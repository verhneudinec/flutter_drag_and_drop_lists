import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item_target.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item_wrapper.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/measure_size.dart';
import 'package:flutter/material.dart';

class DragAndDropList implements DragAndDropListInterface {
  /// The widget that is displayed at the top of the list.
  final Widget? header;

  /// The widget that is displayed at the bottom of the list.
  final Widget? footer;

  /// The widget that is displayed to the left of the list.
  final Widget? leftSide;

  /// The widget that is displayed to the right of the list.
  final Widget? rightSide;

  /// The widget to be displayed when a list is empty.
  /// If this is not null, it will override that set in [DragAndDropLists.contentsWhenEmpty].
  final Widget? contentsWhenEmpty;

  /// The widget to be displayed as the last element in the list that will accept
  /// a dragged item.
  final Widget? lastTarget;

  /// The decoration displayed around a list.
  /// If this is not null, it will override that set in [DragAndDropLists.listDecoration].
  final Decoration? decoration;

  /// The vertical alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.verticalAlignment].
  final CrossAxisAlignment verticalAlignment;

  /// The horizontal alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.horizontalAlignment].
  final MainAxisAlignment horizontalAlignment;

  /// The child elements that will be contained in this list.
  /// It is possible to not provide any children when an empty list is desired.
  @override
  final List<DragAndDropItem> children;

  final void Function()? onTapCallback;

  final void Function(double)? onListHeightChanged;

  final Duration animationDuration;

  /// Whether or not this item can be dragged.
  /// Set to true if it can be reordered.
  /// Set to false if it must remain fixed.
  @override
  final bool canDrag;
  @override
  final Key? key;
  DragAndDropList({
    required this.children,
    this.key,
    this.header,
    this.footer,
    this.leftSide,
    this.rightSide,
    this.contentsWhenEmpty,
    this.lastTarget,
    this.decoration,
    this.horizontalAlignment = MainAxisAlignment.start,
    this.verticalAlignment = CrossAxisAlignment.start,
    this.canDrag = true,
    this.onTapCallback,
    this.onListHeightChanged,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget generateWidget(DragAndDropBuilderParameters params) {
    var contents = <Widget>[];
    if (header != null) {
      contents.add(Flexible(child: header!));
    }
    Widget intrinsicHeight = IntrinsicHeight(
      child: Row(
        mainAxisAlignment: horizontalAlignment,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _generateDragAndDropListInnerContents(params),
      ),
    );
    if (params.axis == Axis.horizontal) {
      intrinsicHeight = SizedBox(
        width: params.listWidth,
        child: intrinsicHeight,
      );
    }
    if (params.listInnerDecoration != null) {
      intrinsicHeight = Flexible(
        child: Container(
          decoration: params.listInnerDecoration,
          child: intrinsicHeight,
        ),
      );
    }
    contents.add(intrinsicHeight);

    if (footer != null) {
      contents.add(Flexible(child: footer!));
    }

    final widget = SizedBox(
      key: key,
      width: params.axis == Axis.vertical
          ? double.infinity
          : params.listWidth - params.listPadding!.horizontal,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: verticalAlignment,
        children: contents,
      ),
    );

    final tapableWidget = InkWell(
      onTap: onTapCallback,
      child: DragTarget(
        onWillAccept: (_) {
          params.listOnWillAccept?.call(null, this);
          return true;
        },
        onAccept: (_) {
          params.listOnAccept?.call(this, this);
        },
        builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
          return AnimatedContainer(
            duration: animationDuration,
            curve: Curves.easeIn,
            decoration: decoration ?? params.listDecoration,
            height: (params.listHeight != null && params.listPadding != null)
                ? params.listHeight! - params.listPadding!.vertical
                : null,
            padding: params.listPadding,
            child: widget,
          );
        }
      ),
    );


    return tapableWidget;
  }

  List<Widget> _generateDragAndDropListInnerContents(
      DragAndDropBuilderParameters parameters) {
    var contents = <Widget>[];
    if (leftSide != null) {
      contents.add(leftSide!);
    }
    if (children.isNotEmpty) {
      List<Widget> allChildren = <Widget>[];
      if (parameters.addLastItemTargetHeightToTop) {
        allChildren.add(Padding(
          padding: EdgeInsets.only(top: parameters.lastItemTargetHeight),
        ));
      }
      for (int i = 0; i < children.length; i++) {
        allChildren.add(DragAndDropItemWrapper(
          key: children[i].key,
          child: children[i],
          parameters: parameters,
        ));
        if (parameters.itemDivider != null && i < children.length - 1) {
          allChildren.add(parameters.itemDivider!);
        }
      }
      allChildren.add(Expanded(
        child: DragAndDropItemTarget(
          parent: this,
          parameters: parameters,
          onReorderOrAdd: parameters.onItemDropOnLastTarget!,
          child: lastTarget ?? Container(height: parameters.lastItemTargetHeight),
        ),
      ));
      contents.add(
        Expanded(
          child: MeasureSize(
            onSizeChange: (size) => onListHeightChanged?.call(size!.height),
            child: Column(
              crossAxisAlignment: verticalAlignment,
              mainAxisSize: MainAxisSize.max,
              children: allChildren,
            ),
          ),
        ),
      );
    } else {
      contents.add(
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: parameters.listHeight != null && parameters.listPadding != null
                  ? parameters.listHeight! - (parameters.listPadding!.vertical * 2)
                  : null,
              child: DragAndDropItemTarget(
                parent: this,
                parameters: parameters,
                onReorderOrAdd: parameters.onItemDropOnLastTarget!,
                child: lastTarget ?? const SizedBox()
              ),
            ),
          ),
        ),
      );
    }
    if (rightSide != null) {
      contents.add(rightSide!);
    }
    return contents;
  }
}