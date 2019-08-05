import 'package:flutter/material.dart';
import 'package:notodo_app/model/nodo_item.dart';
import 'package:notodo_app/util/database_client.dart';
import 'package:notodo_app/util/date_formatter.dart';

class NoToDoScreen extends StatefulWidget {
  @override
  _NoToDoScreenState createState() => _NoToDoScreenState();
}

class _NoToDoScreenState extends State<NoToDoScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  var _db = DatabaseHelper();
  final List<NoDoItem> _itemList = <NoDoItem>[];

  @override
  void initState() {
    super.initState();
    _readNoDoList();
  }

  void _handleSubmitted(String text) async {
    _textEditingController.clear();
    NoDoItem noDoItem = NoDoItem(text, dateFormatted());
    int savedItemId = await _db.saveItem(noDoItem);
    NoDoItem _addedItems = await _db.getItem(savedItemId);
    setState(() {
      _itemList.insert(0, _addedItems);
    });
    print('savedItem Id: $savedItemId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: <Widget>[
          Flexible(
              child: ListView.builder(
                  itemCount: _itemList.length,
                  padding: EdgeInsets.all(8.0),
                  reverse: false,
                  itemBuilder: (_, int index) {
                    return Card(
                      color: Colors.white10,
                      child: ListTile(
                        title: _itemList[index],
                        onLongPress: () => _updateItem(_itemList[index], index),
                        trailing: Listener(
                          key: Key(_itemList[index].itemName),
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.redAccent,
                          ),
                          onPointerDown: (pointerEvent) =>
                              _deleteItem(_itemList[index].id, index),
                        ),
                      ),
                    );
                  })),
          Divider(
            height: 1.0,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.redAccent,
          tooltip: 'Add Item',
          child: ListTile(
            title: Icon(Icons.add),
          ),
          onPressed: _showFormDialogue),
    );
  }

  void _showFormDialogue() {
    var alert = AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: "Item",
                  hintText: "eg. Don't buy stuff!",
                  icon: Icon(Icons.note_add)),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              _handleSubmitted(_textEditingController.text);
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text("Save")),
        FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel"))
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  _readNoDoList() async {
    List items = await _db.getAllItems();
    items.forEach((item) {
      setState(() {
        _itemList.add(NoDoItem.map(item));
      });
//      NoDoItem noDoItem = NoDoItem.fromMap(item);
//      print("Db items: ${noDoItem.itemName}");
    });
  }

  _deleteItem(int id, int index) async {
    await _db.deleteItem(id);
    setState(() {
      _itemList.removeAt(index);
    });
  }

  _updateItem(NoDoItem item, int index) {
    var alert = AlertDialog(
      title: Text("Update Item"),
      content: Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "item",
              hintText: "e.g Don't buy stuff",
              icon: Icon(Icons.update),
            ),
          )),
        ],
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () async {
              NoDoItem newItemUpdated = NoDoItem.fromMap({
                "itemName": _textEditingController.text,
                "dateCreated": dateFormatted(),
                "id": item.id,
              });
              _handleSubmittedUpdate(index, item);
              await _db.updateItem(newItemUpdated);
              setState(() {
                _readNoDoList();
              });
              Navigator.pop(context);
            },
            child: Text("Update")),
        FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Canel")),
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  void _handleSubmittedUpdate(int index, NoDoItem item) {
    setState(() {
      _itemList.removeWhere((element) {
        _itemList[index].itemName == item.itemName;
      });
    });
  }
}
