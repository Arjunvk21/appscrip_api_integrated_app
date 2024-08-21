import 'package:appscrip_task_management_app/model/hive_model.dart';
import 'package:appscrip_task_management_app/model/task.dart';
import 'package:appscrip_task_management_app/model/taskRepository.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();
  List<hive_model> _hivetasks = [];
  Box<hive_model> hiveBox = Hive.box<hive_model>('taskBox');

  List<hive_model> get hivetasks => _hivetasks;
  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;
  List<Map<String, dynamic>> _users = [];

  List<Map<String, dynamic>> get users => _users;

  Stream<void> fetchTasks() async* {
    final hiveTasks = hiveBox.values.toList();
    _hivetasks = await _taskRepository.fetchTasks();
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos'));
    if (response.statusCode == 200) {
      // _tasks = data.map((task) => TaskModel.fromJson(task)).toList();
      _tasks = hiveTasks.map((hiveTask) {
        return TaskModel(
          id: hiveTask.id,
          title: hiveTask.title,
          description: hiveTask.description,
          dueDate: hiveTask.dueDate,
          priority: hiveTask.priority,
          status: hiveTask.status,
          assignedUser: hiveTask.assignedUser,
        );
      }).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('https://reqres.in/api/users'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      _users = List<Map<String, dynamic>>.from(data['data']);
      notifyListeners();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> createTask(TaskModel task, hive_model hivetask) async {
    try {
      // Attempt to create task on the server
      final response = await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/todos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201) {
        // If server creation is successful, update the local state
        _tasks.add(TaskModel.fromJson(json.decode(response.body)));
        await _taskRepository.createTask(hivetask);
        notifyListeners();
      } else {
        throw Exception('Failed to create task on server');
      }
    } catch (e) {
      // Handle errors during server request
      print('Error creating task: $e');
    }

    ///update task
  }

  Future<void> updateTask(TaskModel task, hive_model hivetask) async {
    try {
      print('-------------${task.id}');
      final uri = Uri.parse('https://jsonplaceholder.typicode.com/todos/1');
      final requestBody = json.encode({
        'id': task.id,
        'title': task.title,
        'completed': task.status == 'Done' ? true : false,
      });

      // Debugging log
      print('Updating task at $uri with body: $requestBody');

      // Perform the remote update
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Task updated successfully');

        int index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = task;
          await _taskRepository.updateTask(hivetask);
          notifyListeners();
        }
      } else {
        print('Failed to update task: ${response.body}');
        throw Exception('Failed to update task');
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      print('Deleting task with id: $id');

      // Perform the remote deletion
      final response = await http.delete(
        Uri.parse('https://jsonplaceholder.typicode.com/todos/$id'),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Tasks before deletion: $_tasks');

        // Remove the task from the local list
        _tasks.removeWhere((task) => task.id == id);

        print('Tasks after deletion: $_tasks');

        notifyListeners();
      } else {
        print('Failed to delete task: ${response.body}');
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      print('Error deleting task: $e');
    }
  }
}
