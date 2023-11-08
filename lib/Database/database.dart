import 'package:hive_flutter/hive_flutter.dart';

class ToDoDatabase {
  List toDoList = [];
  //reference the hive box
  final _myBox = Hive.box("mybox");

  //run this method if its the first time opening this app
  void createInitialData() {
    toDoList = [
      ["Do Homework", false],
      ["Take Medicine", false],
    ];
  }

  //load data from database
  void loadData() {
    toDoList = _myBox.get("mybox");
  }

//update the database
  void updateDataBase() {
    _myBox.put("mybox", toDoList);
  }
}
