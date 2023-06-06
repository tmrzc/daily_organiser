import 'package:daily_organiser/screens/stats/statsscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/todo/todoscreen.dart';
import 'screens/tracker/trackerscreen.dart';
import 'screens/journal/journalscreen.dart';
import 'provider.dart';

void main() {
  runApp(const MyApp());
}

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme:
      ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 147, 166, 144)),
);

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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  var currentPageIndex = 0;
  late bool isLoading;
  late bool isLoading3;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        Provider.of<MyAppState>(context, listen: false)
            .dailyTrackerAndTodoCheck();
        break;
      default:
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

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
            label: 'TO DO',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_alt),
            label: 'TRACKERS',
          ),
          /*NavigationDestination(
            icon: Icon(Icons.line_axis_outlined),
            label: 'STATS',
          ),*/
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            label: 'JOURNAL',
          ),
        ],
      ),
      body: <Widget>[
        TodoListScreen(theme: theme),
        TrackerScreen(theme: theme),
        //StatisticsScreen(theme: theme),
        JournalScreen(theme: theme),
      ][currentPageIndex],
    );
  }
}
