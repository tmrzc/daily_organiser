import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:daily_organiser/database/trackermodel.dart';
import 'package:daily_organiser/database/databaseusage.dart';
import 'package:daily_organiser/database/statsmodel.dart';
import 'package:daily_organiser/provider.dart';
import 'package:daily_organiser/screens/stats/bar_graph/bar_data.dart';
import 'package:daily_organiser/screens/tracker/trackerscreen.dart';

class MyBarGraph extends StatefulWidget {
  //final List lastWeekStats;
  final Tracker tracker;
  BarData? myBarData;
  final ThemeData theme;

  MyBarGraph({
    super.key,
    required this.tracker,
    this.myBarData,
    required this.theme,
    //required this.lastWeekStats,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  bool isLoading = false;
  late List<Stat> lastXDayData;
  late double maxCounterValue;

  @override
  void initState() {
    super.initState();
    importXDayStats(7);
    maxCounterValue = 10;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    importXDayStats(7);
    if (widget.tracker.stringConvertertoType(widget.tracker.type) ==
        TrackerType.counter) {
      checkHighestCounterValue(widget.tracker);
    }
  }

  Future checkHighestCounterValue(Tracker tracker) async {
    setState(() => isLoading = true);

    maxCounterValue =
        await OrganiserDatabase.instance.returnHighestValue(tracker.id!);

    setState(() => isLoading = false);
  }

  bool isCounterType(Tracker tracker) {
    TrackerType type = tracker.stringConvertertoType(tracker.type);
    return type == TrackerType.counter ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (maxCounterValue < 10) {
      maxCounterValue = 10;
    }

    return isLoading
        ? Center(child: CircularProgressIndicator())
        : BarChart(
            BarChartData(
                maxY: isCounterType(widget.tracker)
                    ? maxCounterValue
                    : widget.tracker.range.toDouble(),
                minY: 0,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: getBottomTitles,
                    ),
                  ),
                ),
                barGroups: widget.myBarData?.barData
                    .map((data) => BarChartGroupData(
                          x: data.x,
                          barRods: [
                            BarChartRodData(
                                toY: data.y,
                                color: trackerColors[widget.tracker.color]
                                    ['theme'],
                                width: 25,
                                borderRadius:
                                    BorderRadius.all(Radius.elliptical(10, 5)),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: isCounterType(widget.tracker)
                                      ? maxCounterValue
                                      : widget.tracker.range.toDouble(),
                                  color: widget.theme.canvasColor,
                                ),
                                borderSide: BorderSide(color: Colors.black))
                          ],
                        ))
                    .toList()),
          );
  }

  Future importXDayStats(int howManyDays) async {
    setState(() => isLoading = true);

    lastXDayData = await OrganiserDatabase.instance
        .importLastXDays(widget.tracker.id!, howManyDays);

    widget.myBarData = BarData(
      amount0: lastXDayData[6].value,
      amount1: lastXDayData[5].value,
      amount2: lastXDayData[4].value,
      amount3: lastXDayData[3].value,
      amount4: lastXDayData[2].value,
      amount5: lastXDayData[1].value,
      amount6: lastXDayData[0].value,
    );
    widget.myBarData?.initializeBarData();

    setState(() => isLoading = false);
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    Widget text;

    var style = GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w300,
      color: widget.theme.colorScheme.onBackground,
    );

    String whatDayOfWeek(DateTime date) {
      late String finalString;

      switch (date.weekday) {
        case 1:
          finalString = 'MON';
          break;
        case 2:
          finalString = 'TUE';
          break;
        case 3:
          finalString = 'WED';
          break;
        case 4:
          finalString = 'THU';
          break;
        case 5:
          finalString = 'FR';
          break;
        case 6:
          finalString = 'SAT';
          break;
        case 7:
          finalString = 'SUN';
          break;
        default:
          finalString = 'ERROR whatDayOfTheWeek';
      }

      return finalString;
    }

    switch (value.toInt()) {
      case 0:
        int year = lastXDayData[6].year;
        int month = lastXDayData[6].month;
        int day = lastXDayData[6].day;

        DateTime date = DateTime.utc(year, month, day);

        text = Text(
          whatDayOfWeek(date),
          style: style,
        );
        break;
      case 1:
        int year = lastXDayData[5].year;
        int month = lastXDayData[5].month;
        int day = lastXDayData[5].day;

        DateTime date = DateTime.utc(year, month, day);

        text = Text(
          whatDayOfWeek(date),
          style: style,
        );
        break;
      case 2:
        int year = lastXDayData[4].year;
        int month = lastXDayData[4].month;
        int day = lastXDayData[4].day;

        DateTime date = DateTime.utc(year, month, day);

        text = Text(
          whatDayOfWeek(date),
          style: style,
        );
        break;
      case 3:
        int year = lastXDayData[3].year;
        int month = lastXDayData[3].month;
        int day = lastXDayData[3].day;

        DateTime date = DateTime.utc(year, month, day);

        text = Text(
          whatDayOfWeek(date),
          style: style,
        );
        break;
      case 4:
        int year = lastXDayData[2].year;
        int month = lastXDayData[2].month;
        int day = lastXDayData[2].day;

        DateTime date = DateTime.utc(year, month, day);

        text = Text(
          whatDayOfWeek(date),
          style: style,
        );
        break;
      case 5:
        int year = lastXDayData[1].year;
        int month = lastXDayData[1].month;
        int day = lastXDayData[1].day;

        DateTime date = DateTime.utc(year, month, day);

        text = Text(
          whatDayOfWeek(date),
          style: style,
        );
        break;
      case 6:
        int year = lastXDayData[0].year;
        int month = lastXDayData[0].month;
        int day = lastXDayData[0].day;

        DateTime date = DateTime.utc(year, month, day);

        text = Text(
          whatDayOfWeek(date),
          style: style,
        );
        break;
      default:
        text = const Text('ERROR GETBOTTOMTITLES');
    }
    return text;
  }
}
