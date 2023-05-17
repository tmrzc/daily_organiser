import 'package:daily_organiser/database/databaseusage.dart';
import 'package:daily_organiser/screens/stats/statsedit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:daily_organiser/provider.dart';
import 'package:daily_organiser/database/trackermodel.dart';
import 'package:daily_organiser/database/statsmodel.dart';
import 'package:daily_organiser/screens/tracker/trackerpopup.dart';
import 'package:daily_organiser/screens/stats/bar_graph/chart_graph.dart';

class StatsPopup extends StatefulWidget {
  const StatsPopup({
    super.key,
    required this.theme,
    required this.trackerInfo,
  });

  final ThemeData theme;
  final Tracker trackerInfo;

  @override
  State<StatsPopup> createState() => _StatsPopup();
}

class _StatsPopup extends State<StatsPopup> {
  bool isLoading = false;
  List<Stat> historyList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadHistory(widget.trackerInfo.id!);
  }

  Future loadHistory(int tracker_id) async {
    setState(() => isLoading = true);

    historyList = await OrganiserDatabase.instance.readStats(tracker_id);

    setState(() => isLoading = false);
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //HeaderText(widget: widget, header: 'LINE CHART'),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: SizedBox(
                height: 300,
                child: MyChartGraph(theme: theme, tracker: widget.trackerInfo),
              ),
            ),
            HeaderText(widget: widget, header: 'HISTORY'),
            Expanded(
              child: ListView.builder(
                itemCount: historyList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${historyList[index].value.round().toInt()}'),
                    subtitle: Text(
                        '${historyList[index].year}/${historyList[index].month}/${historyList[index].day}'),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditStatsPopup(
                                theme: theme,
                                trackerInfo: widget.trackerInfo,
                                stat: historyList[index],
                              ),
                            ));
                      },
                      icon: Icon(Icons.edit_note),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
