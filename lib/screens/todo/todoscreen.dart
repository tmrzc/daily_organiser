import 'package:daily_organiser/database/databaseusage.dart';
import 'package:daily_organiser/database/todomodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../main.dart';
import 'todopopup.dart';

// ------ TO-DO LIST SCREEN DISPLAYING THE LIST ------

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
  late List<Todo> todos = [];
  late List<Todo> donetodos = [];
  bool isLoading = false;

  /*@override
  void initState() {
    super.initState();

    refreshTodos();
  }*/

  /*@override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    refreshTodos();
  }

  Future<void> refreshTodos() async {
    var appState = context.watch<MyAppState>();
    setState(() => isLoading = true);

    appState.TodoList = await OrganiserDatabase.instance.readTodos(false);
    appState.DoneList = await OrganiserDatabase.instance.readTodos(true);

    setState(() => isLoading = false);
  }*/

  @override
  Widget build(BuildContext context) {
    // FUNCTION FOR CHANGING COLOR OF CHECKED CHECKBOXES
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return widget.theme.primaryColorLight;
      }
      return widget.theme.disabledColor;
    }

    var appState = context.watch<MyAppState>();
    var _TodoList = appState.TodoList;
    var _doneList = appState.DoneList;

    return Center(
      child: CustomScrollView(
        slivers: <Widget>[
          // APP BAR WITH TITLE OF A SCREEN
          SliverAppBar.medium(
            pinned: true,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TodoPopup(),
                      ));
                },
                icon: Icon(
                  Icons.add,
                  size: 40,
                ),
              )
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

          // TASKS TO DO PART OF THE LIST
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Dismissible(
                  key: ValueKey(_TodoList[index]),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: const Color.fromARGB(255, 252, 161, 154),
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Icon(Icons.delete_outline),
                    ),
                  ),
                  child: ListTile(
                    title: Text(_TodoList[index].value),
                    leading: Checkbox(
                      value: _TodoList[index].isDone,
                      onChanged: (bool? value) {
                        setState(() {
                          _TodoList[index].isDone = value!;
                          Timer(const Duration(milliseconds: 200), () {
                            appState.switchListsTodo(
                                _TodoList, _doneList, _TodoList[index], index);
                          });
                        });
                      },
                    ),
                  ),
                  onDismissed: (DismissDirection direction) {
                    setState(() {
                      appState.db.deleteTodo(_TodoList[index]);
                      _TodoList.removeAt(index);
                    });
                  },
                );
              },
              childCount: _TodoList.length,
            ),
          ),

          dividerWithButton(appState),

          // DONE TASKS PART OF THE LIST
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Dismissible(
                  key: ValueKey(_doneList[index]),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: const Color.fromARGB(255, 252, 161, 154),
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Icon(Icons.delete_outline),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      _doneList[index].value,
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: widget.theme.disabledColor,
                      ),
                    ),
                    leading: Checkbox(
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: _doneList[index].isDone,
                      onChanged: (bool? value) {
                        setState(() {
                          _doneList[index].isDone = value!;
                          Timer(const Duration(milliseconds: 200), () {
                            appState.switchListsTodo(
                                _doneList, _TodoList, _doneList[index], index);
                          });
                        });
                      },
                    ),
                  ),
                  onDismissed: (DismissDirection direction) {
                    setState(() {
                      appState.db.deleteTodo(_doneList[index]);
                      _doneList.removeAt(index);
                    });
                  },
                );
              },
              childCount: _doneList.length,
            ),
          ),
        ],
      ),
    );
  }

  // ------ DIVIDER WITH BUTTON FOR DELETING DONE TASKS ------
  SliverList dividerWithButton(MyAppState appState) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 1,
                  width: 40,
                  color: widget.theme.disabledColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    appState.clearlist();
                  });
                },
                child: Text(
                  'Clear all done tasks',
                  style: TextStyle(
                    color: widget.theme.disabledColor,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  width: 40,
                  color: widget.theme.disabledColor,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
