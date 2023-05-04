import 'package:daily_organiser/database/databaseusage.dart';
import 'package:daily_organiser/database/todomodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../main.dart';

// ------ DIALOG DISPLAYED FOR ADDING NEW TO-DO'S ------

class TodoPopup extends StatefulWidget {
  @override
  State<TodoPopup> createState() => _TodoPopup();
}

class _TodoPopup extends State<TodoPopup> {
  final _titlecontroller = TextEditingController();

  // KEY FOR VALIDATION OF THE FORM
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
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
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
