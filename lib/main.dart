import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatefulWidget {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    var theme = Theme.of(context);
    var style = theme.textTheme.headlineMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

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
            icon: Icon(Icons.check_box_outlined),
            label: 'To do',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_alt),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.line_axis_outlined),
            label: 'Stats',
          ),
        ],
      ),
      body: <Widget>[
        CustomScrollView(
          slivers: <Widget>[
            SliverAppBar.medium(
              pinned: true,
              actions: [
                NewTodoPopup(),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                title: Text(
                  "To do:",
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                background: Container(color: theme.colorScheme.background),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Container(
                    color: index.isOdd ? Colors.white : Colors.black12,
                    height: 100.0,
                    child: Center(
                      child: Text('$index', textScaleFactor: 5),
                    ),
                  );
                },
                childCount: 20,
              ),
            ),
          ],
        ),
        Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: const Text('Page 2'),
        ),
        Container(
          color: Colors.blue,
          alignment: Alignment.center,
          child: const Text('Page 3'),
        ),
      ][currentPageIndex],
    );
  }
}

class NewTodoPopup extends StatelessWidget {
  const NewTodoPopup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.add,
        size: 40,
      ),
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => Dialog.fullscreen(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('This is a fullscreen dialog.'),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}