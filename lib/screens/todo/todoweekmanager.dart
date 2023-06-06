import 'package:daily_organiser/database/databaseusage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../provider.dart';
import 'package:daily_organiser/database/todoweeklymodel.dart';
import 'todopopup.dart';

// ------ DIALOG DISPLAYED FOR ADDING NEW TO-DO'S ------

enum ManagerActionItem { edit, delete }

class TodoManagerScreen extends StatefulWidget {
  TodoManagerScreen({
    super.key,
    required this.theme,
  });

  ThemeData theme;

  @override
  State<TodoManagerScreen> createState() => _TodoManagerScreen();
}

class _TodoManagerScreen extends State<TodoManagerScreen> {
  bool isLoading = false;
  List<TodoManager> todoManagers = [];
  ManagerActionItem? actionSelector;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadTodoManagers();
  }

  Future loadTodoManagers() async {
    setState(() => isLoading = true);

    todoManagers = await OrganiserDatabase.instance.readTodoManagers();

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // KEY FOR VALIDATION OF THE FORM
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "RECURSIVE TO-DO'S",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TodoPopup(
                      isTodoManager: true,
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
        centerTitle: true,
      ),

      // FORM FOR ENTERING NEW TO DO DATA
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: todoManagers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      todoManagers[index].title,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: widget.theme.primaryColor,
                      ),
                    ),
                    subtitle: daysEnabledSubtitle(todoManagers[index]),
                    trailing: PopupMenuButton<ManagerActionItem>(
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<ManagerActionItem>>[
                        PopupMenuItem<ManagerActionItem>(
                          value: ManagerActionItem.edit,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Icon(Icons.edit),
                              Expanded(
                                  child: Text(
                                'EDIT',
                                textAlign: TextAlign.right,
                              ))
                            ],
                          ),
                        ),
                        PopupMenuItem<ManagerActionItem>(
                          value: ManagerActionItem.delete,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Icon(Icons.delete),
                              Expanded(
                                  child: Text(
                                'DELETE',
                                textAlign: TextAlign.right,
                              ))
                            ],
                          ),
                        ),
                      ],
                      onSelected: (ManagerActionItem item) {
                        switch (item) {
                          case ManagerActionItem.edit:
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TodoPopup(
                                    theme: widget.theme,
                                    isTodoManager: false,
                                    isEditing: true,
                                    todoManager: todoManagers[index],
                                  ),
                                ));
                            break;
                          case ManagerActionItem.delete:
                            deleteDialog(
                                context, appState, todoManagers[index]);
                            break;
                          default:
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> deleteDialog(
      BuildContext context, MyAppState appState, TodoManager todoManager) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text("Delete this recursive TO-DO?"),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        appState.deleteTodoManager(todoManager);
                        appState.deleteTodoFromManager(todoManager);
                        appState.importTodo();
                      });
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text('Yes'),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => widget.theme.shadowColor),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text(
                        'No',
                        style: TextStyle(
                          color: MaterialStateColor.resolveWith(
                              (states) => widget.theme.backgroundColor),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  Text daysEnabledSubtitle(TodoManager todoManager) {
    String textOfDays = '';
    List<String> enabledDays = [];

    List<Map> weekDays = [
      {'isEnabled': todoManager.mon, 'name': 'MON'},
      {'isEnabled': todoManager.tue, 'name': 'TUE'},
      {'isEnabled': todoManager.wed, 'name': 'WED'},
      {'isEnabled': todoManager.thu, 'name': 'THU'},
      {'isEnabled': todoManager.fr, 'name': 'FR'},
      {'isEnabled': todoManager.sat, 'name': 'SAT'},
      {'isEnabled': todoManager.sun, 'name': 'SUN'}
    ];

    for (int i = 0; i < weekDays.length; i++) {
      if (weekDays[i]['isEnabled']) {
        enabledDays.add(weekDays[i]['name']);
      }
    }

    textOfDays = '${enabledDays[0]}';

    for (int j = 1; j < enabledDays.length; j++) {
      textOfDays = '$textOfDays-${enabledDays[j]}';
    }

    return Text(textOfDays);
  }
}
