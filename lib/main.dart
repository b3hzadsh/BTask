import 'package:database/src/widgets/my_scaffold.dart';
import 'package:flutter/material.dart';

// import 'dart:math' as math;

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController _inputController = new TextEditingController();
  bool _showBottomNavigator = false;
  bool _inputFocus = true;
  Color _submitColor = Colors.grey;
  // for task ui widget

  @override
  Widget build(BuildContext context) {
    return MyScffold("Client");
  }

  /* void _addTask({String x}) async {
    if (_inputController.text != "") {
      Client x = Client(firstName: _inputController.text, blocked: false);
      await DBProvider.db.newClient(x, "Client");
      setState(() {
        _inputController.clear();
      });
    }
  } */
}
