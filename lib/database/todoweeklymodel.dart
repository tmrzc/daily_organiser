import 'package:daily_organiser/database/todomodel.dart';

final String tableTodoManager = 'toDoManager';

class TodoManagerTable {
  static final List<String> values = [
    id,
    mon,
    tue,
    wed,
    thu,
    fr,
    sat,
    sun,
    title,
  ];

  static const String id = 'id_todomanager';
  static const String mon = 'mon';
  static const String tue = 'tue';
  static const String wed = 'wed';
  static const String thu = 'thu';
  static const String fr = 'fr';
  static const String sat = 'sat';
  static const String sun = 'sun';
  static const String title = 'title';
}

class TodoManager {
  TodoManager({
    this.id,
    required this.mon,
    required this.tue,
    required this.wed,
    required this.thu,
    required this.fr,
    required this.sat,
    required this.sun,
    required this.title,
  });

  final int? id;
  bool mon;
  bool tue;
  bool wed;
  bool thu;
  bool fr;
  bool sat;
  bool sun;
  String title;

  TodoManager copy({
    int? id,
    bool? mon,
    bool? tue,
    bool? wed,
    bool? thu,
    bool? fr,
    bool? sat,
    bool? sun,
    String? title,
  }) =>
      TodoManager(
        id: id ?? this.id,
        mon: mon ?? this.mon,
        tue: tue ?? this.tue,
        wed: wed ?? this.wed,
        thu: thu ?? this.thu,
        fr: fr ?? this.fr,
        sat: sat ?? this.sat,
        sun: sun ?? this.sun,
        title: title ?? this.title,
      );

  static TodoManager fromJson(Map<String, Object?> json) => TodoManager(
        id: json[TodoManagerTable.id] as int?,
        mon: json[TodoManagerTable.mon] == 1,
        tue: json[TodoManagerTable.tue] == 1,
        wed: json[TodoManagerTable.wed] == 1,
        thu: json[TodoManagerTable.thu] == 1,
        fr: json[TodoManagerTable.fr] == 1,
        sat: json[TodoManagerTable.sat] == 1,
        sun: json[TodoManagerTable.sun] == 1,
        title: json[TodoManagerTable.title] as String,
      );

  Map<String, Object?> toJson() => {
        TodoManagerTable.id: id,
        TodoManagerTable.mon: mon ? 1 : 0,
        TodoManagerTable.tue: tue ? 1 : 0,
        TodoManagerTable.wed: wed ? 1 : 0,
        TodoManagerTable.thu: thu ? 1 : 0,
        TodoManagerTable.fr: fr ? 1 : 0,
        TodoManagerTable.sat: sat ? 1 : 0,
        TodoManagerTable.sun: sun ? 1 : 0,
        TodoManagerTable.title: title,
      };
}
