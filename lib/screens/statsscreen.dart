import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../main.dart';

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

    return CustomScrollView(slivers: <Widget>[
      // APP BAR WITH TITLE OF A SCREEN
      SliverAppBar.medium(
        pinned: true,
        //actions: [NewTodoPopup()],
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: false,
          title: Text(
            "Statistics:",
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w400,
              color: widget.theme.colorScheme.onBackground,
            ),
          ),
          background: Container(color: widget.theme.colorScheme.background),
        ),
      ),

      // TASKS TO DO PART OF THE LIST
      SliverList(
        delegate:
            SliverChildBuilderDelegate((BuildContext context, int index) {}),
      ),
    ]);
  }
}
