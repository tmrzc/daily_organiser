final String tableTodo = 'toDoList';

class TodoTable {
  static final List<String> values = [
    id,
    value_todo,
    isDone,
    manager_id,
  ];

  static const String id = 'id_todo';
  static const String value_todo = 'value_todo';
  static const String isDone = 'isDone';
  static const String manager_id = 'manager_id';
}

class Todo {
  final int? id;
  final String value;
  bool isDone;
  int? manager_id;

  Todo({
    this.id,
    this.manager_id,
    required this.value,
    required this.isDone,
  });

  Todo copy({
    int? id,
    String? value,
    bool? isDone,
    int? manager_id,
  }) =>
      Todo(
        id: id ?? this.id,
        value: value ?? this.value,
        isDone: isDone ?? this.isDone,
        manager_id: manager_id ?? this.manager_id,
      );

  static Todo fromJson(Map<String, Object?> json) => Todo(
        id: json[TodoTable.id] as int?,
        value: json[TodoTable.value_todo] as String,
        isDone: json[TodoTable.isDone] == 1,
        manager_id: json[TodoTable.manager_id] as int?,
      );

  Map<String, Object?> toJson() => {
        TodoTable.id: id,
        TodoTable.value_todo: value,
        TodoTable.isDone: isDone ? 1 : 0,
        TodoTable.manager_id: manager_id,
      };
}
