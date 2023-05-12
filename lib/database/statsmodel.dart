const String tableStats = 'statsList';

class TrackerStats {
  static final List<String> values = [
    id_stats,
    tracker_id,
    date_year,
    date_month,
    date_day,
    value_stats,
  ];

  static const String id_stats = 'id_stats';
  static const String tracker_id = 'tracker_id';
  static const String date_year = 'date_year';
  static const String date_month = 'date_month';
  static const String date_day = 'date_day';
  static const String value_stats = 'value_stats';
}

class Stat {
  final int? id;
  final int tracker_id;
  final int year;
  final int month;
  final int day;
  final double value;

  const Stat({
    this.id,
    required this.tracker_id,
    required this.year,
    required this.month,
    required this.day,
    required this.value,
  });

  Stat copy({
    int? id,
    int? tracker_id,
    int? year,
    int? month,
    int? day,
    double? value,
  }) =>
      Stat(
        id: id ?? this.id,
        tracker_id: tracker_id ?? this.tracker_id,
        year: year ?? this.year,
        month: month ?? this.month,
        day: day ?? this.day,
        value: value ?? this.value,
      );

  static Stat fromJson(Map<String, Object?> json) => Stat(
        id: json[TrackerStats.id_stats] as int?,
        tracker_id: json[TrackerStats.tracker_id] as int,
        year: json[TrackerStats.date_year] as int,
        month: json[TrackerStats.date_month] as int,
        day: json[TrackerStats.date_day] as int,
        value: json[TrackerStats.value_stats] as double,
      );

  Map<String, Object?> toJson() => {
        TrackerStats.id_stats: id,
        TrackerStats.tracker_id: tracker_id,
        TrackerStats.date_year: year,
        TrackerStats.date_month: month,
        TrackerStats.date_day: day,
        TrackerStats.value_stats: value,
      };
}
