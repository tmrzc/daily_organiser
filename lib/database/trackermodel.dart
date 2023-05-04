final String tableTracker = 'trackersList';

class TrackerTable {
  static final String id_tracker = 'id_tracker';
  static final String name_tracker = 'name_tracker';
  static final String type_tracker = 'type_tracker';
  static final String color_id = 'color_id';
  static final String range_tracker = 'range_tracker';
}

class Tracker {
  final int? id;
  final String name;
  final String type;
  final int color;
  final int range;

  const Tracker({
    this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.range,
  });
}
