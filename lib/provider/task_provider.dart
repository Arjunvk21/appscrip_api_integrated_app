import 'package:appscrip_task_management_app/model/hive_model.dart';
import 'package:appscrip_task_management_app/model/task.dart';
import 'package:appscrip_task_management_app/model/taskRepository.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uuid/uuid.dart';

class TaskProvider with ChangeNotifier {
  var uuid = const Uuid();

  final TaskRepository _taskRepository = TaskRepository();
  List<hive_model> _hivetasks = [];
  Box<hive_model> hiveBox = Hive.box<hive_model>('taskBox');

  List<hive_model> get hivetasks => _hivetasks;
  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;
  List<Map<String, dynamic>> _users = [];

  List<Map<String, dynamic>> get users => _users;

  Future<void> fetchTasks() async {
    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/todos'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _tasks = data.map((task) => TaskModel.fromJson(task)).toList();
        _hivetasks = await _taskRepository.fetchTasks();
        notifyListeners();
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
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

  Future<void> createTask(TaskModel task, hive_model hiveTask) async {
    try {
      // Perform the remote creation
      final response = await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/todos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // If server creation is successful, add to local state and Hive
        _tasks.add(TaskModel.fromJson(json.decode(response.body)));
        task.id = responseData['id'];
        await _taskRepository.createTask(hiveTask); // Save to Hive
        notifyListeners();
        print('Task Created: ${task.localId}');
      } else {
        print('Failed to create task on server: ${response.body}');
        throw Exception('Failed to create task on server');
      }
    } catch (e) {
      print('Error creating task: $e');
    }
  }

  // Future<void> updateTask(TaskModel task, hive_model hiveTask) async {
  //   try {
  //     // Log the API id and localId for debugging
  //     print('API ID: ${task.id}, Local ID: ${task.localId}');

  //     // Construct the URI for updating the task on the server
  //     final uri = Uri.parse(
  //         'https://jsonplaceholder.typicode.com/todos/${task.id}');
  //     final requestBody = json.encode(task.toJson());

  //     // Debugging log
  //     print('Updating task at $uri with body: $requestBody');

  //     // Perform the remote update via HTTP PUT
  //     final response = await http.put(
  //       uri,
  //       headers: {'Content-Type': 'application/json'},
  //       body: requestBody,
  //     );
  //     print('Response status code: ${response.statusCode}');
  //     print('Response body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       print('Task updated successfully');

  //       // Find the task in the local list using localId
  //       int index = _tasks.indexWhere((t) => t.localId == task.localId);
  //       if (index != -1) {
  //         // Update the local task
  //         _tasks[index] = task;
  //         await _taskRepository.updateTask(task);
  //         notifyListeners();
  //       } else {
  //         print('Task with localId ${task.localId} not found');
  //       }
  //     } else {
  //       print('Failed to update task: ${response.body}');
  //       throw Exception('Failed to update task');
  //     }
  //   } catch (e) {
  //     print('Error updating task: $e');
  //   }
  // }
  Future<void> updateTask(TaskModel task, hive_model hiveTask) async {
    try {
      // Log the API id and localId for debugging
      print('API ID: ${task.id}, Local ID: ${task.localId}');

      // Construct the URI for updating the task on the server
      final uri =
          Uri.parse('https://jsonplaceholder.typicode.com/todos/${task.id}');
      final requestBody = json.encode(task.toJson());

      // Debugging log
      print('Updating task at $uri with body: $requestBody');

      // Perform the remote update via HTTP PUT
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Task updated successfully');

        // Find the task in the local list using localId
        int index = _tasks.indexWhere((t) => t.localId == task.localId);
        if (index != -1) {
          // Update the local task
          _tasks[index] = task;
          await _taskRepository.updateTask(hiveTask); // Update Hive task
          notifyListeners();
        } else {
          print('Task with localId ${task.localId} not found');
        }
      } else {
        print('Failed to update task: ${response.body}');
        throw Exception('Failed to update task');
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  // Future<void> deleteTask(id) async {
  //   try {
  //     print('Deleting task with id: $id');

  //     // Perform the remote deletion
  //     final response = await http.delete(
  //       Uri.parse('https://jsonplaceholder.typicode.com/todos/$id'),
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 204) {
  //       print('Tasks before deletion: $_tasks');

  //       // Remove the task from the local list
  //       _tasks.removeWhere((task) => task.id == id);

  //       print('Tasks after deletion: $_tasks');

  //       notifyListeners();
  //     } else {
  //       print('Failed to delete task: ${response.body}');
  //       throw Exception('Failed to delete task');
  //     }
  //   } catch (e) {
  //     print('Error deleting task: $e');
  //   }
  // }

  Future<void> deleteTask(String localId) async {
    try {
      // Find the task to delete using the localId
      final taskToDelete = _tasks.firstWhere(
        (t) => t.localId == localId,
        // orElse: () => null,  // Safely handle cases where the task is not found
      );

      // Check if the task is found and has a valid API ID
      if (taskToDelete != null && taskToDelete.id != null) {
        final uri = Uri.parse(
            'https://jsonplaceholder.typicode.com/todos/${taskToDelete.id}');
        final response = await http.delete(uri);

        if (response.statusCode == 200 || response.statusCode == 204) {
          // Successfully deleted task from API
          _tasks.removeWhere((t) => t.localId == localId);
          await _taskRepository.deleteTask(localId); // Delete from Hive
          notifyListeners();
        } else {
          print('Failed to delete task: ${response.body}');
          throw Exception('Failed to delete task');
        }
      } else {
        print(
            'Task with localId $localId does not have a valid API ID or was not found');
      }
    } catch (e) {
      print('Error deleting task: $e');
    }
  }
}
