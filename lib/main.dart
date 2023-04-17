import 'package:daily_organiser/screens/statsscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'screens/todoscreen.dart';
import 'screens/trackerscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Organise',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 147, 166, 144)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// ------ CHANGE NOTIFIER ------

class MyAppState extends ChangeNotifier {
  late List TodoList = [
    [
      false,
      {'title': 'Wyprowadzić psa'}
    ],
    [
      false,
      {'title': 'Rozładować zmywarkę'}
    ],
    [
      false,
      {'title': 'Wynieść śmieci'}
    ],
    [
      false,
      {'title': 'Posprzątać pokój'}
    ],
    [
      false,
      {'title': 'Zrobić obiad'}
    ],
    [
      false,
      {'title': 'Pójść na siłownię'}
    ]
  ];
  late List DoneList = [];

  List trackerColors = [
    Color.fromARGB(255, 147, 166, 144),
    Color.fromARGB(255, 179, 203, 255),
    Color.fromARGB(255, 221, 231, 166),
    Color.fromARGB(255, 233, 178, 175),
    Color.fromARGB(255, 213, 181, 223),
    Color.fromARGB(255, 223, 186, 138),
    Color.fromARGB(255, 226, 138, 253)
  ];

  List trackers = [
    {
      'title': 'Sleep',
      'rating': 0.0,
      'rangeMax': 10,
      'color': Color.fromARGB(255, 241, 175, 171)
    },
    {
      'title': 'Workouts',
      'rating': 0.0,
      'rangeMax': 100,
      'color': Color.fromARGB(255, 169, 216, 171)
    },
    {
      'title': 'Productivity',
      'rating': 0.0,
      'rangeMax': 30,
      'color': Color.fromARGB(255, 177, 202, 223)
    }
  ];

  void addTracker(String title, double rating, int rangeMax) {
    Map tracker = {'title': title, 'rating': rating, 'rangeMax': rangeMax};
    trackers.add(tracker);

    notifyListeners();
  }

  // CREATING NEW TO-DO LIST ELEMENTS
  void addTodo(var title) {
    List TodoCard = [];
    Map SingleTodo = {};

    SingleTodo['title'] = title;
    TodoCard.add(false);
    TodoCard.add(SingleTodo);
    TodoList.insert(0, TodoCard);

    notifyListeners();
  }

  // FINISHING A TASK AND DELETING IT FROM TO DO'S
  void switchListsTodo(List fromList, List toList, var switchingTask, int idx) {
    //toList.insert(0, switchingTask);
    toList.add(switchingTask);
    fromList.removeAt(idx);

    notifyListeners();
  }

  void clearlist(var listtoclear) {
    listtoclear.clear();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// ------ MAIN SCREEN WITH NAVIGATION BAR ------

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
