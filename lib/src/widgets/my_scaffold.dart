import 'package:database/Database.dart';
import 'package:database/src/utils/bloc/bloc.dart';
import 'package:database/src/utils/colors.dart';
import 'package:database/src/widgets/drawer.dart';
import 'package:flutter/material.dart';

import '../../ClientModel.dart';

class MyScffold extends StatefulWidget {
  MyScffold(this.tableName);
  final String tableName;
  @override
  _MyScffoldState createState() => _MyScffoldState();
}

class _MyScffoldState extends State<MyScffold> {
  TextEditingController _inputController = new TextEditingController();
  bool _showBottomNavigator = false;
  bool _inputFocus = true;
  Color _submitColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //,
      drawer: MyDrawer(),
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        //TODO use sliver appbar
        title: Text(
          widget.tableName == "Client"
              ? "Inbox"
              : widget
                  .tableName, //TODO must be the table name given from constructor
          style: TextStyle(
            color: Color.fromRGBO(230, 230, 235, 1.0),
          ),
        ),
        backgroundColor: MyColors.bgDark,
        actions: <Widget>[
          _simplePopup(widget.tableName, context),
        ],
      ),
      body: Container(
        color: MyColors.bg,
        child: FutureBuilder<List<Client>>(
          future: DBProvider.db.getAllClients(widget.tableName),
          builder:
              (BuildContext context, AsyncSnapshot<List<Client>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Client item = snapshot.data[index];
                  return Dismissible(
                    key: UniqueKey(), // TODO what is unique key?
                    background: Container(color: Colors.red),
                    onDismissed: (_) {
                      DBProvider.db.deleteClient(item.id, widget.tableName);
                    },
                    child: ListTile(
                      title: Text(
                        item.firstName,
                        style: TextStyle(
                          color: MyColors.red,
                        ),
                      ),
                      trailing: IconButton(
                          icon: item.blocked
                              ? Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                )
                              : Icon(Icons.star_border),
                          onPressed: () async {
                            setState(() {
                              item.blocked = (item.blocked ==
                                  false); //TODO may adding bot code to setstate solve
                            });
                            Client needVip = Client(
                                id: item.id,
                                firstName: item.firstName,
                                blocked: item.blocked);
                            await DBProvider.db
                                .updateClient(needVip, widget.tableName);
                          }),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: !_showBottomNavigator
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                _showBottomNavigator = true;
                _inputFocus = true;

                setState(() {});
              },
            )
          : null,
      bottomNavigationBar: _showBottomNavigator //TODO need to double check
          ? WillPopScope(
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
                            _submitColor = (str == "")
                                ? Colors.grey
                                : Colors.deepOrangeAccent;
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
                          //enableFeedback: true,
                          icon: Icon(
                            Icons.send,
                            color:
                                _submitColor, //TODO change color when its not empty ,dont forgetto setState
                          ),
                          onPressed: _inputController == "" ? () {} : _addTask),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  void _addTask({String x}) async {
    if (_inputController.text != "") {
      Client x = Client(firstName: _inputController.text, blocked: false);
      await DBProvider.db.newClient(x, widget.tableName); //
      setState(() {
        _inputController.clear();
      });
    }
  }
}

Widget _simplePopup(String tableName, BuildContext context) =>
    PopupMenuButton<int>(
      color: MyColors.bg,
      icon: Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 1 && tableName != "Client" && tableName != "Tables__") {
          Navigator.pop(context);
          await DBProvider.db.removeTable(tableName);
          bloc.drawAdd(1);

          //TODO add sink streambuilder
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => MyScffold("Client")));
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Text(
            "Delete Project",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
