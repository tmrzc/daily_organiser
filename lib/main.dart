import 'package:daily_organiser/screens/statsscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/todo/todoscreen.dart';
import 'screens/tracker/trackerscreen.dart';
import 'database/databaseusage.dart';
import 'database/todomodel.dart';
import 'screens/todo/todoscreen.dart';

void main() {
  runApp(const MyApp());
}

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme:
      ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 147, 166, 144)),
);

List trackerColors = [
  {'name': 'DEFAULT', 'theme': appTheme.colorScheme.background},
  {'name': 'RED', 'theme': Color.fromARGB(255, 252, 191, 219)},
  {'name': 'BLUE', 'theme': Color.fromARGB(255, 196, 231, 248)},
  {'name': 'MINT', 'theme': const Color.fromARGB(255, 211, 248, 226)},
  {'name': 'VIOLET', 'theme': const Color.fromARGB(255, 228, 193, 249)},
  {'name': 'YELLOW', 'theme': const Color.fromARGB(255, 237, 231, 177)},
];

enum TrackerState { enabled, disabled }

// ENUM FOR SELECTING TYPE OF TRACKER TO ADD
enum TrackerType { score, stars, counter, hours }

// ------- ROOT OF APLICATION ------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Organise',
        theme: appTheme,
        home: MyHomePage(),
      ),
    );
  }
}

// ------ CHANGE NOTIFIER ------

class MyAppState extends ChangeNotifier {
  MyAppState() {
    importTodo();
  }

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
  Future<void> switchListsTodo(
      List<Todo> fromList, List<Todo> toList, Todo task, int idx) async {
    //task.isDone = !task.isDone;
    toList.insert(0, fromList[idx]);
    fromList.removeAt(idx);
    await db.updateTodo(task);

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

// ------ MAIN SCREEN WITH NAVIGATION BAR ------

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'To do',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_alt),
            label: 'Tracker',
          ),
          NavigationDestination(
            icon: Icon(Icons.line_axis_outlined),
            label: 'Stats',
          ),
        ],
      ),
      body: <Widget>[
        TodoListScreen(theme: theme),
        TrackerScreen(theme: theme),
        StatisticsScreen(theme: theme),
      ][currentPageIndex],
    );
  }
}
