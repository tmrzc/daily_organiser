import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../main.dart';

// ------ TRACKER LIST SCREEN DISPLAYING THE LIST ------

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final _titlecontroller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    double intToDouble(int nr) {
      return nr * 1.0;
    }

    return CustomScrollView(slivers: <Widget>[
      // APP BAR WITH TITLE OF A SCREEN
      SliverAppBar.medium(
        pinned: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 40),
            onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => Dialog.fullscreen(
                      child: Scaffold(
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
                        body: Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 0),
                                child: TextFormField(
                                  textCapitalization:
                                      TextCapitalization.sentences,
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
                                        onPressed: () =>
                                            _titlecontroller.clear(),
                                        icon: const Icon(Icons.clear),
                                      )),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 0),
                                child: TextFormField(
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: _titlecontroller,
                                  validator: (String? value) {
                                    return (value != null && value.length < 1)
                                        ? 'Tracker will have max. rating of 10 by default'
                                        : null;
                                  },
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText:
                                          'Maximum score for a rating in this tracker',
                                      suffixIcon: IconButton(
                                        onPressed: () =>
                                            _titlecontroller.clear(),
                                        icon: const Icon(Icons.clear),
                                      )),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // SUBMIT BUTTON FOR SUBMITING NEW TO DO
                              ElevatedButton(
                                onPressed: () {
                                  final isValidForm =
                                      formKey.currentState!.validate();

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
                    )),
          )
        ],
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: false,
          title: Text(
            "Trackers:",
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w400,
              color: widget.theme.colorScheme.onBackground,
            ),
          ),
          background: Container(color: widget.theme.colorScheme.background),
        ),
      ),

      SliverList(
        delegate: SliverChildListDelegate(
          [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: ElevatedButton(
                  onPressed: () => appState.addTracker('Test 1', 5.0, 10),
                  child: Text(
                    "Add today's journal entry...",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: widget.theme.colorScheme.onBackground,
                    ),
                  ),
                ),
              ),
            ),
            Divider(
              indent: 20,
              endIndent: 20,
              height: 40,
            ),
          ],
        ),
      ),

      // LIST OF CARDS OF TRACKERS
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Card(
                color: appState.trackers[index]['color'],
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${appState.trackers[index]['title']}',
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.w400,
                                color: widget.theme.colorScheme.onBackground,
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
                              value: appState.trackers[index]['rating'],
                              divisions: appState.trackers[index]['rangeMax'],
                              min: 0,
                              max: intToDouble(
                                  appState.trackers[index]['rangeMax']),
                              label: appState.trackers[index]['rating']
                                  .round()
                                  .toString(),
                              onChanged: (newRating) {
                                setState(() {
                                  appState.trackers[index]['rating'] =
                                      newRating;
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
            );
          },
          childCount: appState.trackers.length,
        ),
      ),
    ]);
  }
}
