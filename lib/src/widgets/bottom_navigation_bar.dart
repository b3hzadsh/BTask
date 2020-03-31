import 'package:database/ClientModel.dart';
import 'package:database/Database.dart';
import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatefulWidget {
  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  TextEditingController _inputController = new TextEditingController();
  bool _showBottomNavigator = true;
  bool _inputFocus = true;
  Color _submitColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        setState(() {
          _inputFocus = false;
          _showBottomNavigator = false;
          return false;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Divider(
            color: Color.fromRGBO(20, 30, 40, 1.0),
            height: 2.0,
            thickness: 1.95,
          ),
          Container(
            color: Color.fromRGBO(40, 50, 60, 1.0),
            child: ListTile(
              title: TextField(
                onSubmitted: (_) {
                  _addTask();
                },
                onChanged: (str) {
                  setState(() {
                    _submitColor =
                        (str == "") ? Colors.grey : Colors.deepOrangeAccent;
                  });
                },
                autofocus: _inputFocus,
                controller: _inputController,
                decoration: InputDecoration(
                    focusColor: Color.fromRGBO(250, 250, 250, 1.0),
                    border: InputBorder.none,
                    fillColor: Color.fromRGBO(250, 250, 250, 1.0),
                    hintText: "Add a task",
                    hintStyle: TextStyle(color: Colors.white)
                    /* border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(173, 37, 46, 1.0),
                            ),
                          ), */
                    ),
              ),
              trailing: IconButton(
                  //TODO disable when no text entered
                  enableFeedback: true,
                  icon: Icon(
                    Icons.send,
                    color:
                        _submitColor, //TODO change color when its not empty ,dont forgetto setState
                  ),
                  onPressed: _addTask),
            ),
          ),
        ],
      ),
    );
  }

  void _addTask({String x}) async {
    if (_inputController.text != "") {
      Client x = Client(firstName: _inputController.text, blocked: false);
      await DBProvider.db.newClient(x);
      _inputController.clear();
      setState(() {});
    }
  }
}
