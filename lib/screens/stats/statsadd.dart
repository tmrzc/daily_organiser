import 'package:daily_organiser/database/databaseusage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:daily_organiser/provider.dart';
import 'package:daily_organiser/database/trackermodel.dart';
import 'package:daily_organiser/database/statsmodel.dart';
import 'package:daily_organiser/screens/tracker/trackerpopup.dart';
import 'package:daily_organiser/screens/tracker/trackerscreen.dart';

class AddStatsPopup extends StatefulWidget {
  const AddStatsPopup({
    super.key,
    required this.theme,
    required this.trackerInfo,
  });

  final ThemeData theme;
  final Tracker trackerInfo;

  @override
  State<AddStatsPopup> createState() => _AddStatsPopup();
}

class _AddStatsPopup extends State<AddStatsPopup> {
  double rating = 0;
  bool isLoading = false;
  late DateTime chosenTime;
  final _valueController = TextEditingController();
  final counterController = TextEditingController();
  final ratingController = TextEditingController();
  List<Stat> statList = [];

  @override
  void initState() {
    super.initState();
    chosenTime = DateTime.now();

    rating = 0;
    _valueController.text = '';
    ratingController.text = '0';
    ratingController.addListener(ratingChanger);
    counterController.text = '0';
    counterController.addListener(counterChanger);
  }

  void counterChanger() {
    setState(() {
      var temp = counterController.text;
    });
  }

  void ratingChanger() {
    setState(() {
      var temp = ratingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.trackerInfo.name,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HeaderText(widget: widget, header: 'VALUE'),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ratingController.text,
                    style: GoogleFonts.poppins(
                      fontSize: 60,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  stringConvertertoType(widget.trackerInfo.type) ==
                          TrackerType.counter
                      ? Container()
                      : Text(
                          '/${widget.trackerInfo.range}',
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                ],
              ),

              HeaderText(widget: widget, header: 'EDIT THE VALUE'),
              typeDependantOptions(false, widget.trackerInfo),

              /*TextFormField(
                keyboardType: TextInputType.number,
                controller: _valueController,
                onTapOutside: (event) =>
                    importSelectedDate(chosenTime, widget.trackerInfo.id!),
                onTap: () => _valueController.clear(),
                validator: (String? value) {
                  return (int.tryParse(value!) == null && value != null)
                      ? 'Please enter a number'
                      : null;
                },
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Value',
                    suffixIcon: IconButton(
                      onPressed: () => _valueController.clear(),
                      icon: const Icon(Icons.clear),
                    )),
              ),*/

              HeaderText(widget: widget, header: 'DATE'),

              ElevatedButton(
                onPressed: () async {
                  final DateTime? dateTime = await showDatePicker(
                    currentDate: chosenTime,
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1999),
                    lastDate: DateTime.now(),
                  );
                  if (dateTime != null) {
                    setState(() {
                      chosenTime = dateTime;
                    });
                  }
                },
                child: Text(
                    '${chosenTime.year} / ${chosenTime.month} / ${chosenTime.day}'),
              ),

              // SUBMIT BUTTON FOR SUBMITING NEW TRACKER
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                onPressed: () {
                  //final isValidForm = formKey.currentState!.validate();

                  //if (isValidForm) {
                  if (statList.isEmpty) {
                    setState(() {
                      appState.saveValueToTracker(
                        widget.trackerInfo,
                        rating,
                        chosenTime.year,
                        chosenTime.month,
                        chosenTime.day,
                      );
                    });

                    Navigator.of(context).pop();
                  } else {
                    Stat newStat = Stat(
                      id: statList[0].id,
                      tracker_id: widget.trackerInfo.id!,
                      year: chosenTime.year,
                      month: chosenTime.month,
                      day: chosenTime.day,
                      value: rating,
                    );
                    setState(() {
                      appState.updateStat(newStat);
                    });
                    Navigator.of(context).pop();
                  }
                  //}
                },
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(letterSpacing: 2),
                ),
              ),
              SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }

  void importSelectedDate(DateTime dateTime, int tracker_id) async {
    setState(() => isLoading = true);

    statList = await OrganiserDatabase.instance
        .returnSelectedDateStat(chosenTime, tracker_id);

    setState(() => isLoading = false);
  }

  int stringToInt(TextEditingController controllerExample) {
    int? rangeValue = int.tryParse(controllerExample.text);
    int defaultValue = 10;

    if (rangeValue != null) {
      return rangeValue;
    } else {
      return defaultValue;
    }
  }

  // ------ MENU SWITCHER FOR DIFFERENT TYPES OF TRACEKRS ------
  Widget typeDependantOptions(bool isPreview, Tracker tracker) {
    var appState = context.watch<MyAppState>();

    Row selectorRowTracker(Widget option, bool enableSubmitButton) {
      return Row(
        children: [
          Expanded(child: option),
          /*enableSubmitButton
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
              : */
          SizedBox()
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
                /*onChangeEnd: (double newValue) {
                  Timer(Duration(milliseconds: 200), () {
                    appState.saveValueToTracker(tracker, rating);
                  });
                },*/
                value: rating,
                divisions: tracker.range,
                min: 0,
                max: tracker.range.toDouble(),
                label: '${rating.round()}',
                onChanged: (newRating) {
                  importSelectedDate(chosenTime, widget.trackerInfo.id!);
                  setState(() {
                    rating = newRating.roundToDouble();
                    ratingController.text = rating.round().toString();
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
                importSelectedDate(chosenTime, widget.trackerInfo.id!);
                setState(() {
                  rating = value;
                  ratingController.text = rating.round().toString();
                });
                /*Timer(Duration(milliseconds: 200), () {
                  appState.saveValueToTracker(tracker, rating);
                });*/
              },
            ),
          ),
        ),
      ),
    );
  }

  Padding counterOption() {
    var appState = context.watch<MyAppState>();

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
                    importSelectedDate(chosenTime, widget.trackerInfo.id!);
                    setState(() {
                      counterController.text =
                          subtractFromController(counterController, 1);
                      rating = double.parse(counterController.text);
                      ratingController.text = rating.round().toString();
                    });
                  },
                  child: Icon(Icons.remove),
                ),
                Expanded(
                  child: Center(
                    child: TextField(
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        importSelectedDate(chosenTime, widget.trackerInfo.id!);
                        setState(() {
                          rating = double.tryParse(counterController.text) ?? 0;
                          ratingController.text = rating.round().toString();
                        });
                      },
                      onSubmitted: (value) {
                        importSelectedDate(chosenTime, widget.trackerInfo.id!);
                        setState(() {
                          counterController.text =
                              emptyToZero(counterController);
                          rating = double.parse(counterController.text);
                          ratingController.text = rating.round().toString();
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
                    importSelectedDate(chosenTime, widget.trackerInfo.id!);
                    setState(() {
                      counterController.text =
                          addToController(counterController, 1);
                      rating = double.parse(counterController.text);
                      ratingController.text = rating.round().toString();
                    });
                  },
                  child: Icon(Icons.add),
                ),
                /*Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Container(
                    height: 30,
                    width: 1,
                    color: widget.theme.disabledColor,
                  ),
                ),
                ElevatedButton(
                  child: const Icon(Icons.check),
                  onPressed: () {
                    setState(() {
                      appState.saveValueToTracker(widget.trackerInfo, rating);
                    });
                  },
                )*/
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
}
