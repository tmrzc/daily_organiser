import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../main.dart';

// ------ DIALOG DISPLAYED FOR ADDING NEW TRACKERSS ------

class TrackerPopup extends StatefulWidget {
  const TrackerPopup({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  State<TrackerPopup> createState() => _TrackerPopup();
}

class _TrackerPopup extends State<TrackerPopup> {
  final _titlecontroller = TextEditingController();

  // KEY FOR VALIDATION OF THE FORM
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _titlecontroller.addListener(textChanger);
  }

  void textChanger() {
    setState(() {
      var temp = _titlecontroller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var cos = 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create a new tracker',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),

      // FORM FOR ENTERING NEW TRACKER DATA
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              headerText(widget: widget, header: 'Tracker preview'),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Card(
                  color: Color.fromARGB(255, 185, 255, 183),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _titlecontroller.text,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Icon(Icons.settings),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 20, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: cos,
                                divisions: 10,
                                min: 0,
                                max: 10,
                                //label: ,
                                onChanged: (newRating) {
                                  setState(() {
                                    cos = newRating;
                                  });
                                },
                              ),
                            ),
                            Icon(Icons.check),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              headerText(widget: widget, header: 'Title'),

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
                      labelText: 'Title of a new tracker',
                      suffixIcon: IconButton(
                        onPressed: () => _titlecontroller.clear(),
                        icon: const Icon(Icons.clear),
                      )),
                ),
              ),

              headerText(widget: widget, header: 'Type'),

              SingleChoice(),

              // SUBMIT BUTTON FOR SUBMITING NEW TO DO
              ElevatedButton(
                onPressed: () {
                  final isValidForm = formKey.currentState!.validate();

                  if (isValidForm) {
                    appState.addTracker(_titlecontroller.text, 5.0, 10);
                    _titlecontroller.clear();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class headerText extends StatelessWidget {
  headerText({
    super.key,
    required this.widget,
    required this.header,
  });

  final TrackerPopup widget;
  String header;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Text(
              header,
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w400),
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
    );
  }
}

enum trackerType { score, counter, hours }

class SingleChoice extends StatefulWidget {
  const SingleChoice({super.key});

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  trackerType calendarView = trackerType.score;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<trackerType>(
      segments: const <ButtonSegment<trackerType>>[
        ButtonSegment<trackerType>(
            value: trackerType.score,
            label: Text('Score'),
            icon: Icon(Icons.stars)),
        ButtonSegment<trackerType>(
            value: trackerType.counter,
            label: Text('Counter'),
            icon: Icon(Icons.plus_one_outlined)),
        ButtonSegment<trackerType>(
            value: trackerType.hours,
            label: Text('Hours'),
            icon: Icon(Icons.timer)),
      ],
      selected: <trackerType>{calendarView},
      onSelectionChanged: (Set<trackerType> newSelection) {
        setState(() {
          // By default there is only a single segment that can be
          // selected at one time, so its value is always the first
          // item in the selected set.
          calendarView = newSelection.first;
        });
      },
    );
  }
}
