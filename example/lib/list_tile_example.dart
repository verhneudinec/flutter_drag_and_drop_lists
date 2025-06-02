import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:example/custom_navigation_drawer.dart';
import 'package:flutter/material.dart';

class ListTileExample extends StatefulWidget {
  const ListTileExample({Key? key}) : super(key: key);

  @override
  State createState() => _ListTileExample();
}

class _ListTileExample extends State<ListTileExample> {
  late List<DragAndDropList> _contents;

  final PageController _pageController = PageController(viewportFraction: 0.75);
  late List<DragAndDropList> _contents2;

  Offset? _dragStartPosition;
  bool _isDragging = false;
  double _dragOffsetX = 0;


  @override
  void initState() {
    super.initState();

    _contents = List.generate(4, (index) {
      return DragAndDropList(
        header: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                'Header $index',
              ),
              subtitle: Text('Header $index subtitle'),
            ),
            const Divider(),
          ],
        ),
        footer: Column(
          children: <Widget>[
            const Divider(),
            ListTile(
              title: Text(
                'Footer $index',
              ),
              subtitle: Text('Footer $index subtitle'),
            ),
          ],
        ),
        children: <DragAndDropItem>[
          DragAndDropItem(
            child: ListTile(
              title: Text(
                'Sub $index.1',
              ),
              trailing: const Icon(Icons.access_alarm),
            ),
          ),
          DragAndDropItem(
            child: ListTile(
              title: Text(
                'Sub $index.2',
              ),
              trailing: const Icon(Icons.alarm_off),
            ),
          ),
          DragAndDropItem(
            child: ListTile(
              title: Text(
                'Sub $index.3',
              ),
              trailing: const Icon(Icons.alarm_on),
            ),
          ),
        ],
      );
    });


    _contents2 = List.generate(4, (index) {
      return DragAndDropList(
        header: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                'Header $index',
              ),
              subtitle: Text('Header $index subtitle'),
            ),
            const Divider(),
          ],
        ),
        footer: Column(
          children: <Widget>[
            const Divider(),
            ListTile(
              title: Text(
                'Footer $index',
              ),
              subtitle: Text('Footer $index subtitle'),
            ),
          ],
        ),
        children: <DragAndDropItem>[
          DragAndDropItem(
            child: ListTile(
              title: Text(
                'Sub $index.1',
              ),
              trailing: const Icon(Icons.access_alarm),
            ),
          ),
          DragAndDropItem(
            child: ListTile(
              title: Text(
                'Sub $index.2',
              ),
              trailing: const Icon(Icons.alarm_off),
            ),
          ),
          DragAndDropItem(
            child: ListTile(
              title: Text(
                'Sub $index.3',
              ),
              trailing: const Icon(Icons.alarm_on),
            ),
          ),
        ],
      );
    });
  }


void _checkEdgeScroll(Offset position) {
    final screenWidth = MediaQuery.of(context).size.width;
    const edgeThreshold = 125.0; // Расстояние от края для срабатывания
    
    // Проверяем левый край
    if (position.dx < edgeThreshold && _pageController.page! > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
    // Проверяем правый край
    else if (position.dx > screenWidth - edgeThreshold && 
             _pageController.page! < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }


 void _handleDragPosition(Offset globalPosition) {
    final screenWidth = MediaQuery.of(context).size.width;
    const threshold = 100.0; // Зона срабатывания у краев экрана

    if (globalPosition.dx < threshold && _pageController.page! > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else if (globalPosition.dx > screenWidth - threshold && 
    // _pages.length
               _pageController.page! < 2 - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Tiles'),
      ),
      drawer: const CustomNavigationDrawer(),
      body: Builder(
        // onMove: (details) => _checkEdgeScroll(details.),
        builder: (BuildContext context) { 
return PageView(
  controller: _pageController,
        physics: _isDragging ? NeverScrollableScrollPhysics() : null,
  // allowImplicitScrolling: true,
          children: [
            Listener(
               onPointerMove: (event) => _handleDragPosition(event.position),
             behavior: HitTestBehavior.opaque,
      
              child: Container(
                width: 250,
                child: DragAndDropLists(
                  children: _contents,
                  onItemReorder: _onItemReorder,
                  enableAnyDragDirection: true,
                  onListReorder: _onListReorder,
                  listGhost: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 100.0),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: const Icon(Icons.add_box),
                      ),
                    ),
                  ),
                  listPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  contentsWhenEmpty: Row(
                    children: <Widget>[
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 40, right: 10),
                          child: Divider(),
                        ),
                      ),
                      Text(
                        'Empty List',
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall!.color,
                            fontStyle: FontStyle.italic),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 20, right: 40),
                          child: Divider(),
                        ),
                      ),
                    ],
                  ),
                  listDecoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ),
            ),
        
        
        
            GestureDetector(
             behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        _dragStartPosition = details.globalPosition;
        _dragOffsetX = 0;
        setState(() => _isDragging = true);
      },
      onPanUpdate: (details) {
        final currentPosition = details.globalPosition;
        _dragOffsetX = currentPosition.dx - _dragStartPosition!.dx;
        
        // Реальное время: двигаем PageView пропорционально смещению пальца
        if (_pageController.hasClients) {
          final pageWidth = MediaQuery.of(context).size.width;
          final currentPage = _pageController.page!;
          final newPageOffset = currentPage - _dragOffsetX / (pageWidth * 0.7);
          
          _pageController.position.jumpToWithoutSettling(newPageOffset * pageWidth);
        }
      },
      onPanEnd: (details) {
        // Возвращаем к ближайшей странице
        _pageController.animateToPage(
          _pageController.page!.round(),
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
        
        setState(() {
          _isDragging = false;
          _dragStartPosition = null;
          _dragOffsetX = 0;
        });
      },
              child: Container(
                width: 250,
                child: DragAndDropLists(
                        children: _contents2,
                  enableAnyDragDirection: true,
                        
                        onItemReorder: _onItemReorder,
                        onListReorder: _onListReorder,
                        listGhost: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 100.0),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: const Icon(Icons.add_box),
                  ),
                ),
                        )),
              ),
            ),
          ],
        );
         },
  
      ),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _contents[oldListIndex].children.removeAt(oldItemIndex);
      _contents[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _contents.removeAt(oldListIndex);
      _contents.insert(newListIndex, movedList);
    });
  }
}
