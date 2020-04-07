import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:database/ClientModel.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TestDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      bool xBool = true;
      await db.execute("CREATE TABLE Client ("
          "id INTEGER PRIMARY KEY,"
          "first_name TEXT,"
          "blocked BIT"
          ")");
      await db.execute("CREATE TABLE Tables__ ("
          "id INTEGER PRIMARY KEY,"
          "first_name TEXT," // tablename
          "blocked BIT" //main project
          ")");
      /* await db.execute("""
           INSERT INTO Tables__ (id , first_name, blocked)
           VALUES (1,'Client' , 1);"""); */
      await db.rawInsert(
          "INSERT Into Tables__ (id,first_name,blocked)"
          " VALUES (?,?,?)",
          [1, "Client", xBool]);

      /* newClient(Client(blocked: false, firstName: "Client"), "Tables__");
      newClient(Client(blocked: true, firstName: "first task"), "Client"); */
    });
  }

  newClient(Client newClient, String tableName) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM $tableName");
    int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into $tableName (id,first_name,blocked)"
        " VALUES (?,?,?)",
        [id, newClient.firstName, newClient.blocked]);
    return raw;
  }

  blockOrUnblock(Client client, String tableName) async {
    final db = await database;
    Client blocked = Client(
        id: client.id,
        firstName: client.firstName,
        // lastName: client.lastName,
        blocked: !client.blocked);
    var res = await db.update(tableName, blocked.toMap(),
        where: "id = ?", whereArgs: [client.id]);
    return res;
  }

  updateClient(Client newClient, String tableName) async {
    final db = await database;
    var res = await db.update(tableName, newClient.toMap(),
        where: "id = ?", whereArgs: [newClient.id]);
    return res;
  }

  getClient(int id, String tableName) async {
    final db = await database;
    var res = await db.query(tableName, where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Client.fromMap(res.first) : null;
  }

  Future<List<Client>> getBlockedClients(String tableName) async {
    final db = await database;

    print("works");
    // var res = await db.rawQuery("SELECT * FROM Client WHERE blocked=1");
    var res = await db.query(tableName, where: "blocked = ? ", whereArgs: [1]);

    List<Client> list =
        res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Client>> getAllClients(String tableName) async {
    final db = await database;
    var res = await db.query(tableName);
    List<Client> list =
        res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
    return list;
  }

  deleteClient(int id, String tableName) async {
    final db = await database;
    return db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }

  deleteAll(String tableName) async {
    final db = await database;
    db.rawDelete("Delete  from $tableName", []);
  }

  addTable(String tableName) async {
    if (tableName != "Tables__") {
      final db = await database;
      await db.execute("CREATE TABLE $tableName ("
          "id INTEGER PRIMARY KEY,"
          "first_name TEXT,"
          "blocked BIT"
          ")");
      await newClient(Client(blocked: true, firstName: tableName), "Tables__");
    }
  }

  removeTable(String tableName) async {
    if (tableName != "Client" && tableName != "Tables__") {
      final db = await database;
      await db.execute("DROP TABLE IF EXISTS $tableName");
      return db
          .delete("Tables__", where: "first_name = ?", whereArgs: [tableName]);
    }
  }
}
