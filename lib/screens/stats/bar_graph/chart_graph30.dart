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

class MyChartGraph30 extends StatefulWidget {
  MyChartGraph30({
    super.key,
    required this.theme,
    required this.tracker,
    required this.listOfSpots,
    required this.maxCounterValue,
    required this.statsList,
  });

  ChartData? myChartData;
  final ThemeData theme;
  final Tracker tracker;
  final List<FlSpot> listOfSpots;
  final double maxCounterValue;
  final List<Stat> statsList;

  @override
  State<MyChartGraph30> createState() => _MyChartGraph30State();
}

class _MyChartGraph30State extends State<MyChartGraph30> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        maxY: widget.maxCounterValue * 1.3, //widget.tracker.range.toDouble(),
        minY: -widget.maxCounterValue * 0.1,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map(
                (LineBarSpot touchedSpot) {
                  return LineTooltipItem(
                      '${widget.listOfSpots[touchedSpot.spotIndex].y.toStringAsFixed(0)}\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: getTooltipDate(touchedSpot),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ))
                      ]);
                },
              ).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              show: false,
            ),
            spots: widget.listOfSpots,
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

  String getTooltipDate(LineBarSpot touchedSpot) {
    List<DateTime> datesList = [];
    var idx = widget.listOfSpots[touchedSpot.spotIndex].x.toInt() - 1;

    for (int i = widget.statsList.length - 1; i >= 0; i--) {
      datesList.add(DateTime.utc(
        widget.statsList[i].year,
        widget.statsList[i].month,
        widget.statsList[i].day,
      ));
    }

    String text =
        '${datesList[idx].year}/${datesList[idx].month}/${datesList[idx].day}';

    return text;
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    Widget text;
    List<DateTime> datesList = [];

    for (int i = widget.statsList.length - 1; i >= 0; i--) {
      datesList.add(DateTime.utc(
        widget.statsList[i].year,
        widget.statsList[i].month,
        widget.statsList[i].day,
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
    } else if (idx == 29 && datesList[idx].day >= 4) {
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
}
