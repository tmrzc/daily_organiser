import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../provider.dart';
import 'trackerpopup.dart';
import 'trackercard.dart';
import 'package:daily_organiser/main.dart';

var color = appTheme.primaryColor;

List primaryLighterColorValues = [
  (color.red + (255 - color.red) * offset).toInt(),
  (color.green + (255 - color.green) * offset).toInt(),
  (color.blue + (255 - color.blue) * offset).toInt(),
];

double offset = 0.75;

List trackerColors = [
  {
    'name': 'DEFAULT',
    'theme': Color.fromARGB(255, primaryLighterColorValues[0],
        primaryLighterColorValues[1], primaryLighterColorValues[2]),
  }, // idx 0
  {'name': 'RED', 'theme': Color.fromARGB(255, 252, 191, 219)}, // idx 1
  {'name': 'BLUE', 'theme': Color.fromARGB(255, 196, 231, 248)}, // idx 2
  {'name': 'MINT', 'theme': const Color.fromARGB(255, 211, 248, 226)}, // idx 3
  {'name': 'PINK', 'theme': const Color.fromARGB(255, 228, 193, 249)}, // idx 4
  {
    'name': 'YELLOW',
    'theme': const Color.fromARGB(255, 237, 231, 177)
  }, // idx 5
];

// ENUM FOR SELECTING TYPE OF TRACKER TO ADD
enum TrackerType { score, stars, counter, hours }

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
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Provider.of<MyAppState>(context, listen: false).dailyTrackerUnlock();
  }

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
          /*IconButton(
            onPressed: () {
              appState.checkDatabase();
            },
            icon: Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () {
              appState.testUnockingTrackers();
            },
            icon: Icon(Icons.lock),
          ),
          IconButton(
            onPressed: () {
              appState.changeTodayTimeBackwards();
            },
            icon: Icon(Icons.calendar_today),
          ),*/
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
          title: Transform(
            transform: Matrix4.translationValues(-30.0, 0.0, 0.0),
            child: Text(
              "TRACKERS:",
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

      // BUTTON FOR ADDING JOURNAL ENTRY
      SliverList(
        delegate: SliverChildListDelegate(
          [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "ADD TODAY'S JOURNAL ENTRY...",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
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
