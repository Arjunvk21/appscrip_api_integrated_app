import 'package:uuid/uuid.dart';

class TaskModel {
  String localId; 
  int? id;
  String title;
  String description;
  DateTime dueDate;
  String priority;
  String status;
  String assignedUser;

  TaskModel({
    this.id,
    required this.localId,
    required this.title,
    this.description = '',
    required this.dueDate,
    required this.priority,
    required this.status,
    this.assignedUser = '',
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      localId: Uuid().v4(),
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['due_date']),
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'To-Do',
      assignedUser: json['assigned_user'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
      'status': status,
      'assigned_user': assignedUser,
    };
  }
}
