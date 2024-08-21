class TaskModel {
  int id;
  String title;
  String description;
  DateTime dueDate;
  String priority;
  String status;
  String assignedUser;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.assignedUser,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      priority: json['priority'],
      status: json['status'],
      assignedUser: json['assigned_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
      'status': status,
      'assigned_user': assignedUser,
    };
  }
}
