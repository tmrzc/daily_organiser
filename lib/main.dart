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

class MyAppState extends ChangeNotifier {
  List TodoList = [];
  List Checkboxes = [];
  bool cos = false;

  void addTodo(var title) {
    Map SingleTodo = {};
    SingleTodo['title'] = title;
    TodoList.add(SingleTodo);
    Checkboxes.add(cos);
    notifyListeners();
  }
}

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
        TodoListScreen(theme: theme),
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

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var _TodoList = appState.TodoList;

    return CustomScrollView(
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
                color: widget.theme.colorScheme.onBackground,
              ),
            ),
            background: Container(color: widget.theme.colorScheme.background),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Dismissible(
                key: ValueKey(_TodoList[index]),
                child: ListTile(
                  title: Text('${_TodoList[index]['title']}'),
                  leading: Checkbox(
                    value: appState.Checkboxes[index],
                    onChanged: (bool? value) {
                      setState(() {
                        appState.Checkboxes[index] = value!;
                      });
                    },
                  ),
                ),
                onDismissed: (DismissDirection direction) {
                  setState(() {
                    _TodoList.removeAt(index);
                    appState.Checkboxes.removeAt(index);
                  });
                },
              );
            },
            childCount: _TodoList.length,
          ),
        ),
      ],
    );
  }
}

class NewTodoPopup extends StatefulWidget {
  const NewTodoPopup({
    super.key,
  });

  @override
  State<NewTodoPopup> createState() => _NewTodoPopupState();
}

class _NewTodoPopupState extends State<NewTodoPopup> {
  final _titlecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return IconButton(
      icon: const Icon(
        Icons.add,
        size: 40,
      ),
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Create a new to do',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              centerTitle: true,
            ),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextField(
                    controller: _titlecontroller,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Title of a new to do',
                        suffixIcon: IconButton(
                          onPressed: () => _titlecontroller.clear(),
                          icon: const Icon(Icons.clear),
                        )),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    appState.addTodo(_titlecontroller.text);
                    _titlecontroller.clear();
                    Navigator.of(context).pop();
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
