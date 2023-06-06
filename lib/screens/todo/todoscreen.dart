import 'package:daily_organiser/database/todomodel.dart';
import 'package:daily_organiser/screens/todo/todoweekmanager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../provider.dart';
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
  late Todo tempTodo;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshTodos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var appState = context.watch<MyAppState>();
    if (!appState.isDailyChangeActive) {
      //setState(() => appState.isDailyChangeActive = true);
      appState.isDailyChangeActive = true;
      Provider.of<MyAppState>(context, listen: false)
          .dailyTrackerAndTodoCheck();
      appState.isDailyChangeActive = false;
    }

    //print('------------------CHANGE DEPENDENCIES------------------');
  }

  Future refreshTodos() async {
    setState(() => isLoading = true);

    Provider.of<MyAppState>(context, listen: false).importTodo();

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future loadTodos() async {
    setState(() => isLoading = true);

    var appState = context.watch<MyAppState>();
    appState.dailyTrackerAndTodoCheck();

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

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
      child: isLoading
          ? CustomScrollView(
              slivers: <Widget>[
                TodoTopBar(context),
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [CircularProgressIndicator()],
                    ),
                  ),
                )
              ],
            )
          : _TodoList.isEmpty && _doneList.isEmpty
              ? CustomScrollView(
                  slivers: <Widget>[
                    TodoTopBar(context),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "PRESS THE PLUS ICON TO ADD A TO-DO",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              : CustomScrollView(
                  slivers: <Widget>[
                    // APP BAR WITH TITLE OF A SCREEN
                    TodoTopBar(context),

                    // TASKS TO DO PART OF THE LIST
                    _TodoList.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                child: Text(
                                  "PRESS THE PLUS ICON TO ADD A TO-DO",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          )
                        : tasksLists(_TodoList, appState, _doneList, false),

                    _doneList.isEmpty
                        ? const SliverToBoxAdapter()
                        : dividerWithButton(appState, _doneList),

                    // DONE TASKS PART OF THE LIST
                    _doneList.isEmpty
                        ? SliverToBoxAdapter()
                        : tasksLists(
                            _doneList, appState, _TodoList, true, getColor),
                  ],
                ),
    );
  }

  // ------APP BAR WITH TITLE OF A SCREEN------
  SliverAppBar TodoTopBar(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return SliverAppBar.medium(
      pinned: true,
      actions: [
        /*IconButton(
          onPressed: () {
            appState.changeTodayTimeBackwards10days();
          },
          icon: Icon(
            Icons.circle_outlined,
            size: 40,
          ),
        ),*/
        IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TodoManagerScreen(
                      theme: widget.theme,
                    ),
                  ));
            },
            icon: const Icon(Icons.checklist_rounded)),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TodoPopup(
                    isTodoManager: false,
                    theme: widget.theme,
                    isEditing: false,
                  ),
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
        title: Transform(
          transform: Matrix4.translationValues(-30.0, 0.0, 0.0),
          child: Text(
            "TO DO:",
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: widget.theme.colorScheme.onBackground,
            ),
          ),
        ),
        background: Container(color: widget.theme.colorScheme.background),
      ),
    );
  }

  // ------TASKS LISTS WIDGET FOR BOTH LISTS------
  SliverList tasksLists(
      List<Todo> list1, MyAppState appState, List<Todo> list2, bool isDone,
      [Color getColor(Set<MaterialState> states)?]) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Dismissible(
            key: ValueKey(list1[index]),
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
                '${list1[index].value}',
                style: isDone
                    ? TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: widget.theme.disabledColor,
                      )
                    : list1[index].manager_id != null
                        ? TextStyle(
                            fontStyle: FontStyle.italic,
                            color: widget.theme.primaryColor)
                        : const TextStyle(),
              ),
              leading: isDone
                  ? Checkbox(
                      fillColor: MaterialStateProperty.resolveWith(getColor!),
                      value: list1[index].isDone,
                      onChanged: (bool? value) {
                        setState(() {
                          list1[index].isDone = value!;
                          appState.switchListsTodo(
                              list1, list2, list1[index], index);
                        });
                      },
                    )
                  : Checkbox(
                      value: list1[index].isDone,
                      onChanged: (bool? value) {
                        setState(() {
                          list1[index].isDone = value!;
                          appState.switchListsTodo(
                              list1, list2, list1[index], index);
                        });
                      },
                    ),
            ),
            onDismissed: (DismissDirection direction) {
              appState.db.deleteTodo(list1[index]);
              setState(() {
                tempTodo = list1[index];
                list1.removeAt(index);
              });
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                snackBarTodo(appState, isDone),
              );
            },
          );
        },
        childCount: list1.length,
      ),
    );
  }

  SnackBar snackBarTodo(MyAppState appState, bool isDone) {
    return SnackBar(
      duration: Duration(milliseconds: 2500),
      content: const Text(
        'REVERSE CHANGES?',
        textAlign: TextAlign.center,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      action: SnackBarAction(
          label: 'YES',
          onPressed: () {
            appState.addTodo(tempTodo.value, isDone);
          }),
      showCloseIcon: true,
    );
  }

  // ------ DIVIDER WITH BUTTON FOR DELETING DONE TASKS ------
  SliverList dividerWithButton(MyAppState appState, List<dynamic> _doneList) {
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
                onLongPress: () {
                  setState(() {
                    appState.clearlist();
                  });
                },
                onPressed: () {},
                child: Text(
                  'HOLD TO CLEAR DONE TASKS',
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
