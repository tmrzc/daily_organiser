import 'package:daily_organiser/screens/statsscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/todo/todoscreen.dart';
import 'screens/tracker/trackerscreen.dart';
import 'provider.dart';

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
