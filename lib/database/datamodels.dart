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

final String tableTodo = 'toDoList';

class TodoTable {
  static final List<String> values = [id, value_todo, isDone];

  static final String id = 'id_todo';
  static final String value_todo = 'value_todo';
  static final String isDone = 'isDone';
}

class Todo {
  final int? id;
  final String value;
  final bool isDone;

  const Todo({
    this.id,
    required this.value,
    required this.isDone,
  });

  Todo copy({
    int? id,
    String? value,
    bool? isDone,
  }) =>
      Todo(
        id: id ?? this.id,
        value: value ?? this.value,
        isDone: isDone ?? this.isDone,
      );

  Map<String, Object?> toJson() => {
        TodoTable.id: id,
        TodoTable.value_todo: value,
        TodoTable.isDone: isDone ? 1 : 0,
      };
}
