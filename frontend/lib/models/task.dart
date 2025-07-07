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
      taskType: json['taskType'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'] ?? false,
      aquariumId: json['aquariumId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'taskType': taskType,
      'dueDate': dueDate.toIso8601String(),
      'aquariumId': aquariumId,
    };
  }
}
