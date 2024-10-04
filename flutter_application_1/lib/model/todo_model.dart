class Todo {
  final int? id;
  final String name;
  final String description;
  final DateTime? alarmTime;

  Todo({
    this.id,
    required this.name,
    required this.description,
    this.alarmTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'alarmTime': alarmTime?.toIso8601String(),
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      alarmTime:
          map['alarmTime'] != null ? DateTime.parse(map['alarmTime']) : null,
    );
  }
}
