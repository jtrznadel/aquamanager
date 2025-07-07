class Task {
  final int? id;
  final String title;
  final String taskType;
  final DateTime dueDate;
  final bool isCompleted;
  final int aquariumId;

  Task({
    this.id,
    required this.title,
    required this.taskType,
    required this.dueDate,
    this.isCompleted = false,
    required this.aquariumId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      taskType: json['task_type'],
      dueDate: DateTime.parse(json['due_date']),
      isCompleted: json['is_completed'] ?? false,
      aquariumId: json['aquarium_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'task_type': taskType,
      'due_date': dueDate.toIso8601String(),
      'aquarium_id': aquariumId,
    };
  }
}
