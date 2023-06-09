import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../provider.dart';
import 'package:daily_organiser/database/notemodel.dart';

// ------ DIALOG DISPLAYED FOR ADDING NEW TO-DO'S ------

enum PopupMode { create, edit }

class JournalPopup extends StatefulWidget {
  JournalPopup({
    required this.modeSelector,
    this.noteEdited,
    required this.theme,
  });

  PopupMode? modeSelector;
  Note? noteEdited;
  ThemeData theme;

  @override
  State<JournalPopup> createState() => _JournalPopup();
}

class _JournalPopup extends State<JournalPopup> {
  final _textcontroller = TextEditingController();

  // KEY FOR VALIDATION OF THE FORM
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.modeSelector == PopupMode.edit) {
      _textcontroller.text = widget.noteEdited!.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    DateTime time = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                final isValidForm = formKey.currentState!.validate();

                if (isValidForm) {
                  if (widget.modeSelector == PopupMode.edit) {
                    widget.noteEdited!.note = _textcontroller.text;
                    appState.editNote(widget.noteEdited!);
                  } else {
                    appState.saveNote(_textcontroller.text, time);
                  }

                  Navigator.of(context).pop();
                }
              },
              icon: Icon(Icons.save)),
          widget.modeSelector == PopupMode.edit
              ? IconButton(
                  onPressed: () {
                    deleteDialog(context, appState, widget.noteEdited!);
                  },
                  icon: Icon(Icons.delete))
              : Container(),
        ],
        title: Text(
          widget.modeSelector == PopupMode.edit
              ? '${widget.noteEdited!.year}/ ${widget.noteEdited!.month}/ ${widget.noteEdited!.day}'
              : 'NEW ENTRY',
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.modeSelector == PopupMode.edit
                ? <Widget>[
                    Expanded(
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: _textcontroller,
                        maxLines: null,
                        minLines: null,
                        expands: true,
                        decoration: InputDecoration(),
                        validator: (String? value) {
                          return (value == null)
                              ? 'NOTE CANNOT BE EMPTY'
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]
                : <Widget>[
                    Text('${time.year}/${time.month}/${time.day}'),
                    const SizedBox(height: 5),
                    Expanded(
                      child: TextFormField(
                        controller: _textcontroller,
                        maxLines: null,
                        minLines: null,
                        expands: true,
                        decoration: InputDecoration(),
                        validator: (String? value) {
                          return (value == null)
                              ? 'NOTE CANNOT BE EMPTY'
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> deleteDialog(
      BuildContext context, MyAppState appState, Note note) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text("Delete this note?"),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        appState.deleteNote(note);
                      });
                      Navigator.pop(context);
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
}
