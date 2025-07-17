import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');

  List<Task> get tasks => _taskBox.values.toList();

  void addTask(String title) {
    final normalizedTitle = title.trim().toLowerCase();

    final exists = _taskBox.values.any(
      (task) => task.title.trim().toLowerCase() == normalizedTitle,
    );

    if (exists) {
      throw Exception('La tarea ya existe');
    }

    final task = Task(title: title, isDone: false);
    _taskBox.add(task);
    notifyListeners();
  }

  void toggleTask(Task task) {
    task.isDone = !task.isDone;
    task.save();
    notifyListeners();
  }

  void deleteTask(Task task) {
    task.delete();
    notifyListeners();
  }

  void editTask(Task task, String newTitle) {
    task.title = newTitle;
    task.save();
    notifyListeners();
  }
}
