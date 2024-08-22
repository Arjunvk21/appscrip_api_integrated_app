import 'package:appscrip_task_management_app/model/hive_model.dart';
import 'package:appscrip_task_management_app/model/task.dart';
import 'package:appscrip_task_management_app/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class TaskManagementPage extends StatelessWidget {
  const TaskManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6200EE),
        elevation: 0,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return ListView.builder(
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = taskProvider.tasks[index];
              print('-----------${task.id}');

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  color: const Color(0xFFBB86FC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigned User: ${task.title}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            '${task.dueDate} - ${task.priority}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white70,
                      ),
                      onPressed: () async {
                        await taskProvider.deleteTask(task.localId);
                      },
                    ),
                    onTap: () async {
                      // Navigate to edit task page
                      final updatedTaskData = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskEditPage(task: task),
                        ),
                      );
                      if (updatedTaskData != null) {
                        final updatedTask =
                            updatedTaskData['task'] as TaskModel?;
                        final hiveUpdatedTask =
                            updatedTaskData['hiveTask'] as hive_model?;

                        if (updatedTask != null) {
                          await taskProvider.updateTask(
                              updatedTask, hiveUpdatedTask!);
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTaskData = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TaskEditPage(),
            ),
          );
          if (newTaskData != null) {
            final newTask = newTaskData['task'] as TaskModel?;
            final hiveNewTask = newTaskData['hiveTask'] as hive_model?;

            if (newTask != null) {
              await Provider.of<TaskProvider>(context, listen: false)
                  .createTask(newTask, hiveNewTask!);
            }
          }
        },
        backgroundColor: const Color(0xFF6200EE),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class TaskEditPage extends StatefulWidget {
  final TaskModel? task;

  const TaskEditPage({super.key, this.task});

  @override
  _TaskEditPageState createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  DateTime _dueDate = DateTime.now();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  late String _description;
  late String _priority;
  late String _status;
  String? _assignedUser;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _priority = widget.task!.priority;
      _status = widget.task!.status;
      _assignedUser = widget.task!.assignedUser;
    } else {
      _title = '';
      _description = '';
      _dueDate = DateTime.now();
      _priority = 'Medium';
      _status = 'To-Do';
      _assignedUser = '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchUsers();
    });
  }

  int generateHiveKey() {
    return DateTime.now().millisecondsSinceEpoch.hashCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'Create Task' : 'Edit Task',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6200EE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: const TextStyle(color: Color(0xFF6200EE)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSaved: (value) => _title = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: Color(0xFF6200EE)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  labelStyle: const TextStyle(color: Color(0xFF6200EE)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                controller: TextEditingController(
                  text: _dateFormat.format(_dueDate),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF6200EE),
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null && pickedDate != _dueDate) {
                    setState(() {
                      _dueDate = pickedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _priority,
                items: ['High', 'Medium', 'Low']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) => _priority = value!,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  labelStyle: const TextStyle(color: Color(0xFF6200EE)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _status,
                items: ['To-Do', 'In Progress', 'Done']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) => _status = value!,
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: const TextStyle(color: Color(0xFF6200EE)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<TaskProvider>(
                builder: (context, taskProvider, _) {
                  if (_assignedUser != null &&
                      !taskProvider.users.any((user) =>
                          user['first_name'] + user['last_name'].toString() ==
                          _assignedUser)) {
                    _assignedUser = null;
                  }

                  return DropdownButtonFormField<String>(
                    // dropdownColor: Color.fromARGB(255, 56, 2, 43),
                    // style: TextStyle(color: Color.fromARGB(255, 244, 242, 198)),
                    decoration: const InputDecoration(
                      labelText: 'Assigned User',
                      // labelStyle: TextStyle(
                      //     color: Color.fromARGB(255, 244, 242, 198)),
                      // iconColor: Color.fromARGB(255, 244, 242, 198)
                    ),
                    value: _assignedUser,
                    items: taskProvider.users
                        .map<DropdownMenuItem<String>>((user) {
                      return DropdownMenuItem<String>(
                        value:
                            user['first_name'] + user['last_name'].toString(),
                        child:
                            Text('${user['first_name']} ${user['last_name']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _assignedUser = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a user';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final newTask = TaskModel(
                      localId: Uuid().v4(),
                      id: widget.task?.id ?? generateHiveKey(),
                      title: _title,
                      description: _description,
                      dueDate: _dueDate,
                      priority: _priority,
                      status: _status,
                      assignedUser: _assignedUser ?? '',
                    );
                    final hiveNewTask = hive_model(
                        localId: Uuid().v4(),
                        id: widget.task?.id ?? generateHiveKey(),
                        title: _title,
                        description: _description,
                        dueDate: _dueDate,
                        priority: _priority,
                        status: _status,
                        assignedUser: _assignedUser ?? '');
                    Navigator.pop(
                        context, {'task': newTask, 'hiveTask': hiveNewTask});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6200EE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save Task',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
