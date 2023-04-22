import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import 'trackercard.dart';

// ------ SCREEN DISPLAYED FOR CRATING NEW TRACKERS ------

// ENUM FOR SELECTING TYPE OF TRACKER TO ADD
enum TrackerType { score, stars, counter, hours }

// ------ CLASS FOR THE NEW TRACKER SCREEN ------
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
  // TEXTEDITINGCONTROLLERS FOR TRACKER CREATOR INPUT FIELDS
  final _titlecontroller = TextEditingController();
  final counterController = TextEditingController();

  // KEY FOR VALIDATION OF THE FORM
  final formKey = GlobalKey<FormState>();

  // TEMPORARY VALUE FOR LABEL FOR SLIDER TRACKER
  var cos = 0.0;

  // VARIABLE FOR SWITCHING BETWEEN TYPES
  TrackerType trackerView = TrackerType.score;

  @override
  void initState() {
    super.initState();

    counterController.text = '0';
    _titlecontroller.text = 'Title...';
    _titlecontroller.addListener(textChanger);
    counterController.addListener(counterChanger);
  }

  // AUTO UPDATING TEXT FOR THE PREVIEW
  void textChanger() {
    setState(() {
      var temp = _titlecontroller.text;
    });
  }

  // AUTO CHECKING IF COUNTER IS NULL FOR THE PREVIEW
  void counterChanger() {
    setState(() {
      var temp = counterController.text;
    });
  }

  // PANEL FOR CHOOSING TYPE OF CREATED TRACKER
  Column choosingType() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: SegmentedButton<TrackerType>(
            segments: const <ButtonSegment<TrackerType>>[
              ButtonSegment<TrackerType>(
                  value: TrackerType.score,
                  label: Text('Score'),
                  icon: Icon(Icons.score)),
              ButtonSegment<TrackerType>(
                  value: TrackerType.stars,
                  label: Text('Stars'),
                  icon: Icon(Icons.stars)),
              ButtonSegment<TrackerType>(
                  value: TrackerType.counter,
                  label: Text('Count'),
                  icon: Icon(Icons.plus_one_outlined)),
              /*ButtonSegment<TrackerType>(
                  value: TrackerType.hours,
                  label: Text('Time'),
                  icon: Icon(Icons.timer)),*/
            ],
            selected: <TrackerType>{trackerView},
            onSelectionChanged: (Set<TrackerType> newSelection) {
              setState(() {
                trackerView = newSelection.first;
              });
            },
          ),
        ),
      ],
    );
  }

  // ------ MAIN WIDGET TREE FOR THE CREATE NEW TRACKER SCREEN ------
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

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
              HeaderText(widget: widget, header: 'Tracker preview'),

              trackerCardListItem(
                theme: theme,
                trackerInfo: {
                  'type': trackerView,
                  'info': {
                    'title': _titlecontroller.text,
                    'rangeMax': 10,
                  }
                },
              ),

              HeaderText(widget: widget, header: 'Type'),

              choosingType(),

              HeaderText(widget: widget, header: 'Title'),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: _titlecontroller,
                  onTap: () => _titlecontroller.clear(),
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

              // SUBMIT BUTTON FOR SUBMITING NEW TO DO
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  final isValidForm = formKey.currentState!.validate();

                  if (isValidForm) {
                    appState.addTracker(_titlecontroller.text, trackerView, 10);
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

// ------ DIVIDER WITH TEXT CLASS ------
class HeaderText extends StatelessWidget {
  const HeaderText({
    super.key,
    required this.widget,
    required this.header,
  });

  final TrackerPopup widget;
  final String header;

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
