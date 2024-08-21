import 'package:hive/hive.dart';

part 'hive_model.g.dart'; // This file will be generated

@HiveType(typeId: 1)
class hive_model extends HiveObject {
  @HiveField(0)
  late final int id;
  @HiveField(1)
  late final String title;
  @HiveField(2)
  late final String description;
  @HiveField(3)
  late final DateTime dueDate;
  @HiveField(4)
  late final String priority;
  @HiveField(5)
  late final String status;
  @HiveField(6)
  late final String assignedUser;

  hive_model({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.assignedUser,
  });
}
