const String tableNotes = 'notesList';

class JournalNotes {
  static const String id = 'id';
  static const String dateYear = 'dateYear';
  static const String dateMonth = 'dateMonth';
  static const String dateDay = 'dateDay';
  static const String noteContent = 'noteContent';

  static final List<String> values = [
    id,
    dateYear,
    dateMonth,
    dateDay,
    noteContent,
  ];
}

class Note {
  final int? id;
  final int year;
  final int month;
  final int day;
  String note;

  Note({
    this.id,
    required this.year,
    required this.month,
    required this.day,
    required this.note,
  });

  Note copy({
    int? id,
    int? year,
    int? month,
    int? day,
    String? note,
  }) =>
      Note(
        id: id ?? this.id,
        year: year ?? this.year,
        month: month ?? this.month,
        day: day ?? this.day,
        note: note ?? this.note,
      );

  static Note fromJson(Map<String, Object?> json) => Note(
        id: json[JournalNotes.id] as int?,
        year: json[JournalNotes.dateYear] as int,
        month: json[JournalNotes.dateMonth] as int,
        day: json[JournalNotes.dateDay] as int,
        note: json[JournalNotes.noteContent] as String,
      );

  Map<String, Object?> toJson() => {
        JournalNotes.id: id,
        JournalNotes.dateYear: year,
        JournalNotes.dateMonth: month,
        JournalNotes.dateDay: day,
        JournalNotes.noteContent: note,
      };
}
