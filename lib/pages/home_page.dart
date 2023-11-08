import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/Database/database.dart';
import 'package:todo_app/components/dialog_box.dart';
import '../components/todo_tile.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //reference the hive box
  final _myBox = Hive.box("mybox");
  ToDoDatabase db = ToDoDatabase();
  //this list will store the filtered result
  List _searched = [];

  TextEditingController searchTextController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    // check whether there's any existing data in the Hive box if no data create initial data else load data
    if (_myBox.get("mybox") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    // update the searched list to the entire to-do list
    setState(() {
      _searched = db.toDoList;
    });
    super.initState();
  }

  void filter(String enteredText) {
    List result = [];
    if (enteredText.isEmpty) {
      // If it's empty, the _searched list is set to the entire to-do list
      result = db.toDoList;
    } else {
      result = db.toDoList
          .where((element) => element[0].toLowerCase().contains(enteredText
              .toLowerCase())) // Filter the list based on the entered text
          .toList();
    } //if there's input, it filters the toDoList It checks if the first element of each to-do item which is taskName contains the entered text.
    setState(() {
      _searched = result;
    });
  }

  //checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDataBase();
  }

  //text controller
  final _controller = TextEditingController();

//save new tasks
  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    db.updateDataBase();

    Navigator.of(context).pop();
  }

  deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          cancel: () {
            Navigator.of(context).pop();
          },
          save: saveNewTask,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(
              Icons.menu,
              color: Colors.black,
              size: 30,
            ),
          ],
        ),
        backgroundColor: const Color.fromRGBO(237, 237, 245, 1.0),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: searchTextController,
                onChanged: (value) {
                  filter(value);
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(0),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                    size: 20,
                  ),
                  prefixIconConstraints:
                      BoxConstraints(maxHeight: 20, minWidth: 25),
                  border: InputBorder.none,
                  hintText: "Search",
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 40, bottom: 10),
              child: const Text("Todo List",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searched.length,
                itemBuilder: (context, index) {
                  return TodoTile(
                    deleteFunction: (value) => deleteTask(index),
                    taskName: _searched[index][0],
                    taskCompleted: _searched[index][1],
                    onChanged: (value) => checkBoxChanged(value, index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
