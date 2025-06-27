import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:example/custom_navigation_drawer.dart';
import 'package:flutter/material.dart';

class HorizontalExample extends StatefulWidget {
  const HorizontalExample({Key? key}) : super(key: key);

  @override
  State createState() => _HorizontalExample();
}

class _HorizontalExample extends State<HorizontalExample> {
  final List<DragAndDropList> _contents = <DragAndDropList>[];
  double? _maxListHeight;

  @override
  void initState() {
    super.initState();
    _contents.addAll([
      DragAndDropList(
        header: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Text(
            'List 1',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        children: <DragAndDropItem>[
          DragAndDropItem(
            child: Container(
              height: 100,
              child: const Card(
                child: Center(child: Text('Item 1')),
              ),
            ),
          ),
          DragAndDropItem(
            child: Container(
              height: 150,
              child: const Card(
                child: Center(child: Text('Item 2')),
              ),
            ),
          ),
          DragAndDropItem(
            child: Container(
              height: 80,
              child: const Card(
                child: Center(child: Text('Item 3')),
              ),
            ),
          ),
        ],
      ),
      DragAndDropList(
        header: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Text(
            'List 2',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        children: <DragAndDropItem>[
          DragAndDropItem(
            child: Container(
              height: 120,
              child: const Card(
                child: Center(child: Text('Item 4')),
              ),
            ),
          ),
          DragAndDropItem(
            child: Container(
              height: 90,
              child: const Card(
                child: Center(child: Text('Item 5')),
              ),
            ),
          ),
          DragAndDropItem(
            child: Container(
              height: 200,
              child: const Card(
                child: Center(child: Text('Item 6')),
              ),
            ),
          ),
        ],
      ),
      DragAndDropList(
        header: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Text(
            'List 3',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        children: <DragAndDropItem>[
          DragAndDropItem(
            child: Container(
              height: 110,
              child: const Card(
                child: Center(child: Text('Item 7')),
              ),
            ),
          ),
          DragAndDropItem(
            child: Container(
              height: 130,
              child: const Card(
                child: Center(child: Text('Item 8')),
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horizontal Lists with Two-Phase Build'),
      ),
      drawer: const CustomNavigationDrawer(),
      body: Column(
        children: <Widget>[
          if (_maxListHeight != null)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.yellow,
              child: Text('Max List Height: ${_maxListHeight!.toStringAsFixed(1)}'),
            ),
          Flexible(
            flex: 10,
            child: DragAndDropLists(
              axis: Axis.horizontal,
              listWidth: 200,
              children: _contents,
              onItemReorder: _onItemReorder,
              onListReorder: _onListReorder,
              enableTwoPhaseBuild: true,
              onListHeightChanged: (height) {
                print('List height measured: $height');
              },
            ),
          ),
        ],
      ),
    );
  }

  _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      final DragAndDropItem item = _contents[oldListIndex].children.removeAt(oldItemIndex);
      _contents[newListIndex].children.insert(newItemIndex, item);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      final DragAndDropList list = _contents.removeAt(oldListIndex);
      _contents.insert(newListIndex, list);
    });
  }
}
