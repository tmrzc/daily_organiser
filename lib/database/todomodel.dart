final String tableTodo = 'toDoList';

class TodoTable {
  static final List<String> values = [
    id,
    value_todo,
    isDone,
  ];

  static const String id = 'id_todo';
  static const String value_todo = 'value_todo';
  static const String isDone = 'isDone';
}

class Todo {
  final int? id;
  final String value;
  bool isDone;

  Todo({
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

  static Todo fromJson(Map<String, Object?> json) => Todo(
        id: json[TodoTable.id] as int?,
        value: json[TodoTable.value_todo] as String,
        isDone: json[TodoTable.isDone] == 1,
      );

  Map<String, Object?> toJson() => {
        TodoTable.id: id,
        TodoTable.value_todo: value,
        TodoTable.isDone: isDone ? 1 : 0,
      };
}
