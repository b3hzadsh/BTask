import 'package:flutter/material.dart';
import 'package:database/ClientModel.dart';
import 'package:database/Database.dart';
// import 'dart:math' as math;

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // data for testing
  /* List<Client> testClients = [
    Client(firstName: "Raouf", lastName: "Rahiche", blocked: false),
    Client(firstName: "Zaki", lastName: "oun", blocked: true),
    Client(firstName: "oussama", lastName: "ali", blocked: false),
  ]; */
  TextEditingController _inputController = new TextEditingController();
  bool _showBottomNavigator = false;
  bool _inputFocus = true;
  Color _submitColor = Colors.grey;
  // for task ui widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                          enableFeedback: true,
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
      appBar: AppBar(
        title: Text(
          "Inbox", //TODO must be the table name given from constructor
          style: TextStyle(
            color: Color.fromRGBO(230, 230, 235, 1.0),
          ),
        ),
        backgroundColor: Color.fromRGBO(30, 40, 50, 1.0),
      ),
      body: Container(
        color: Color.fromRGBO(37, 46, 56, 1.0),
        child: FutureBuilder<List<Client>>(
          future: DBProvider.db.getAllClients("Client"),
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
                      DBProvider.db.deleteClient(item.id, "Client");
                    },
                    child: ListTile(
                      title: Text(
                        item.firstName,
                        style:
                            TextStyle(color: Color.fromRGBO(173, 37, 46, 1.0)),
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
                              item.blocked = item.blocked == false;
                            });
                            Client needVip = Client(
                                id: item.id,
                                firstName: item.firstName,
                                blocked: true);
                            await DBProvider.db.updateClient(needVip, "Client");
                          }),
                    ),
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
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
    );
  }

  void _addTask({String x}) async {
    if (_inputController.text != "") {
      Client x = Client(firstName: _inputController.text, blocked: false);
      await DBProvider.db.newClient(x, "Client");
      setState(() {
        _inputController.clear();
      });
    }
  }
}
