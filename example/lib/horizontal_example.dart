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
  late List<InnerList> _lists2;

  ScrollController _mycontroller1 = new ScrollController(); // make seperate controllers
  ScrollController _mycontroller2 = new ScrollController();


  @override
  void initState() {
    super.initState();

    _lists = List.generate(6, (outerIndex) {
      return InnerList(
        name: outerIndex.toString(),
        children: List.generate(2, (innerIndex) => '$outerIndex.$innerIndex'),
      );
    });

    _lists2 = List.generate(6, (outerIndex) {
      return InnerList(
        name: '2222222' + outerIndex.toString(),
        children: List.generate(2, (innerIndex) => '$outerIndex.$innerIndex.2'),
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
      body:  NotificationListener<ScrollNotification>(
        
          onNotification: (ScrollNotification scrollInfo) {  // HEY!! LISTEN!!
            // this will set controller1's offset the same as controller2's
            _mycontroller1.jumpTo(_mycontroller2.offset); 

            // you can check both offsets in terminal
            print('check -- offset Left: '+_mycontroller1.offset.toInt().toString()+ ' -- offset Right: '+_mycontroller2.offset.toInt().toString()); 
          
          return true;
          },
        child: Column(children: [
        
        
          Container(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: DragAndDropLists(
            useSnapScrollPhysics: true,
            children: List.generate(_lists.length, (index) => _buildList(index)),
            onItemReorder: _onItemReorder,
            onListReorder: _onListReorder,
            axis: Axis.horizontal,
            onItemDraggingChanged: (item, dragging) => print('onItemDraggingChanged $item $dragging'),
             onItemAdd: (newItem, listIndex, newItemIndex) {
        print('movedItem newItem ${newItem.runtimeType} ');
            setState(() {
        _lists2[0].children.removeAt(listIndex);
        
        _lists[0].children.insert(newItemIndex, _lists2[0].children[listIndex]);
            });
            },
            listWidth: MediaQuery.sizeOf(context).width * 0.9,
            listDraggingWidth: 150,
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
            scrollController: _mycontroller1,
            listPadding: const EdgeInsets.all(8.0),
                  ),
          ),
        Container(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: DragAndDropLists(
            useSnapScrollPhysics: true,
            children: List.generate(_lists2.length, (index) => _buildList(index, true)),
            onItemReorder: _onItemReorder,
            onListReorder: _onListReorder,
            onItemAdd: (newItem, listIndex, newItemIndex) {
        print('movedItem newItem ${newItem} ');
            setState(() {
        _lists[0].children.removeAt(listIndex);
        _lists2[0].children.insert(newItemIndex,  _lists[0].children[listIndex]);
            });
            },
            onListAdd:(newList, newListIndex) {
        print('movedItem ${newList} ');
        
        
            },
            scrollController: _mycontroller2,
            axis: Axis.horizontal,
            listWidth: MediaQuery.sizeOf(context).width * 0.9,
            listDraggingWidth: 150,
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
          )
        
        
        ],),
      ),
    );
  }

  _buildList(int outerIndex, [bool list2 = false]) {
    var innerList = list2 ? _lists2[outerIndex] : _lists[outerIndex];
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
    return DragAndDropItem<KeepAlive>(
      key: ValueKey('iTEM_${item}'),
      child: ListTile(
        title: Text(item),
      ),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      print('movedItem ${oldItemIndex} ${oldListIndex} ${newItemIndex} ${newListIndex}');
      var movedItem = _lists2[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _lists2.removeAt(oldListIndex);
      _lists.insert(newListIndex, movedList);
    });
  }
}


