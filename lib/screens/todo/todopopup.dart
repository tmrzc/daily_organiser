import 'package:daily_organiser/screens/todo/todoweekmanager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../provider.dart';
import 'package:daily_organiser/screens/tracker/trackerpopup.dart';
import 'package:daily_organiser/database/todoweeklymodel.dart';
import 'package:daily_organiser/screens/tracker/trackerscreen.dart';

// ------ DIALOG DISPLAYED FOR ADDING NEW TO-DO'S ------

enum TodoMode { simple, recursive }

enum WeekDays { MON, TUE, WED, THU, FR, SAT, SUN }

class TodoPopup extends StatefulWidget {
  TodoPopup({
    super.key,
    required this.theme,
    required this.isEditing,
    required this.isTodoManager,
    this.todoManager,
  });

  ThemeData theme;
  bool isEditing;
  bool isTodoManager;
  TodoManager? todoManager;

  @override
  State<TodoPopup> createState() => _TodoPopup();
}

class _TodoPopup extends State<TodoPopup> {
  int? _value = 0;
  TodoMode todoMode = TodoMode.simple;
  Set<WeekDays> weekDays = <WeekDays>{};
  final _titlecontroller = TextEditingController();

  // KEY FOR VALIDATION OF THE FORM
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      _titlecontroller.text = widget.todoManager!.title;
      weekDays = checkEnabledWeekDays(widget.todoManager!);
      todoMode = TodoMode.recursive;
    }

    if (widget.isTodoManager) {
      todoMode = TodoMode.recursive;
    }
  }

  Set<WeekDays> checkEnabledWeekDays(TodoManager todoManager) {
    Set<WeekDays> daysToEnable = {};

    if (todoManager.mon) daysToEnable.add(WeekDays.MON);
    if (todoManager.tue) daysToEnable.add(WeekDays.TUE);
    if (todoManager.wed) daysToEnable.add(WeekDays.WED);
    if (todoManager.thu) daysToEnable.add(WeekDays.THU);
    if (todoManager.fr) daysToEnable.add(WeekDays.FR);
    if (todoManager.sat) daysToEnable.add(WeekDays.SAT);
    if (todoManager.sun) daysToEnable.add(WeekDays.SUN);

    return daysToEnable;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CREATE A NEW TO DO',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      // FORM FOR ENTERING NEW TO DO DATA
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                HeaderText(widget: widget, header: 'TITLE'),

                TextFormField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  controller: _titlecontroller,
                  validator: (String? value) {
                    return (value != null && value.length < 1)
                        ? 'Title cannot be empty.'
                        : null;
                  },
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Title of a new to do',
                      suffixIcon: IconButton(
                        onPressed: () => _titlecontroller.clear(),
                        icon: const Icon(Icons.clear),
                      )),
                ),

                widget.isEditing
                    ? Container()
                    : widget.isTodoManager
                        ? Container()
                        : HeaderText(widget: widget, header: 'MODE'),

                widget.isEditing
                    ? Container()
                    : widget.isTodoManager
                        ? Container()
                        : SegmentedButton<TodoMode>(
                            showSelectedIcon: false,
                            segments: const <ButtonSegment<TodoMode>>[
                              ButtonSegment<TodoMode>(
                                value: TodoMode.simple,
                                label: Text('SIMPLE'),
                              ),
                              ButtonSegment<TodoMode>(
                                value: TodoMode.recursive,
                                label: Text('RECURSIVE'),
                              ),
                            ],
                            selected: <TodoMode>{todoMode},
                            onSelectionChanged: (Set<TodoMode> newSelection) {
                              setState(() {
                                todoMode = newSelection.first;
                              });
                            },
                          ),

                todoMode == TodoMode.simple
                    ? const SizedBox(height: 20)
                    : HeaderText(widget: widget, header: 'SELECT DAYS'),

                todoMode == TodoMode.simple
                    ? Container()
                    : Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        children: WeekDays.values.map((WeekDays weekDay) {
                          return FilterChip(
                            label: Text(weekDay.name),
                            selected: weekDays.contains(weekDay),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  weekDays.add(weekDay);
                                } else {
                                  weekDays.remove(weekDay);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                // SUBMIT BUTTON FOR SUBMITING NEW TO DO
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50)),
                  onPressed: () {
                    final isValidForm = formKey.currentState!.validate();

                    if (isValidForm) {
                      if (widget.isEditing) {
                        appState.deleteTodoManager(widget.todoManager!);
                        appState.deleteTodoFromManager(widget.todoManager!);
                        var todoManager = TodoManager(
                          mon: weekDays.contains(WeekDays.MON),
                          tue: weekDays.contains(WeekDays.TUE),
                          wed: weekDays.contains(WeekDays.WED),
                          thu: weekDays.contains(WeekDays.THU),
                          fr: weekDays.contains(WeekDays.FR),
                          sat: weekDays.contains(WeekDays.SAT),
                          sun: weekDays.contains(WeekDays.SUN),
                          title: _titlecontroller.text,
                        );
                        Future.wait([appState.addTodoManager(todoManager)])
                            .then((newTodoManager) {
                          appState.importTodoFromManager(newTodoManager[0]);
                          appState.importTodo();
                        });
                      } else {
                        if (todoMode == TodoMode.simple) {
                          appState.addTodo(_titlecontroller.text, false);
                        } else if (todoMode == TodoMode.recursive) {
                          var todoManager = TodoManager(
                            mon: weekDays.contains(WeekDays.MON),
                            tue: weekDays.contains(WeekDays.TUE),
                            wed: weekDays.contains(WeekDays.WED),
                            thu: weekDays.contains(WeekDays.THU),
                            fr: weekDays.contains(WeekDays.FR),
                            sat: weekDays.contains(WeekDays.SAT),
                            sun: weekDays.contains(WeekDays.SUN),
                            title: _titlecontroller.text,
                          );
                          Future.wait([appState.addTodoManager(todoManager)])
                              .then((newTodoManager) {
                            appState.importTodoFromManager(newTodoManager[0]);
                          });
                        }
                      }

                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
