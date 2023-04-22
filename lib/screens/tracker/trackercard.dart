import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:async';
import '../../main.dart';
import 'trackerpopup.dart';

class trackerCardListItem extends StatefulWidget {
  trackerCardListItem({
    super.key,
    required this.theme,
    required this.trackerInfo,
  });

  final ThemeData theme;
  var trackerInfo;

  @override
  State<trackerCardListItem> createState() => _trackerCardListItem();
}

class _trackerCardListItem extends State<trackerCardListItem> {
  double rating = 0;
  final counterController = TextEditingController();

  @override
  void initState() {
    super.initState();

    counterController.text = '0';
    counterController.addListener(counterChanger);
  }

  void counterChanger() {
    setState(() {
      var temp = counterController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    //var appState = context.watch<MyAppState>();
    var trackerInfo = widget.trackerInfo;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      trackerInfo['info']['title'],
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
                  Expanded(child: typeDependantOptions(trackerInfo['type'])),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Icon(Icons.check),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------ MENU SWITCHER FOR DIFFERENT TYPES OF TRACEKRS ------
  Widget typeDependantOptions(TrackerType type) {
    if (type == TrackerType.score) {
      return sliderOption();
    } else if (type == TrackerType.stars) {
      return starsOption();
    } else if (type == TrackerType.counter) {
      return counterOption();
    } else if (type == TrackerType.hours) {
      return timeOption();
    } else {
      return Text('ERROR: trackerpopup.dart typeDependantOptions()');
    }
  }

  Padding sliderOption() {
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 7, 0, 7),
      child: Center(
        child: Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Column(
            children: [
              Slider(
                value: rating,
                divisions: 10,
                min: 0,
                max: 10,
                label: '$rating',
                onChanged: (newRating) {
                  setState(() {
                    rating = newRating;
                    //appState.trackers[widget.index][1]['value'] = rating;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding starsOption() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Center(
        child: Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(11, 11, 11, 11),
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
          ),
        ),
      ),
    );
  }

  Padding counterOption() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 0, 4),
      child: Center(
        child: Card(
          elevation: 0,
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

  // ------ FUNCTIONS FOR MANAGING COUNTER TYPE TRACKER ------
  String addToController(
      TextEditingController controllerExample, int amountToAdd) {
    int value;
    if (controllerExample.text == '') {
      value = 0;
    } else {
      value = int.parse(controllerExample.text);
    }
    value = value + amountToAdd;
    return value.toString();
  }

  String subtractFromController(
      TextEditingController controllerExample, int amountToSubtract) {
    int value;
    if (controllerExample.text == '') {
      value = 0;
    } else {
      value = int.parse(controllerExample.text);
    }
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

  Center timeOption() {
    return Center(
      child: ElevatedButton(
        child: Text('time'),
        onPressed: () {
          showTimePassedDialog(context);
        },
      ),
    );
  }

  ListWheelScrollView timePassedPicker() {
    return ListWheelScrollView.useDelegate(
      itemExtent: 25,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 24,
        builder: (context, index) {
          return Card(
            child: Center(
              child: Text('$index'),
            ),
          );
        },
      ),
    );
  }

  void showTimePassedDialog(BuildContext context) => showDialog(
        context: context,
        builder: (context) {
          return Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(),
              body: timePassedPicker(),
            ),
          );
        },
      );
}
