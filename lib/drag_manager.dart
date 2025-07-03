import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'dart:math';

class DragManager {
  DragAndDropItem? _draggingItem;
  DragAndDropListInterface? _draggingItemParent;
  bool _isDragging = false;
  List<DragAndDropListsState> _activeInstances = [];
  ScrollController? _sharedScrollController;

  // Состояние скролла
  bool _pointerDown = false;
  double? _pointerYPosition;
  double? _pointerXPosition;
  bool _scrolling = false;
  DateTime? _lastScrollTime;
  final _scrollThrottle = const Duration(milliseconds: 1300);
  final _scrollTriggerZone = 50.0;
  final int _duration = 30; // in ms
  final int _scrollAreaSize = 60;
  final double _overDragMin = 5.0;
  final double _overDragMax = 20.0;
  final double _overDragCoefficient = 3.3;

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
  }

  bool get isDragging => _isDragging;
  DragAndDropItem? get draggingItem => _draggingItem;
  DragAndDropListInterface? get draggingItemParent => _draggingItemParent;
  ScrollController? get sharedScrollController => _sharedScrollController;

  // Методы для управления скроллом
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
  }

  void scrollList() async {
    if (!_scrolling &&
        _pointerDown &&
        _pointerYPosition != null &&
        _pointerXPosition != null) {

      // Найти активный экземпляр для получения контекста
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

      final verticalOffset = _scrollListVerticalOld(activeInstance);
      final directionality = Directionality.of(activeInstance.context);
      final horizontalOffset = activeInstance.widget.useSnapScrollPhysics
        ? _scrollListHorizontalWithSnapPhysicsOld(topLeftOffset, bottomRightOffset, activeInstance)
          : directionality == TextDirection.ltr
            ? _scrollListHorizontalLtr(topLeftOffset, bottomRightOffset, activeInstance)
            : _scrollListHorizontalRtl(topLeftOffset, bottomRightOffset, activeInstance);

      // // Выполняем вертикальный и горизонтальный скролл
      // if (verticalOffset != null) {
      //   _scrolling = true;
      //   final scrollController = activeInstance.widget.verticalScrollController ?? activeInstance.scrollController;
      //   scrollController!.animateTo(verticalOffset,
      //       duration: Duration(milliseconds: _duration), curve: Curves.linear).then((_) {
      //     _scrolling = false;
      //     if (_pointerDown && verticalOffset <= scrollController.position.maxScrollExtent) scrollList();
      //   });
      // }

      // if (horizontalOffset != null) {
      //   if (!_scrolling) {
      //     _scrolling = true;
      //   }
      //   final scrollController = activeInstance.widget.scrollController ?? activeInstance.scrollController;
      //   scrollController!.animateTo(horizontalOffset,
      //       duration: Duration(milliseconds: _duration), curve: Curves.linear).then((_) {
      //     if (!_scrolling) {
      //       _scrolling = false;
      //       if (_pointerDown) scrollList();
      //     }
      //   });
      // }

      
    }
  }

  double _scrollListHorizontalWithSnapPhysicsOld(Offset topLeftOffset, Offset bottomRightOffset, DragAndDropListsState instance) {
    final pointerXPosition = _pointerXPosition;
    final scrollController = instance.widget.scrollController ?? instance.scrollController;

    if (scrollController == null || pointerXPosition == null) return 0.0;

    final position = scrollController.position;
    final double listWidth = instance.widget.listWidth;
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
        _lastScrollTime = now;

        scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 350),
          curve: Curves.linear
        ).then((_) {
          _scrolling = false;
          if (_pointerDown) scrollList();
        });
      }

    return position.pixels;
  }

  double? _scrollListVerticalOld(DragAndDropListsState instance) {
    if (_isDragging) {
      forceMoveToVisibleList();
    }

    final pointerYPosition = _pointerYPosition;
    final scrollController = instance.widget.verticalScrollController ?? instance.scrollController;

    if (scrollController == null || pointerYPosition == null) return null;

    final position = scrollController.position;
    final viewportHeight = position.viewportDimension;

    const top = 80.0;
    final bottom = viewportHeight;

    double? newOffset;

    if (pointerYPosition < (top + _scrollAreaSize)) {
      final overDrag = max((top + _scrollAreaSize) - pointerYPosition, _overDragMax);
      newOffset = position.pixels - overDrag / _overDragCoefficient;
    } else if (pointerYPosition > (bottom - _scrollAreaSize)) {
      final overDrag = max(pointerYPosition - (bottom - _scrollAreaSize), _overDragMax);
      newOffset = position.pixels + overDrag / _overDragCoefficient;
    }

    if (newOffset != null && newOffset > 0) {
      final isMoreThanMax = newOffset > position.maxScrollExtent;
      newOffset = newOffset.clamp(position.minScrollExtent, position.maxScrollExtent);
      // Запускаем анимацию скролла и продолжаем скроллить, пока палец на экране
      _scrolling = true;

      final offset = min(newOffset, scrollController.position.maxScrollExtent);

      scrollController.animateTo(offset,
        duration: Duration(milliseconds: _duration), curve: Curves.linear).then((_) {
        _scrolling = false;
        if (_pointerDown && !isMoreThanMax) scrollList();
      });
    }

    return newOffset;
  }

  double? _scrollListVertical(DragAndDropListsState activeInstance) {
    final pointerYPosition = _pointerYPosition;
    final scrollController = activeInstance.widget.verticalScrollController ?? activeInstance.scrollController;

    if (scrollController == null || pointerYPosition == null) return null;

    final position = scrollController.position;
    final viewportHeight = position.viewportDimension;

    const top = 80.0;
    final bottom = viewportHeight;

    double? newOffset;

    if (pointerYPosition < (top + _scrollAreaSize)) {
      final overDrag = max((top + _scrollAreaSize) - pointerYPosition, _overDragMax);
      newOffset = position.pixels - overDrag / _overDragCoefficient;
    } else if (pointerYPosition > (bottom - _scrollAreaSize)) {
      final overDrag = max(pointerYPosition - (bottom - _scrollAreaSize), _overDragMax);
      newOffset = position.pixels + overDrag / _overDragCoefficient;
    }

    // Убираем дублирование анимации - просто возвращаем значение
    if (newOffset != null) {
      newOffset = newOffset.clamp(position.minScrollExtent, position.maxScrollExtent);
    }

    return newOffset;
  }

  double? _scrollListHorizontalWithSnapPhysics(Offset topLeftOffset, Offset bottomRightOffset, DragAndDropListsState instance) {
    final pointerXPosition = _pointerXPosition;
    final scrollController = instance.widget.scrollController ?? instance.scrollController;

    if (scrollController == null || pointerXPosition == null) return null;

    final position = scrollController.position;
    final double listWidth = instance.widget.listWidth;
    double left = topLeftOffset.dx;
    double right = bottomRightOffset.dx;

    final now = DateTime.now();
    if (_lastScrollTime != null) {
      if (now.difference(_lastScrollTime!) < _scrollThrottle) {
        return null;
      }
    }

    double? targetOffset;

    if (pointerXPosition < (left + _scrollTriggerZone)) {
      targetOffset = position.pixels - listWidth;
    } else if (pointerXPosition > (right - _scrollTriggerZone)) {
      targetOffset = position.pixels + listWidth;
    }

    if (targetOffset != null) {
      targetOffset = targetOffset.clamp(position.minScrollExtent, position.maxScrollExtent);
      _lastScrollTime = now;
    }

    return targetOffset;
  }

  double? _scrollListHorizontalLtr(Offset topLeftOffset, Offset bottomRightOffset, DragAndDropListsState instance) {
    double left = topLeftOffset.dx;
    double right = bottomRightOffset.dx;
    double? newOffset;

    var pointerXPosition = _pointerXPosition;
    var scrollController = instance.widget.scrollController ?? instance.scrollController;
    if (scrollController != null && pointerXPosition != null) {
      if (pointerXPosition < (left + _scrollAreaSize) &&
          scrollController.position.pixels > scrollController.position.minScrollExtent) {
        final overDrag = min((left + _scrollAreaSize) - pointerXPosition + _overDragMin, _overDragMax);
        newOffset = max(scrollController.position.minScrollExtent,
            scrollController.position.pixels - overDrag / _overDragCoefficient);
      } else if (pointerXPosition > (right - _scrollAreaSize) &&
          scrollController.position.pixels < scrollController.position.maxScrollExtent) {
        final overDrag = min(pointerXPosition - (right - _scrollAreaSize) + _overDragMin, _overDragMax);
        newOffset = min(scrollController.position.maxScrollExtent,
            scrollController.position.pixels + overDrag / _overDragCoefficient);
      }
    }

    return newOffset;
  }

  double? _scrollListHorizontalRtl(Offset topLeftOffset, Offset bottomRightOffset, DragAndDropListsState instance) {
    double left = topLeftOffset.dx;
    double right = bottomRightOffset.dx;
    double? newOffset;

    var pointerXPosition = _pointerXPosition;
    var scrollController = instance.widget.scrollController ?? instance.scrollController;
    if (scrollController != null && pointerXPosition != null) {
      if (pointerXPosition < (left + _scrollAreaSize) &&
          scrollController.position.pixels < scrollController.position.maxScrollExtent) {
        final overDrag = min((left + _scrollAreaSize) - pointerXPosition + _overDragMin, _overDragMax);
        newOffset = min(scrollController.position.maxScrollExtent,
            scrollController.position.pixels + overDrag / _overDragCoefficient);
      } else if (pointerXPosition > (right - _scrollAreaSize) &&
          scrollController.position.pixels > scrollController.position.minScrollExtent) {
        final overDrag = min(pointerXPosition - (right - _scrollAreaSize) + _overDragMin, _overDragMax);
        newOffset = max(scrollController.position.minScrollExtent,
            scrollController.position.pixels - overDrag / _overDragCoefficient);
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
      if (nearestInstance.widget.children.isNotEmpty && nearestInstance.widget.onItemReorder != null) {
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
          nearestInstance.widget.onItemReorder!(oldItemIndex, oldListIndex, 0, 0);
        }
      }
    }
  }
}