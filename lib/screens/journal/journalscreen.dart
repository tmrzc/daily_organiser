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
  bool locked = false;
  bool isLoading = false;
  List<Note> notesList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadJournalNotes();
    //locked = isTodaysJournalCreated(notesList);
  }

  Future loadJournalNotes() async {
    setState(() => isLoading = true);

    notesList = await OrganiserDatabase.instance.readAllNotes().then((value) {
      locked = isTodaysJournalCreated(value);
      return value;
    });

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  bool isTodaysJournalCreated(List<Note> notesList) {
    if (notesList.isEmpty) return false;

    Note note = notesList[0];
    DateTime now = DateTime.now();
    if (now.year == note.year &&
        now.month == note.month &&
        now.day == note.day) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return CustomScrollView(slivers: <Widget>[
      // APP BAR WITH TITLE OF A SCREEN
      SliverAppBar.medium(
        pinned: true,
        actions: [
          isLoading
              ? Container()
              : IconButton(
                  tooltip: locked ? 'ONE NOTE PER DAY' : 'NEW NOTE',
                  onPressed: () {
                    if (locked) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          showCloseIcon: true,
                          content: const Text(
                            'YOU CAN ONLY CREATE\n ONE NOTE PER DAY',
                            textAlign: TextAlign.center,
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JournalPopup(
                              modeSelector: PopupMode.create,
                              theme: widget.theme,
                            ),
                          ));
                    }
                  },
                  icon: locked
                      ? Icon(
                          Icons.add,
                          size: 40,
                          color: widget.theme.disabledColor,
                        )
                      : const Icon(
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
                                theme: widget.theme,
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
