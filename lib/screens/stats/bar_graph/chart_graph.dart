import 'dart:math';

import 'package:daily_organiser/screens/stats/bar_graph/chart_data.dart';
import 'package:daily_organiser/screens/stats/bar_graph/individual_point.dart';
import 'package:daily_organiser/database/trackermodel.dart';
import 'package:daily_organiser/database/databaseusage.dart';
import 'package:daily_organiser/database/statsmodel.dart';
import 'package:daily_organiser/screens/tracker/trackerscreen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class MyChartGraph extends StatefulWidget {
  MyChartGraph({
    super.key,
    this.myChartData,
    required this.theme,
    required this.tracker,
  });

  ChartData? myChartData;
  final ThemeData theme;
  final Tracker tracker;

  @override
  State<MyChartGraph> createState() => _MyChartGraphState();
}

class _MyChartGraphState extends State<MyChartGraph> {
  bool isLoading = false;
  late List<Stat> statsList;
  late double maxCounterValue2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    importXDaysData(30);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : LineChart(
            LineChartData(
              maxY: maxCounterValue2 * 1.3, //widget.tracker.range.toDouble(),
              minY: -maxCounterValue2 * 0.1,
              titlesData: FlTitlesData(
                  show: true,
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                      getTitlesWidget: getLeftTitles,
                      reservedSize: 50,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      interval: 1,
                      reservedSize: 30,
                      showTitles: true,
                      getTitlesWidget: getBottomTitles,
                    ),
                  )),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
              lineBarsData: [
                LineChartBarData(
                  shadow: Shadow(),
                  color: trackerColors[widget.tracker.color]
                      ['theme'], //widget.theme.primaryColor,
                  barWidth: 2,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        trackerColors[widget.tracker.color]['theme'],
                        widget.theme.canvasColor
                      ],
                    ),
                  ),
                  isCurved: true,
                  preventCurveOverShooting: true,
                  dotData: FlDotData(
                    show: true,
                  ),
                  spots: provideSpotsList(widget.myChartData!),
                ),
              ],
            ),
          );
  }

  Widget getLeftTitles(double value, TitleMeta meta) {
    Widget text;

    var style = GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w300,
      color: widget.theme.colorScheme.onBackground,
    );

    text = Text(
      '${value.toInt()}',
      style: style,
      maxLines: 1,
    );

    return text;
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    Widget text;
    List<DateTime> datesList = [];

    for (int i = statsList.length - 1; i >= 0; i--) {
      datesList.add(DateTime.utc(
        statsList[i].year,
        statsList[i].month,
        statsList[i].day,
      ));
    }

    String whatMonth(int monthInt) {
      List<String> monthsStrings = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC'
      ];

      return monthsStrings[monthInt - 1];
    }

    var idx = value.toInt() - 1;
    if (idx < 0) {
      text = Text('');
    } else if (datesList[idx].day == 1) {
      text = Text(
        whatMonth(datesList[idx].month),
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: widget.theme.colorScheme.onBackground,
        ),
        maxLines: 2,
        overflow: TextOverflow.fade,
      );
    } else if (idx == 29) {
      text = Text(
        '${datesList[idx].day}',
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: widget.theme.colorScheme.onBackground,
        ),
        maxLines: 2,
        overflow: TextOverflow.fade,
      );
    } else if (datesList[idx].day % 3 == 0 &&
        datesList[idx].day < 29 &&
        idx < 28 &&
        datesList[idx].day > 2) {
      text = Text(
        '${datesList[idx].day}',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: widget.theme.colorScheme.onBackground,
        ),
        maxLines: 2,
        overflow: TextOverflow.fade,
      );
    } else {
      text = Text('');
    }

    return text;
  }

  List<FlSpot> provideSpotsList(ChartData chartData) {
    var listIndividualPoints = chartData.chartData;
    List<FlSpot> listFlSpot = [];

    for (int i = 0; i < listIndividualPoints.length; i++) {
      if (listIndividualPoints[i].y < 0) {
        listFlSpot.add(FlSpot.nullSpot);
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

  Future importXDaysData(int howManyDays) async {
    setState(() => isLoading = true);

    final db = OrganiserDatabase.instance;

    statsList = await db.importLastXDays(widget.tracker.id!, howManyDays);

    if (isCounterType(widget.tracker)) {
      maxCounterValue2 = await db.returnHighestValue(widget.tracker.id!);
      widget.tracker.range = (maxCounterValue2.toInt() * 1.1).toInt();
      db.updateTracker(widget.tracker);
    } else {
      maxCounterValue2 = widget.tracker.range.toDouble();
    }

    List<double> list = [];

    for (int i = statsList.length - 1; i >= 0; i--) {
      list.add(statsList[i].value);
    }

    widget.myChartData = ChartData(
      amounts: list,
    );
    widget.myChartData?.initializeChartData(howManyDays);

    setState(() => isLoading = false);
  }
}
