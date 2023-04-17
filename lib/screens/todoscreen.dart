import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../main.dart';

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
  @override
  Widget build(BuildContext context) {
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

    return CustomScrollView(
      slivers: <Widget>[
        // APP BAR WITH TITLE OF A SCREEN
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

        // TASKS TO DO PART OF THE LIST
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Column(
                children: [
                  Dismissible(
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
                      title: Text('${_TodoList[index][1]['title']}'),
                      leading: Checkbox(
                        value: _TodoList[index][0],
                        onChanged: (bool? value) {
                          setState(() {
                            _TodoList[index][0] = value!;
                            Timer(Duration(milliseconds: 1000), () {});
                            appState.switchListsTodo(
                              _TodoList,
                              _doneList,
                              _TodoList[index],
                              index,
                            );
                            //print(appState.TodoList);
                            //print(appState.DoneList);
                          });
                        },
                      ),
                    ),
                    onDismissed: (DismissDirection direction) {
                      setState(() {
                        _TodoList.removeAt(index);
                      });
                    },
                  ),
                  const Divider(
                    height: 0,
                    indent: 20,
                    endIndent: 20,
                  ),
                ],
              );
            },
            childCount: _TodoList.length,
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const Divider(),
          ]),
        ),

        // DONE TASKS PART OF THE LIST
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Column(
                children: [
                  Dismissible(
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
                        '${_doneList[index][1]['title']}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      leading: Checkbox(
                        fillColor: MaterialStateProperty.resolveWith(getColor),
                        value: _doneList[index][0],
                        onChanged: (bool? value) {
                          setState(() {
                            _doneList[index][0] = value!;
                            Timer(Duration(milliseconds: 1000), () {});
                            appState.switchListsTodo(
                              _doneList,
                              _TodoList,
                              _doneList[index],
                              index,
                            );
                            //print(appState.TodoList);
                            //print(appState.DoneList);
                          });
                        },
                      ),
                    ),
                    onDismissed: (DismissDirection direction) {
                      setState(() {
                        _doneList.removeAt(index);
                      });
                    },
                  ),
                  const Divider(
                    height: 0,
                    indent: 20,
                    endIndent: 20,
                  ),
                ],
              );
            },
            childCount: _doneList.length,
          ),
        ),
      ],
    );
  }
}

// ------ DIALOG DISPLAYED FOR ADDING NEW TO-DO'S ------

class NewTodoPopup extends StatefulWidget {
  const NewTodoPopup({
    super.key,
  });

  @override
  State<NewTodoPopup> createState() => _NewTodoPopupState();
}

class _NewTodoPopupState extends State<NewTodoPopup> {
  final _titlecontroller = TextEditingController();

  // KEY FOR VALIDATION OF THE FORM
  final formKey = GlobalKey<FormState>();

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

            // FORM FOR ENTERING NEW TO DO DATA
            body: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: TextFormField(
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
                  ),
                  const SizedBox(height: 20),

                  // SUBMIT BUTTON FOR SUBMITING NEW TO DO
                  ElevatedButton(
                    onPressed: () {
                      final isValidForm = formKey.currentState!.validate();

                      if (isValidForm) {
                        appState.addTodo(_titlecontroller.text);
                        _titlecontroller.clear();
                        Navigator.of(context).pop();
                        //print(appState.TodoList);
                        //print(appState.DoneList);
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
