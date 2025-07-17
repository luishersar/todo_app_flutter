import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TodoPage extends StatelessWidget {
  TodoPage({super.key});

  final TextEditingController _taskController = TextEditingController();

  void _showAddTaskDialog(BuildContext context) {
    _taskController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva tarea'),
        content: TextField(
          controller: _taskController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre de la tarea'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Agregar'),
            onPressed: () {
              final text = _taskController.text.trim();
              if (text.isNotEmpty) {
                try {
                  context.read<TaskProvider>().addTask(text);
                  Navigator.pop(context);
                } catch (e) {
                  Navigator.pop(context); // Cierra el diálogo primero
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(e.toString().replaceFirst('Exception: ', ''))),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    _taskController.text = task.title;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar tarea'),
        content: TextField(
          controller: _taskController,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Nuevo nombre de la tarea'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Guardar'),
            onPressed: () {
              final text = _taskController.text.trim();
              if (text.isNotEmpty) {
                context.read<TaskProvider>().editTask(task, text);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tareas'),
        centerTitle: true,
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No hay tareas aún.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (_) => taskProvider.toggleTask(task),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditTaskDialog(context, task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => taskProvider.deleteTask(task),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
