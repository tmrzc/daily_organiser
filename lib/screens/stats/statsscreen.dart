import 'package:daily_organiser/database/trackermodel.dart';
import 'package:daily_organiser/screens/stats/bar_graph/bar_graph.dart';
import 'package:daily_organiser/screens/stats/statspopup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../main.dart';
import '../../../provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:daily_organiser/screens/tracker/trackerscreen.dart';
import 'package:daily_organiser/screens/stats/statspopup.dart';

// ------ STATISTICS LIST SCREEN DISPLAYING THE LIST ------

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var trackers = appState.trackers;

    return CustomScrollView(slivers: <Widget>[
      // APP BAR WITH TITLE OF A SCREEN
      SliverAppBar.medium(
        pinned: true,
        actions: [
          IconButton(
            onPressed: () {
              appState.fillUpTrackersStats(30);
            },
            icon: Icon(Icons.smoke_free),
          )
        ],
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: false,
          title: Transform(
            transform: Matrix4.translationValues(-30.0, 0.0, 0.0),
            child: Text(
              "STATISTICS:",
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: widget.theme.colorScheme.onBackground,
              ),
            ),
          ),
          background: Container(color: widget.theme.colorScheme.background),
        ),
      ),

      // TRACKERS STATS FOR PAST WEEK
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: statsCard(
                trackers,
                index,
              ),
            );
          },
          childCount: trackers.length,
        ),
      ),
    ]);
  }

  Padding statsCard(List<Tracker> trackers, int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Card(
        color: trackerColors[trackers[index].color]['theme'],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        trackers[index].name,
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatsPopup(
                                theme: widget.theme,
                                trackerInfo: trackers[index],
                              ),
                            ));
                      },
                      child: Text(
                        'SEE MORE',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: MyBarGraph(
                  tracker: trackers[index],
                  theme: widget.theme,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "LAST WEEK'S STATISTICS",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
