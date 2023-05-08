import 'package:flutter/material.dart';
import 'main.dart';
import 'database/databaseusage.dart';
import 'database/todomodel.dart';

// ------ CHANGE NOTIFIER ------

class MyAppState extends ChangeNotifier {
  /*MyAppState() {
    importTodo();
  }*/

  late List<Todo> TodoList = [];
  late List<Todo> DoneList = [];
  var db = OrganiserDatabase.instance;

  void importTodo() async {
    TodoList = await db.readTodos(false);
    DoneList = await db.readTodos(true);
    notifyListeners();
  }

  // CREATING NEW TO-DO LIST ELEMENTS
  Future<void> addTodo(var title) async {
    var newTodo = Todo(value: title, isDone: false);
    await db.create(newTodo);
    TodoList.insert(0, newTodo);

    notifyListeners();
  }

  // FINISHING A TASK AND DELETING IT FROM TO DO'S
  void switchListsTodo(
      List<Todo> fromList, List<Todo> toList, Todo task, int idx) {
    //task.isDone = !task.isDone;
    toList.insert(0, fromList[idx]);
    fromList.removeAt(idx);
    db.updateTodo(task);

    notifyListeners();
  }

  void clearlist() {
    db.deleteDoneTodo();
    DoneList.clear();
    notifyListeners();
  }

  List trackers = [];

  void addTracker(String title, TrackerType type, int colorId,
      [int rangeMax = 10]) {
    Map tracker = {
      'type': type,
      'title': title,
      'rangeMax': rangeMax,
      'state': TrackerState.enabled,
      'color_id': colorId,
    };
    trackers.add(tracker);

    notifyListeners();
  }

  void saveValueToTracker(Map tracker, double value) {
    tracker['value'] = value;
    tracker['state'] = TrackerState.disabled;

    notifyListeners();
  }

  void enableTracker(Map tracker) {
    tracker['state'] = TrackerState.enabled;

    notifyListeners();
  }

  void removeTracker(int index) {
    trackers.removeAt(index);

    notifyListeners();
  }
}
