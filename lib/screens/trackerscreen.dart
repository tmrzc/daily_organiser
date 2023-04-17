
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../main.dart';

// ------ TO-DO LIST SCREEN DISPLAYING THE LIST ------

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

      // TASKS TO DO PART OF THE LIST
      SliverList(
        delegate:
            SliverChildBuilderDelegate((BuildContext context, int index) {}),
      ),
    ]);
  }
}
