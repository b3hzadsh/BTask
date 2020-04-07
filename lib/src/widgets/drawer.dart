import 'package:database/Database.dart';
import 'package:database/src/utils/bloc/bloc.dart';
import 'package:database/src/utils/colors.dart';
import 'package:database/src/widgets/my_scaffold.dart';
import 'package:flutter/material.dart';

import '../../ClientModel.dart';
import 'my_scaffold_widgets.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  var x = DBProvider.db.getAllClients("Tables__");
  TextEditingController dialogeTextCtl = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: MyColors.bg,
        child: Column(
          children: <Widget>[
            Expanded(
              child: myStream(
                bloc.draw,
                ListView(
                  children: <Widget>[
                    myDrawerHeader(),
                    FutureBuilder<List<Client>>(
                      future: x,
                      builder: (context,
                          AsyncSnapshot<List<Client>> futureSnapshot) {
                        return futureSnapshot.hasData
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemBuilder: (context, int index) {
                                  return item(
                                      futureSnapshot.data[index].firstName);
                                },
                                itemCount: futureSnapshot.data.length,
                              )
                            : Container(
                                margin: EdgeInsets.only(top: 20.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                      },
                    ),
                  ],
                  // add a add btn to add project bottom of list view call addTable
                ),
              ),
            ),
            Divider(
              thickness: 0.5,
              color: MyColors.red,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          child: new AlertDialog(
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () async {
                                    var tables = await x;
                                    var existTables =
                                        List.generate(tables.length, (i) {
                                      return tables[i].firstName;
                                    });
                                    if (dialogeTextCtl.text != "" &&
                                        !(existTables
                                            .contains(dialogeTextCtl.text))) {
                                      await DBProvider.db
                                          .addTable(dialogeTextCtl.text);
                                      setState(() {
                                        bloc.drawAdd(1);
                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (contex) => MyScffold(
                                                    dialogeTextCtl.text)));
                                      });
                                    } else {
                                      Scaffold.of(context)
                                          .showSnackBar(mySnackBar);
                                    }
                                  },
                                  child: Text("OK"))
                            ],
                            title: new Text("Please enter project name"),
                            content: new TextField(
                              key:
                                  UniqueKey(), // TODO please dont make any problem bro
                              controller: dialogeTextCtl, // Here
                            ), //TODO show dialoge and get name and add table .
                          ));
                    },
                    child: Text(
                      "Add Project",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget addProjectBtn() {
    return Text("data");
  }

  Widget item(String name) {
    var dropdownValue = "Delete";
    return Column(
      children: <Widget>[
        ListTile(
          // add trailing more icon to option to remove proj
          /* trailing: DropdownButton<String>(
            //TODO one of this can make me happy !
            isDense: false,
            isExpanded: false,
            value: dropdownValue,
            icon: Icon(Icons.more_vert),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String newValue) {
              setState(() async {
                if (newValue == "Delete") {
                  await DBProvider.db.removeTable(name);
                  setState(() {});

                  //TODO remove that table . remove from Tables__
                }
              });
            },
            items: <String>['Delete', 'change']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ), */
          title: Text(
            name,
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MyScffold(name)));
          },
          leading: Icon(
            Icons.crop_square,
            color: MyColors.red,
          ),
        ),
        Divider(
          thickness: 0.1,
          color: Colors.white,
        )
      ],
    );
  }

  Widget myDrawerHeader() {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage("assets/images/drawer_header.jpg"),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            child: Text(
              "B-Task",
              style: TextStyle(color: Colors.white),
            ),
            bottom: 5.0,
            left: 10.0,
          ),
        ],
      ),
    );
  }
}

Widget myStream(Stream x, Widget child) {
  return StreamBuilder(
    stream: x,
    builder: (context, snapshot) {
      return child;
    },
  );
}
