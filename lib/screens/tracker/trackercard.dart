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

enum ActionItems { priorityUp, priorityDown, rename, delete, unlock }

class trackerCardListItem extends StatefulWidget {
  trackerCardListItem({
    super.key,
    required this.theme,
    required this.trackerInfo,
    this.index,
    this.isPreview = false,
    this.rating = 0,
  });

  final ThemeData theme;
  Tracker trackerInfo;
  int? index;
  bool isPreview;
  double rating;

  @override
  State<trackerCardListItem> createState() => _trackerCardListItem();
}

class _trackerCardListItem extends State<trackerCardListItem> {
  final counterController = TextEditingController();
  final _titlecontroller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    //widget.rating = 0;
    counterController.text = '0';
    _titlecontroller.text = widget.trackerInfo.name;
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Card(
        color: trackerColors[widget.trackerInfo.color]['theme'],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.trackerInfo.name,
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
                            Icons.more_vert_rounded,
                          ),
                        )
                      : popupMenu(appState, context, widget.trackerInfo),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
              child: typeDependantOptions(
                widget.isPreview,
                widget.trackerInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuButton<ActionItems> popupMenu(
      MyAppState appState, BuildContext context, Tracker trackerInfo) {
    return PopupMenuButton<ActionItems>(
      onSelected: (ActionItems item) {
        switch (item) {
          case ActionItems.priorityUp:
            setState(() {
              //print('ss ${widget.index}');
              appState.trackerPrioritySwap(widget.index!, true);
            });
            break;
          case ActionItems.priorityDown:
            setState(() {
              //print('ss ${widget.index}');
              appState.trackerPrioritySwap(widget.index!, false);
            });
            break;
          case ActionItems.rename:
            setState(() {
              renameDialog(context, appState, trackerInfo);
            });
            break;
          case ActionItems.delete:
            setState(() {
              deleteDialog(context, appState, trackerInfo);
            });
            break;
          case ActionItems.unlock:
            setState(() {
              appState.enableTracker(trackerInfo);
            });
            break;
          default:
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ActionItems>>[
        PopupMenuItem<ActionItems>(
          enabled: widget.index == 0 ? false : true,
          value: ActionItems.priorityUp,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(Icons.arrow_upward_rounded),
              Expanded(
                  child: Text(
                'MOVE UP',
                textAlign: TextAlign.right,
              ))
            ],
          ),
        ),
        PopupMenuItem<ActionItems>(
          enabled:
              widget.index == (appState.trackers.length - 1) ? false : true,
          value: ActionItems.priorityDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(Icons.arrow_downward_rounded),
              Expanded(
                  child: Text(
                'MOVE DOWN',
                textAlign: TextAlign.right,
              ))
            ],
          ),
        ),
        PopupMenuItem<ActionItems>(
          value: ActionItems.rename,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(Icons.edit),
              Expanded(
                  child: Text(
                'RENAME',
                textAlign: TextAlign.right,
              ))
            ],
          ),
        ),
        PopupMenuItem<ActionItems>(
          value: ActionItems.delete,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(Icons.delete),
              Expanded(
                  child: Text(
                'DELETE',
                textAlign: TextAlign.right,
              ))
            ],
          ),
        ),
        PopupMenuItem<ActionItems>(
          enabled: widget.trackerInfo.isLocked ? true : false,
          value: ActionItems.unlock,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(Icons.lock_open_rounded),
              Expanded(
                  child: Text(
                "UNLOCK",
                textAlign: TextAlign.right,
              ))
            ],
          ),
        ),
      ],
    );
  }

  Future<dynamic> renameDialog(
      BuildContext context, MyAppState appState, Tracker trackerInfo) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: formKey,
            child: SimpleDialog(
              title: const Text("Enter new name"),
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
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
                            labelText: 'Title of the tracker',
                            suffixIcon: IconButton(
                              onPressed: () => _titlecontroller.clear(),
                              icon: const Icon(Icons.clear),
                            )),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            final isValidForm =
                                formKey.currentState!.validate();

                            if (isValidForm) {
                              setState(() {
                                trackerInfo.name = _titlecontroller.text;
                                appState.updateTracker(trackerInfo);
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Text('Rename'),
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
                              'Cancel',
                              style: TextStyle(
                                color: MaterialStateColor.resolveWith(
                                    (states) => widget.theme.backgroundColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  Future<dynamic> deleteDialog(
      BuildContext context, MyAppState appState, Tracker trackerInfo) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text("Delete this tracker and it's history?"),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        appState.removeTracker(trackerInfo);
                      });
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

    if (tracker.isLocked) {
      return Row(
        children: [
          Expanded(child: disabledTracker()),
          /*Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  appState.enableTracker(widget.trackerInfo);
                });
              },
            ),
          ),*/
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
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 7, 0, 7),
      child: Center(
          child: Text(
        'SAVED FOR TODAY',
        style: GoogleFonts.poppins(
          fontSize: 16,
          letterSpacing: 2,
          fontWeight: FontWeight.w500,
        ),
      )),
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
                    appState.saveValueToTracker(tracker, widget.rating);
                  });
                },
                value: widget.rating,
                divisions: tracker.range,
                min: 0,
                max: tracker.range.toDouble(),
                label: '${widget.rating.round()}',
                onChanged: (newRating) {
                  setState(() {
                    widget.rating = newRating.roundToDouble();
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
              initialRating: widget.rating,
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
                widget.rating = value;
                Timer(Duration(milliseconds: 200), () {
                  appState.saveValueToTracker(tracker, widget.rating);
                });
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
                    setState(() {
                      counterController.text =
                          subtractFromController(counterController, 1);
                      widget.rating = double.parse(counterController.text);
                    });
                  },
                  child: Icon(Icons.remove),
                ),
                Expanded(
                  child: Center(
                    child: TextField(
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        setState(() {
                          widget.rating =
                              double.tryParse(counterController.text) ?? 0;
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          counterController.text =
                              emptyToZero(counterController);
                          widget.rating = double.parse(counterController.text);
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
                      widget.rating = double.parse(counterController.text);
                    });
                  },
                  child: Icon(Icons.add),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Container(
                    height: 30,
                    width: 1,
                    color: widget.theme.disabledColor,
                  ),
                ),
                widget.isPreview
                    ? ElevatedButton(
                        child: const Icon(Icons.check),
                        onPressed: () {},
                      )
                    : ElevatedButton(
                        child: const Icon(Icons.check),
                        onPressed: () {
                          setState(() {
                            appState.saveValueToTracker(
                                widget.trackerInfo, widget.rating);
                          });
                        },
                      )
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
