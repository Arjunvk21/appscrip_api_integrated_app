import 'dart:convert';

List<TaskModelOriginal> taskModelFromJson(String str) =>
    List<TaskModelOriginal>.from(json.decode(str).map((x) => TaskModelOriginal.fromJson(x)));

String taskModelToJson(List<TaskModelOriginal> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TaskModelOriginal {
  int? userId;
  int? id;
  String? title;
  bool? completed;

  TaskModelOriginal({
    this.userId,
    this.id,
    this.title,
    this.completed,
  });

  factory TaskModelOriginal.fromJson(Map<String, dynamic> json) => TaskModelOriginal(
        userId: json["userId"],
        id: json["id"],
        title: json["title"],
        completed: json["completed"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "completed": completed,
      };
}
