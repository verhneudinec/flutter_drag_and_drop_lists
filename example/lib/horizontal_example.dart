import 'dart:math';

import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:example/custom_navigation_drawer.dart';
import 'package:flutter/material.dart';

class HorizontalExample extends StatefulWidget {
  const HorizontalExample({Key? key}) : super(key: key);

  @override
  State createState() => _HorizontalExample();
}

class InnerList {
  final String name;
  List<String> children;
  InnerList({required this.name, required this.children});
}

class _HorizontalExample extends State<HorizontalExample> {
  late List<InnerList> _lists;
  final ScrollController scrollController = ScrollController();
  int activeIndex = 3;

  @override
  void initState() {
    super.initState();

    _lists = List.generate(9, (outerIndex) {
      return InnerList(
        name: outerIndex.toString(),
        children: List.generate(Random().nextInt(20), (innerIndex) => '$outerIndex.$innerIndex'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horizontal'),
      ),
      drawer: const CustomNavigationDrawer(),
      body: ListView(
        controller: scrollController,
        children: [
          for(int i = 0; i<2; i++)
          Container (
            child: Container(
              height: 3000,
              width: 3000,
              child: DragAndDropLists(
              listHeigth: 1400,
                
                verticalScrollController: scrollController,
                onMoveUpdate: (p0, p1) => print('sdaads $p0 -> $p1'),
                useSnapScrollPhysics: true,
                children: List.generate(_lists.length, (index) => _buildList(index)),
                onItemDraggingChanged: (c, v) {
                  
                },
                listOnWillAccept: (ins, c) {
                  print('kckck ${c?.key}');
                  return true;
                },
                itemTargetOnAccept: (incoming, parentList, target) {
                  print('list listTargetOnAccept ${parentList.key} ${parentList.children?.map((e) => e.key)}');

                  print('list $incoming');
                  
                },
                listTargetOnAccept: (list, t) {
                  print('${list.key}');
                  print('list listTargetOnAccept ${list.key} ${list.children?.map((e) => e.key)}');
                },
                itemOnWillAccept:(incoming, target) {
                  print('list dd');

return true;
                },
                listOnAccept:(incoming, target) {
                  print('list  listOnAcceptdd');

                },
                itemOnAccept: (incoming, target) {
                  print('list  itemOnAccept');

                },
                onItemReorder: _onItemReorder,
                onListReorder: _onListReorder,
                enableAnyDragDirection: true,
                axis: Axis.horizontal,
                listWidth: MediaQuery.sizeOf(context).width * 0.92,
                listDraggingWidth: 150,
                onItemAdd:(newItem, listIndex, newItemIndex) => print('loogog 1'),
                onListAdd: (newList, newListIndex) => print('loogog 2'),
                // listDecoration: BoxDecoration(
                //   color: Colors.grey[200],
                //   borderRadius: const BorderRadius.all(Radius.circular(7.0)),
                //   boxShadow: const <BoxShadow>[
                //     BoxShadow(
                //       color: Colors.black45,
                //       spreadRadius: 3.0,
                //       blurRadius: 6.0,
                //       offset: Offset(2, 3),
                //     ),
                //   ],
                // ),
                listPadding: const EdgeInsets.all(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildList(int outerIndex) {
    final isActive = outerIndex == activeIndex;
    var innerList = _lists[outerIndex];
    return DragAndDropList(
      key: ValueKey('list1 22'),
      decoration: BoxDecoration(color: 
      isActive ? Colors.red.withOpacity(0.3) : null),
      onTapCallback: () {

      },
      // header: Row(
      //   children: <Widget>[
      //     Expanded(
      //       child: Container(
      //         decoration: const BoxDecoration(
      //           borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
      //           color: Colors.pink,
      //         ),
      //         padding: const EdgeInsets.all(10),
      //         child: Text(
      //           'Header ${innerList.name}',
      //           style: Theme.of(context).primaryTextTheme.titleLarge,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      // footer: Row(
      //   children: <Widget>[
      //     Expanded(
      //       child: Container(
      //         decoration: const BoxDecoration(
      //           borderRadius:
      //               BorderRadius.vertical(bottom: Radius.circular(7.0)),
      //           color: Colors.pink,
      //         ),
      //         padding: const EdgeInsets.all(10),
      //         child: Text(
      //           'Footer ${innerList.name}',
      //           style: Theme.of(context).primaryTextTheme.titleLarge,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      // leftSide: const VerticalDivider(
      //   color: Colors.pink,
      //   width: 1.5,
      //   thickness: 1.5,
      // ),
      // rightSide: const VerticalDivider(
      //   color: Colors.pink,
      //   width: 1.5,
      //   thickness: 1.5,
      // ),
      children: List.generate(innerList.children.length,
          (index) => _buildItem(innerList.children[index])),
    );
  }

  _buildItem(String item) {
    return DragAndDropItem(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2.0,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: ListTile(
          title: Text(item),
        ),
      ),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {

      print('sdaads111r ___________________');
      var movedItem = _lists[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
      print('sdaads2222___________________');

    setState(() {
      var movedList = _lists.removeAt(oldListIndex);
      _lists.insert(newListIndex, movedList);
    });
  }
}
