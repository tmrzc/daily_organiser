import 'package:daily_organiser/screens/tracker/trackerscreen.dart';

final String tableTracker = 'trackersList';
final String tableStats = 'statsList';

class TrackerTable {
  static final List<String> values = [
    id_tracker,
    name_tracker,
    type_tracker,
    color_id,
    range_tracker,
    isLocked,
    value,
  ];

  static final String id_tracker = 'id_tracker';
  static final String name_tracker = 'name_tracker';
  static final String type_tracker = 'type_tracker';
  static final String color_id = 'color_id';
  static final String range_tracker = 'range_tracker';
  static final String isLocked = 'isLocked';
  static final String value = 'value';
}

class TrackerStats {
  static final String id_stats = 'id_stats';
  static final String date_stats = 'date_stats';
  static final String tracker_id = 'tracker_id';
  static final String value_stats = 'value_stats';
}

class Tracker {
  final int? id;
  final String name;
  final String type;
  final int color;
  final int range;
  bool isLocked;
  double? value;

  Tracker({
    this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.range,
    required this.isLocked,
    this.value,
  });

  Tracker copy(
          {int? id,
          String? name,
          String? type,
          int? color,
          int? range,
          bool? isLocked,
          double? value}) =>
      Tracker(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        color: color ?? this.color,
        range: range ?? this.range,
        isLocked: isLocked ?? this.isLocked,
        value: value ?? this.value,
      );

  static Tracker fromJson(Map<String, Object?> json) => Tracker(
        id: json[TrackerTable.id_tracker] as int?,
        name: json[TrackerTable.name_tracker] as String,
        type: json[TrackerTable.type_tracker] as String,
        color: json[TrackerTable.color_id] as int,
        range: json[TrackerTable.range_tracker] as int,
        isLocked: json[TrackerTable.isLocked] == 1,
        value: json[TrackerTable.value] as double?,
      );

  Map<String, Object?> toJson() => {
        TrackerTable.id_tracker: id,
        TrackerTable.name_tracker: name,
        TrackerTable.type_tracker: type,
        TrackerTable.color_id: color,
        TrackerTable.range_tracker: range,
        TrackerTable.isLocked: isLocked ? 1 : 0,
        TrackerTable.value: value,
      };
}

TrackerType stringConvertertoType(String typeString) {
  switch (typeString) {
    case 'score':
      return TrackerType.score;
    case 'stars':
      return TrackerType.stars;
    case 'counter':
      return TrackerType.counter;
    default:
      return TrackerType.score;
  }
}

String typeConverterToString(TrackerType typeToConvert) {
  switch (typeToConvert) {
    case TrackerType.score:
      return 'score';
    case TrackerType.stars:
      return 'stars';
    case TrackerType.counter:
      return 'counter';
    default:
      return 'ERROR CONVERTING TOJSON';
  }
}
