import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../main.dart';
import 'trackerpopup.dart';

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
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    // FUNCTION FOR SETTING DIVIDERS FROM MAXVALUE FOR SLIDERS
    double intToDouble(int nr) {
      return nr * 1.0;
    }

    return CustomScrollView(slivers: <Widget>[
      // APP BAR WITH TITLE OF A SCREEN
      SliverAppBar.medium(
        pinned: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackerPopup(theme: theme),
                  ));
            },
            icon: Icon(
              Icons.add,
              size: 40,
            ),
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

      // BUTTON FOR ADDING JOURNAL ENTRY
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
            const Divider(
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
