// lib/repositories/task_repository.dart

import 'package:appscrip_task_management_app/model/hive_model.dart';
import 'package:hive/hive.dart';

class TaskRepository {
  Future<void> createTask(hive_model task) async {
    final box = await Hive.openBox<hive_model>('taskBox');
    await box.put(task.id, task);
    print("Task Created: ${box.get(task.id)}"); // Print task to verify
  }

  Future<void> updateTask(hive_model task) async {
    final box = await Hive.openBox<hive_model>('taskBox');
    await box.put(task.id, task as hive_model);
  }

  Future<void> deleteTask( id) async {
    final box = await Hive.openBox<hive_model>('taskBox');
    await box.delete(id);
  }

  Future<List<hive_model>> fetchTasks() async {
    final box = await Hive.openBox<hive_model>('taskBox');
    return box.values.toList();
  }
}
