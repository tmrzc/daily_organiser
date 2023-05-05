import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import 'trackerpopup.dart';
import 'trackercard.dart';

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
                  onPressed: () => appState.addTodo('title'),
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: trackerCardListItem(
                theme: theme,
                trackerInfo: appState.trackers[index],
                index: index,
              ),
            );
          },
          childCount: appState.trackers.length,
        ),
      ),
    ]);
  }
}