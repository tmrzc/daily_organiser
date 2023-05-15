import 'package:daily_organiser/database/trackermodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:async';
import '../../main.dart';
import '../../provider.dart';
import 'trackerscreen.dart';
import 'package:daily_organiser/database/trackermodel.dart';

class trackerCardListItem extends StatefulWidget {
  trackerCardListItem({
    super.key,
    required this.theme,
    required this.trackerInfo,
    this.index = 0,
    this.isPreview = false,
  });

  final ThemeData theme;
  Tracker trackerInfo;
  int index;
  bool isPreview;

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
    var appState = context.watch<MyAppState>();
    var trackerInfo = widget.trackerInfo;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Card(
        color: trackerColors[trackerInfo.color]['theme'],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      trackerInfo.name,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  widget.isPreview
                      ? const Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Icon(
                            Icons.delete,
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SimpleDialog(
                                    title: const Text(
                                        "Delete this tracker and it's history?"),
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                appState
                                                    .removeTracker(trackerInfo);
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  20, 0, 20, 0),
                                              child: Text('Yes'),
                                            ),
                                          ),
                                          ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateColor
                                                      .resolveWith((states) =>
                                                          widget.theme
                                                              .shadowColor),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 0, 20, 0),
                                              child: Text(
                                                'No',
                                                style: TextStyle(
                                                  color: MaterialStateColor
                                                      .resolveWith((states) =>
                                                          widget.theme
                                                              .backgroundColor),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                                });
                          },
                          icon: const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Icon(
                              Icons.delete,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
              child: typeDependantOptions(
                widget.isPreview,
                trackerInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------ MENU SWITCHER FOR DIFFERENT TYPES OF TRACEKRS ------
  Widget typeDependantOptions(bool isPreview, Tracker tracker) {
    var appState = context.watch<MyAppState>();

    Row selectorRowTracker(Widget option, bool enableSubmitButton) {
      return Row(
        children: [
          Expanded(child: option),
          enableSubmitButton
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: isPreview
                      ? const Icon(Icons.check)
                      : IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            setState(() {
                              appState.saveValueToTracker(
                                  widget.trackerInfo, rating);
                            });
                          },
                        ),
                )
              : SizedBox()
        ],
      );
    }

    if (tracker.isLocked) {
      return Row(
        children: [
          Expanded(child: disabledTracker()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  appState.enableTracker(widget.trackerInfo);
                });
              },
            ),
          ),
        ],
      );
    }

    switch (stringConvertertoType(tracker.type)) {
      case TrackerType.score:
        return selectorRowTracker(sliderOption(tracker), false);
      case TrackerType.stars:
        return selectorRowTracker(starsOption(tracker), false);
      case TrackerType.counter:
        return selectorRowTracker(counterOption(), true);
      //case TrackerType.hours:
      //  return selectorRowTracker(timeOption());
      default:
        return const Text('ERROR: trackerpopup.dart typeDependantOptions()');
    }
  }

  Padding disabledTracker() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(10, 7, 0, 7),
      child: Center(child: Text('S a v e d !')),
    );
  }

  // ------ TYPES OF TRACKERS TO SELECT FROM -------
  Padding sliderOption(Tracker tracker) {
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
                onChangeEnd: (double newValue) {
                  Timer(Duration(milliseconds: 200), () {
                    appState.saveValueToTracker(tracker, rating);
                  });
                },
                value: rating,
                divisions: tracker.range,
                min: 0,
                max: tracker.range.toDouble(),
                label: '${rating.round()}',
                onChanged: (newRating) {
                  setState(() {
                    rating = newRating;
                    //appState.saveValueToTracker(widget.trackerInfo, rating);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding starsOption(Tracker tracker) {
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 0, 0),
      child: Center(
        child: Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(11, 11, 11, 11),
            child: RatingBar(
              glow: false,
              initialRating: rating,
              itemCount: 5,
              itemSize: 36,
              itemPadding: EdgeInsets.fromLTRB(6, 0, 6, 0),
              ratingWidget: RatingWidget(
                  full: const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  empty: const Icon(
                    Icons.star,
                    color: Colors.grey,
                  ),
                  half: const Icon(
                    Icons.star_half,
                    color: Colors.amber,
                  )),
              onRatingUpdate: (value) {
                rating = value;
                Timer(Duration(milliseconds: 200), () {
                  appState.saveValueToTracker(tracker, rating);
                });
              },
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
                      rating = double.parse(counterController.text);
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
                          rating = double.parse(counterController.text);
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
                      rating = double.parse(counterController.text);
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
