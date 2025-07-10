import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'dart:math';

class DragAndDropListsMananger {
  DragAndDropItem? _draggingItem;
  DragAndDropListInterface? _draggingItemParent;
  bool _isDragging = false;
  List<DragAndDropListsState> _activeInstances = [];
  ScrollController? _sharedScrollController;

  bool _pointerDown = false;
  double? _pointerYPosition;
  double? _pointerXPosition;
  bool _scrolling = false;
  DateTime? _lastScrollTime;
  final _scrollThrottle = const Duration(milliseconds: 1300);
  final _scrollTriggerZone = 25.0;
  final int _duration = 30; // in ms
  final int _scrollAreaSize = 8;
  final double _overDragMin = 5.0;
  final double _overDragMax = 20.0;
  final double _overDragCoefficient = 3.3;
  final double _overDragCoefficientUp = 2.5; // Faster upward scrolling

  void registerInstance(DragAndDropListsState instance) {
    if (!_activeInstances.contains(instance)) {
      _activeInstances.add(instance);
    }
  }

  void unregisterInstance(DragAndDropListsState instance) {
    _activeInstances.remove(instance);
  }

  void setSharedScrollController(ScrollController controller) {
    _sharedScrollController = controller;
  }

  void startDragging(DragAndDropItem item, DragAndDropListInterface? parent) {
    _draggingItem = item;
    _draggingItemParent = parent;
    _isDragging = true;
  }

  void stopDragging() {
    _draggingItem = null;
    _draggingItemParent = null;
    _isDragging = false;
    resetScrollState(); // Reset scroll state when stopping dragging
  }

  bool get isDragging => _isDragging;
  DragAndDropItem? get draggingItem => _draggingItem;
  DragAndDropListInterface? get draggingItemParent => _draggingItemParent;
  ScrollController? get sharedScrollController => _sharedScrollController;

  // Methods for scroll management
  void onPointerMove(PointerMoveEvent event) {
    if (_pointerDown) {
      _pointerYPosition = event.position.dy;
      _pointerXPosition = event.position.dx;
      scrollList();
    }
  }

  void onPointerDown(PointerDownEvent event) {
    _pointerDown = true;
    _pointerYPosition = event.position.dy;
    _pointerXPosition = event.position.dx;
  }

  void onPointerUp(PointerUpEvent event) {
    _pointerDown = false;
    // Reset vertical scrolling flag when pointer is released
    _isVerticalScrolling = false;
  }

  // Flag to track if vertical scrolling is currently in progress
  bool _isVerticalScrolling = false;

  void scrollList() async {
    if (!_scrolling &&
        _pointerDown &&
        _pointerYPosition != null &&
        _pointerXPosition != null) {

      // Find active instance to get context
      DragAndDropListsState? activeInstance;
      for (var instance in _activeInstances) {
        if (instance.mounted) {
          activeInstance = instance;
          break;
        }
      }

      if (activeInstance == null || !activeInstance.mounted) return;

      var rb = activeInstance.context.findRenderObject()!;
      late Size size;
      if (rb is RenderBox) {
        size = rb.size;
      } else if (rb is RenderSliver) {
        size = rb.paintBounds.size;
      }

      var topLeftOffset = localToGlobal(rb, Offset.zero);
      var bottomRightOffset = localToGlobal(rb, size.bottomRight(Offset.zero));

      // First check vertical scroll
      final verticalOffset = scrollListVertical(activeInstance);

      // Set vertical scrolling flag
      _isVerticalScrolling = verticalOffset != null;

      // Start horizontal scroll only if no vertical scrolling
      double? horizontalOffset;
      if (!_isVerticalScrolling) {
        horizontalOffset = activeInstance.widget.useSnapScrollPhysics
        ? scrollListHorizontalWithSnapPhysics(topLeftOffset, bottomRightOffset, activeInstance)
        : scrollListHorizontal(topLeftOffset, bottomRightOffset, activeInstance);
      }

      if (verticalOffset != null || horizontalOffset != null) {
        // not used for now
        // widget.onMoveUpdate?.call(_pointerYPosition, _pointerXPosition);
      }
    }
  }

  double? scrollListVertical(DragAndDropListsState activeInstance) {
    final pointerYPosition = _pointerYPosition;
    final scrollController = activeInstance.widget.verticalScrollController ?? activeInstance.scrollController;

    if (scrollController == null || pointerYPosition == null) return null;

    final position = scrollController.position;
    final viewportHeight = position.viewportDimension;

    const top = 80.0;
    final bottom = viewportHeight;

    double? newOffset;

    // Reset vertical scrolling flag by default
    _isVerticalScrolling = false;

    if (pointerYPosition < (top + _scrollAreaSize)) {
      final overDrag = max((top + _scrollAreaSize) - pointerYPosition, _overDragMax);
      newOffset = position.pixels - overDrag / _overDragCoefficientUp; // Use faster coefficient for upward scroll
    } else if (pointerYPosition > (bottom - _scrollAreaSize)) {
      final overDrag = max(pointerYPosition - (bottom - _scrollAreaSize), _overDragMax);
      newOffset = position.pixels + overDrag / _overDragCoefficient; // Use normal coefficient for downward scroll
    }

    if (newOffset != null && newOffset > 0) {
      _lastScrollTime = DateTime.now().add(Duration(milliseconds: _duration));
      final isMoreThanMax = newOffset > position.maxScrollExtent;
      newOffset = newOffset.clamp(position.minScrollExtent, position.maxScrollExtent);

      _isVerticalScrolling = true;

      // Start scroll animation and continue scrolling while finger is on screen
      _scrolling = true;

      final offset = min(newOffset, scrollController.position.maxScrollExtent);

      scrollController.animateTo(offset,
        duration: Duration(milliseconds: _duration), curve: Curves.linear).then((_) {
        _scrolling = false;
        if (_pointerDown && !isMoreThanMax) scrollList();
      }).then((_) {
        _isVerticalScrolling = false;
      });
    }

    return newOffset;
  }



  double scrollListHorizontalWithSnapPhysics(Offset topLeftOffset, Offset bottomRightOffset, DragAndDropListsState activeInstance) {
    // If vertical scrolling is in progress, don't perform horizontal scrolling
    if (_isVerticalScrolling) return 0.0;

    final pointerXPosition = _pointerXPosition;
    final scrollController = activeInstance.scrollController;

    if (scrollController == null || pointerXPosition == null || !_pointerDown) return 0.0;

    final position = scrollController.position;
    final double listWidth = activeInstance.widget.listWidth;
    double left = topLeftOffset.dx;
    double right = bottomRightOffset.dx;

    // Check if enough time has passed since last scroll
    final now = DateTime.now();
    if (_lastScrollTime != null) {
      if (now.difference(_lastScrollTime!) < _scrollThrottle) {
        return position.pixels;
      }
    }

    double? targetOffset;

    if (pointerXPosition < (left + _scrollTriggerZone)) {
      // Scroll left
      targetOffset = position.pixels - listWidth;
    } else if (pointerXPosition > (right - _scrollTriggerZone)) {
      // Scroll right
      targetOffset = position.pixels + listWidth;
    }

    if (!_scrolling && _pointerDown && targetOffset != null) {
        targetOffset = targetOffset.clamp(position.minScrollExtent, position.maxScrollExtent);
        _scrolling = true;

        scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 350),
          curve: Curves.linear
        ).then((_) {
          _lastScrollTime = now.add(Duration(milliseconds: _duration));
          _scrolling = false;
          if (_pointerDown) scrollList();
        });
      }

    return position.pixels;
  }

  double? scrollListHorizontal(
      Offset topLeftOffset, Offset bottomRightOffset, DragAndDropListsState activeInstance) {
    // If vertical scrolling is in progress, don't perform horizontal scrolling
    if (_isVerticalScrolling) return null;

    double left = topLeftOffset.dx;
    double right = bottomRightOffset.dx;
    double? newOffset;
    const additionalScrollAmount = 50.0;

    var pointerXPosition = _pointerXPosition;
    var scrollController = activeInstance.scrollController;
    if (scrollController != null && pointerXPosition != null) {
      if (pointerXPosition < (left + _scrollAreaSize) &&
          scrollController.position.pixels >
              scrollController.position.minScrollExtent) {
        // scrolling toward minScrollExtent
        final overDrag = min(
            (left + _scrollAreaSize) - pointerXPosition + _overDragMin,
            _overDragMax) + additionalScrollAmount;
        newOffset = max(scrollController.position.minScrollExtent,
            scrollController.position.pixels - overDrag / _overDragCoefficient);
      } else if (pointerXPosition > (right - _scrollAreaSize) &&
          scrollController.position.pixels <
              scrollController.position.maxScrollExtent) {
        // scrolling toward maxScrollExtent
        final overDrag = min(
            pointerXPosition - (right - _scrollAreaSize) + _overDragMin,
            _overDragMax) + additionalScrollAmount;

        newOffset = min(scrollController.position.maxScrollExtent,
            scrollController.position.pixels + overDrag / _overDragCoefficient);
      }

      final now = DateTime.now();
      if (_pointerDown && newOffset != null) {
        newOffset = newOffset.clamp(scrollController.position.minScrollExtent, scrollController.position.maxScrollExtent);

        _scrolling = true;
        _lastScrollTime = now;

        scrollController.animateTo(
          newOffset,
          duration: Duration(milliseconds: _duration),
          curve: Curves.linear
        ).then((_) {
          _scrolling = false;
          if (_pointerDown) scrollList();
        });
      }
    }

    return newOffset;
  }

  static Offset localToGlobal(RenderObject object, Offset point, {RenderObject? ancestor}) {
    return MatrixUtils.transformPoint(object.getTransformTo(ancestor), point);
  }

  void forceMoveToVisibleList() {
    if (!_isDragging || _draggingItem == null) return;
    DragAndDropListsState? nearestInstance;
    for (var instance in _activeInstances) {
      if (instance.mounted) {
        nearestInstance = instance;
        break;
      }
    }
    if (nearestInstance != null && nearestInstance.mounted) {
      if (nearestInstance.widget.children.isNotEmpty) {
        int oldListIndex = -1;
        int oldItemIndex = -1;
        for (int i = 0; i < nearestInstance.widget.children.length; i++) {
          if (nearestInstance.widget.children[i] == _draggingItemParent) {
            oldListIndex = i;
            oldItemIndex = _draggingItemParent?.children?.indexWhere((e) => e == _draggingItem) ?? -1;
            break;
          }
        }
        if (oldListIndex != -1 && oldItemIndex != -1) {
          nearestInstance.widget.onItemReorder(oldItemIndex, oldListIndex, 0, 0);
        }
      }
    }
  }

  void resetScrollState() {
    _pointerDown = false;
    _scrolling = false;
    _isVerticalScrolling = false;
    _pointerYPosition = null;
    _pointerXPosition = null;
  }
}