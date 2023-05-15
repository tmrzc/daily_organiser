import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:daily_organiser/provider.dart';
import 'package:daily_organiser/database/trackermodel.dart';
import 'package:daily_organiser/screens/tracker/trackerpopup.dart';

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
              HeaderText(widget: widget, header: 'History'),
            ],
          ),
        ),
      ),
    );
  }
}
