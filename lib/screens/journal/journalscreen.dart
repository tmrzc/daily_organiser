import 'package:daily_organiser/database/databaseusage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider.dart';
import 'journalpopup.dart';
import 'package:daily_organiser/database/notemodel.dart';

// ------ STATISTICS LIST SCREEN DISPLAYING THE LIST ------

enum ActionItems { edit, delete }

class JournalScreen extends StatefulWidget {
  const JournalScreen({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool isLoading = false;
  List<Note> notesList = [];
  String loremIpsum =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadJournalNotes();
  }

  Future loadJournalNotes() async {
    setState(() => isLoading = true);

    notesList = await OrganiserDatabase.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return CustomScrollView(slivers: <Widget>[
      // APP BAR WITH TITLE OF A SCREEN
      SliverAppBar.medium(
        pinned: true,
        //floating: true,
        //snap: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JournalPopup(
                      modeSelector: PopupMode.create,
                    ),
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
              "JOURNAL:",
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

      isLoading
          ? SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator()],
                ),
              ),
            )
          : SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                crossAxisCount: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  double left = (index % 2 == 0 ? 20 : 0);
                  double right = (index % 2 == 0 ? 0 : 20);

                  return Padding(
                    padding: EdgeInsets.fromLTRB(left, 0, right, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JournalPopup(
                                modeSelector: PopupMode.edit,
                                noteEdited: notesList[index],
                              ),
                            ));
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${notesList[index].year}/${notesList[index].month}/${notesList[index].day}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          widget.theme.colorScheme.onBackground,
                                    ),
                                  )
                                ],
                              ),
                              Divider(),
                              Flexible(
                                child: Text(
                                  notesList[index].note,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.fade,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: notesList.length,
              ),
            )
    ]);
  }
}
