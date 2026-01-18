
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// A simple data model for a task
class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});

  // Serialization
  Map<String, dynamic> toJson() => {'title': title, 'isDone': isDone};

  // Deserialization
  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(title: json['title'], isDone: json['isDone']);
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _textController = TextEditingController();
  static const _tasksKey = 'tasks_key';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString(_tasksKey);
    if (tasksString != null) {
      final List<dynamic> taskJson = jsonDecode(tasksString);
      setState(() {
        _tasks.clear();
        _tasks.addAll(taskJson.map((json) => Task.fromJson(json)));
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString =
        jsonEncode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_tasksKey, tasksString);
  }

  void _addTask() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _tasks.insert(0, Task(title: _textController.text));
        _textController.clear();
      });
      _saveTasks();
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart To-Do List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  key: ValueKey(task.title + index.toString()), // Unique key for reordering
                  leading: Checkbox(
                    value: task.isDone,
                    onChanged: (value) => _toggleTask(index),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteTask(index),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final task = _tasks.removeAt(oldIndex);
                  _tasks.insert(newIndex, task);
                });
                _saveTasks();
              },
            ),
          ),
          _buildTaskComposer(),
        ],
      ),
    );
  }

  Widget _buildTaskComposer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Add a new task...',
                    ),
                    onSubmitted: (value) => _addTask(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _addTask,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

