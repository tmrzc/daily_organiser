import 'package:daily_organiser/screens/stats/bar_graph/chart_graph90.dart';
import 'package:daily_organiser/screens/stats/bar_graph/chart_graph_all.dart';
import 'package:daily_organiser/screens/tracker/trackerpopup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:daily_organiser/database/databaseusage.dart';
import 'package:daily_organiser/screens/stats/statsedit.dart';
import 'package:daily_organiser/screens/stats/statsadd.dart';
import 'package:daily_organiser/provider.dart';
import 'package:daily_organiser/screens/tracker/trackerscreen.dart';
import 'package:daily_organiser/database/trackermodel.dart';
import 'package:daily_organiser/database/statsmodel.dart';
import 'package:daily_organiser/screens/stats/bar_graph/chart_graph30.dart';
import 'package:daily_organiser/screens/stats/bar_graph/chart_data.dart';

enum ChartRangeItems { last30days, last90days, all }

class StatsPopup extends StatefulWidget {
  StatsPopup({
    super.key,
    this.myChartData,
    required this.theme,
    required this.trackerInfo,
  });

  ChartData? myChartData;
  final ThemeData theme;
  final Tracker trackerInfo;

  @override
  State<StatsPopup> createState() => _StatsPopup();
}

class _StatsPopup extends State<StatsPopup> {
  bool isHistoryLoading = false;
  bool isChartLoading = false;
  List<Stat> historyList = [];
  List<FlSpot> listOfSpots = [];
  List<Stat> statsList = [];
  double maxCounterValue = 0;
  ChartRangeItems chartRangeItemView = ChartRangeItems.last30days;
  int numberOfDaysSinceFirstEntry = 0;

  @override
  void initState() {
    super.initState();
    loadHistory(widget.trackerInfo.id!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.wait([loadHistory(widget.trackerInfo.id!)]).then((value) {
      loadDataAccordingly(chartRangeItemView, value[0]);
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: SizedBox(
                height: 300,
                child: isChartLoading
                    ? const Center(child: CircularProgressIndicator())
                    : chartRangeItemView == ChartRangeItems.all
                        ? MyChartGraphAll(
                            theme: theme,
                            tracker: widget.trackerInfo,
                            listOfSpots: listOfSpots,
                            maxCounterValue: maxCounterValue,
                            statsList: statsList,
                          )
                        : chartRangeItemView == ChartRangeItems.last90days
                            ? MyChartGraph90(
                                theme: theme,
                                tracker: widget.trackerInfo,
                                listOfSpots: listOfSpots,
                                maxCounterValue: maxCounterValue,
                                statsList: statsList,
                              )
                            : MyChartGraph30(
                                theme: theme,
                                tracker: widget.trackerInfo,
                                listOfSpots: listOfSpots,
                                maxCounterValue: maxCounterValue,
                                statsList: statsList,
                              ),
              ),
            ),
            SegmentedButton<ChartRangeItems>(
              showSelectedIcon: false,
              segments: <ButtonSegment<ChartRangeItems>>[
                ButtonSegment<ChartRangeItems>(
                  enabled: isChartLoading ? false : true,
                  value: ChartRangeItems.last30days,
                  label: Text('30 DAYS'),
                ),
                ButtonSegment<ChartRangeItems>(
                  enabled: isChartLoading ? false : true,
                  value: ChartRangeItems.last90days,
                  label: Text('90 DAYS'),
                ),
                ButtonSegment<ChartRangeItems>(
                  enabled: isChartLoading ? false : true,
                  value: ChartRangeItems.all,
                  label: Text('ALL DATA'),
                ),
              ],
              selected: <ChartRangeItems>{chartRangeItemView},
              onSelectionChanged: (Set<ChartRangeItems> newSelection) {
                setState(() {
                  chartRangeItemView = newSelection.first;
                  loadDataAccordingly(
                      chartRangeItemView, numberOfDaysSinceFirstEntry);
                });
              },
            ),
            HeaderTextWithButton(
              widget: widget,
              header: 'HISTORY',
              theme: theme,
            ),
            Expanded(
              child: isHistoryLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: historyList.length,
                      itemBuilder: (context, index) {
                        return historyList[index].day == 1 &&
                                historyList[index] != historyList.last
                            ? Column(
                                children: [
                                  valuesHistoryListTile(index, context, theme),
                                  SizedBox(height: 10),
                                  DatesDivider(
                                      widget: widget,
                                      header:
                                          '${monthStringFromInt(historyList[index].month)} ${historyList[index].year}'),
                                ],
                              )
                            : valuesHistoryListTile(index, context, theme);
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  String monthStringFromInt(int monthInt) {
    List<String> months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];

    return months[monthInt - 2];
  }

  ListTile valuesHistoryListTile(
      int index, BuildContext context, ThemeData theme) {
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
  }

  void loadDataAccordingly(ChartRangeItems item, [int difference = 1]) {
    switch (item) {
      case ChartRangeItems.all:
        importXDaysData(difference);
        break;
      case ChartRangeItems.last90days:
        importXDaysData(90);
        break;
      case ChartRangeItems.last30days:
        importXDaysData(30);
        break;
      default:
    }
  }

  Future<int> loadHistory(int tracker_id) async {
    setState(() => isHistoryLoading = true);

    historyList = await OrganiserDatabase.instance.readStats(tracker_id);

    if (historyList.isNotEmpty) {
      int day = historyList.last.day;
      int month = historyList.last.month;
      int year = historyList.last.year;
      DateTime firstEntryDate = DateTime.utc(year, month, day);
      numberOfDaysSinceFirstEntry =
          DateTime.now().difference(firstEntryDate).inDays + 5;
    }

    if (mounted) {
      setState(() => isHistoryLoading = false);
    }

    if (historyList.isEmpty) {
      return 1;
    }

    return numberOfDaysSinceFirstEntry;
  }

  Future importXDaysData(int howManyDays) async {
    setState(() => isChartLoading = true);

    final db = OrganiserDatabase.instance;

    statsList = await db.importLastXDays(widget.trackerInfo.id!, howManyDays);

    if (isCounterType(widget.trackerInfo)) {
      maxCounterValue = await db.returnHighestValue(widget.trackerInfo.id!);
      widget.trackerInfo.range = (maxCounterValue.toInt() * 1.1).toInt();
      db.updateTracker(widget.trackerInfo);
    } else {
      maxCounterValue = widget.trackerInfo.range.toDouble();
    }

    List<double> list = [];

    for (int i = statsList.length - 1; i >= 0; i--) {
      list.add(statsList[i].value);
    }

    widget.myChartData = ChartData(
      amounts: list,
    );
    widget.myChartData?.initializeChartData(howManyDays);
    listOfSpots = await provideSpotsList();

    if (mounted) {
      setState(() => isChartLoading = false);
    }
  }

  Future<List<FlSpot>> provideSpotsList() async {
    var listIndividualPoints = widget.myChartData!.chartData;
    List<FlSpot> listFlSpot = [];

    for (int i = 0; i < listIndividualPoints.length; i++) {
      if (listIndividualPoints[i].y < 0) {
        listFlSpot
            .add(FlSpot(listIndividualPoints[i].x, 0)); //(FlSpot.nullSpot);
      } else {
        listFlSpot
            .add(FlSpot(listIndividualPoints[i].x, listIndividualPoints[i].y));
      }
    }
    return listFlSpot;
  }

  bool isCounterType(Tracker tracker) {
    TrackerType type = tracker.stringConvertertoType(tracker.type);
    return type == TrackerType.counter ? true : false;
  }
}

class DatesDivider extends StatelessWidget {
  DatesDivider({
    super.key,
    required this.widget,
    required this.header,
  });

  var widget;
  final String header;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 1,
              width: 40,
              color: widget.theme.disabledColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Text(
              header,
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w400),
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

// ------ HEADER WITH BUTTON ------
class HeaderTextWithButton extends StatelessWidget {
  HeaderTextWithButton({
    super.key,
    required this.widget,
    required this.header,
    required this.theme,
  });

  ThemeData theme;
  var widget;
  final String header;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: Text(
            header,
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            width: 40,
            color: widget.theme.disabledColor,
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddStatsPopup(
                    theme: theme,
                    trackerInfo: widget.trackerInfo,
                  ),
                ));
          },
          icon: const Icon(Icons.add),
        )
      ],
    );
  }
}
