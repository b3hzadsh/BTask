import 'dart:async';

class Bloc {
  //static Bloc bloc;
  StreamController _drawerCtl = new StreamController.broadcast();

  Stream get draw => _drawerCtl.stream;
  get drawAdd => _drawerCtl.sink.add;

  void dispose() {
    _drawerCtl.close();
  }
}

Bloc bloc = new Bloc();
