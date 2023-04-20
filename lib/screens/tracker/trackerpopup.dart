import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../main.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// ------ DIALOG DISPLAYED FOR ADDING NEW TRACKERSS ------

enum TrackerType { score, stars, counter, hours }

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

  var cos = 0.0;

  TrackerType trackerView = TrackerType.score;

  final counterController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    counterController.text = '0';
    _titlecontroller.addListener(textChanger);
    counterController.addListener(counterChanger);
  }

  void textChanger() {
    setState(() {
      var temp = _titlecontroller.text;
    });
  }

  void counterChanger() {
    setState(() {
      var temp = counterController.text;
    });
  }

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
              ButtonSegment<TrackerType>(
                  value: TrackerType.hours,
                  label: Text('Time'),
                  icon: Icon(Icons.timer)),
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

  Widget typeDependantOptions() {
    if (trackerView == TrackerType.score) {
      return Column(
        children: [
          sliderOption(),
        ],
      );
    } else if (trackerView == TrackerType.stars) {
      return Column(
        children: [
          starsOption(),
        ],
      );
    } else if (trackerView == TrackerType.counter) {
      return Column(
        children: [
          counterOption(),
        ],
      );
    } else if (trackerView == TrackerType.hours) {
      return Column(
        children: [
          Text('Time'),
        ],
      );
    } else {
      return Column(
        children: [
          Text('Nothing'),
        ],
      );
    }
  }

  Center starsOption() {
    return Center(
      child: RatingBar(
        glow: false,
        initialRating: 5,
        itemCount: 5,
        ratingWidget: RatingWidget(
            full: Icon(
              Icons.star,
              color: Colors.amber,
            ),
            empty: Icon(
              Icons.star,
              color: Colors.grey,
            ),
            half: Icon(Icons.star_half)),
        onRatingUpdate: (value) {},
      ),
    );
  }

  String addToController(
      TextEditingController controllerExample, int amountToAdd) {
    int value = int.parse(controllerExample.text);
    value = value + amountToAdd;
    return value.toString();
  }

  String subtractFromController(
      TextEditingController controllerExample, int amountToSubtract) {
    int value = int.parse(controllerExample.text);
    if (amountToSubtract > value) {
      value = 0;
    } else {
      value = value - amountToSubtract;
    }

    return value.toString();
  }

  String emptyToZero(TextEditingController controllerExample) {
    if (controllerExample.text == '') return '0';
    int value = int.parse(controllerExample.text);
    if (value < 0) return '0';

    return controllerExample.text;
  }

  Center counterOption() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      counterController.text =
                          subtractFromController(counterController, 1);
                    });
                  },
                  child: Icon(Icons.remove),
                ),
                Expanded(
                  child: Center(
                    child: TextField(
                      textAlign: TextAlign.center,
                      onSubmitted: (value) {
                        setState(() {
                          counterController.text =
                              emptyToZero(counterController);
                        });
                      },
                      keyboardType: TextInputType.number,
                      controller: counterController,
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      counterController.text =
                          addToController(counterController, 1);
                    });
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Slider sliderOption() {
    return Slider(
      value: cos,
      divisions: 10,
      min: 0,
      max: 10,
      label: '$cos',
      onChanged: (newRating) {
        setState(() {
          cos = newRating;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                              child: typeDependantOptions(),
                            ),
                            Icon(Icons.check),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              HeaderText(widget: widget, header: 'Title'),

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

              HeaderText(widget: widget, header: 'Type'),

              choosingType(),

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
