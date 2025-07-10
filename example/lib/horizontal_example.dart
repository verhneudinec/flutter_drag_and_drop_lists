import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:drag_and_drop_lists/drag_manager.dart';
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
  // Создаем экземпляр DragManager для управления перетаскиванием
  final DragManager _dragManager = DragManager();
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();

    // Инициализируем ScrollController
    _scrollController = ScrollController();
    // Передаем контроллер скролла в DragManager
    _dragManager.setSharedScrollController(_scrollController!);

    _lists = List.generate(9, (outerIndex) {
      return InnerList(
        name: outerIndex.toString(),
        children: List.generate(12, (innerIndex) => '$outerIndex.$innerIndex'),
      );
    });
  }

  @override
  void dispose() {
    // Очищаем ресурсы при уничтожении виджета
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horizontal'),
      ),
      drawer: const CustomNavigationDrawer(),
      body: Listener(
        onPointerDown: _dragManager.onPointerDown,
        onPointerUp: _dragManager.onPointerUp,
        onPointerMove: _dragManager.onPointerMove,
        child: DragAndDropLists(
          useSnapScrollPhysics: true,
          children: List.generate(_lists.length, (index) => _buildList(index)),
          onItemReorder: _onItemReorder,
          onListReorder: _onListReorder,
          axis: Axis.horizontal,
          listWidth: MediaQuery.sizeOf(context).width * 0.9,
          listDraggingWidth: 150,
          scrollController: _scrollController,
          dragManager: _dragManager, // Передаем DragManager для блокировки горизонтального скролла при вертикальном
          listDecoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.all(Radius.circular(7.0)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Colors.black45,
                spreadRadius: 3.0,
                blurRadius: 6.0,
                offset: Offset(2, 3),
              ),
            ],
          ),
          listPadding: const EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  _buildList(int outerIndex) {
    var innerList = _lists[outerIndex];
    return DragAndDropList(
      header: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
                color: Colors.pink,
              ),
              padding: const EdgeInsets.all(10),
              child: Text(
                'Header ${innerList.name}',
                style: Theme.of(context).primaryTextTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
      footer: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(7.0)),
                color: Colors.pink,
              ),
              padding: const EdgeInsets.all(10),
              child: Text(
                'Footer ${innerList.name}',
                style: Theme.of(context).primaryTextTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
      leftSide: const VerticalDivider(
        color: Colors.pink,
        width: 1.5,
        thickness: 1.5,
      ),
      rightSide: const VerticalDivider(
        color: Colors.pink,
        width: 1.5,
        thickness: 1.5,
      ),
      children: List.generate(innerList.children.length,
          (index) => _buildItem(innerList.children[index])),
    );
  }

  _buildItem(String item) {
    return DragAndDropItem(
      child: ListTile(
        title: Text(item),
      ),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _lists[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _lists.removeAt(oldListIndex);
      _lists.insert(newListIndex, movedList);
    });
  }
}
