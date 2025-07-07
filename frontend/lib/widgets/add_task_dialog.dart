import 'package:aquamanager_frontend/models/task.dart';
import 'package:aquamanager_frontend/services/api_service.dart';
import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  final int aquariumId;
  final DateTime selectedDate;
  final Function(Task) onTaskAdded;

  const AddTaskDialog({
    super.key,
    required this.aquariumId,
    required this.selectedDate,
    required this.onTaskAdded,
  });

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedTaskType = 'water_change';
  DateTime? _selectedDate;
  bool isLoading = false;

  final Map<String, String> taskTypes = {
    'water_change': 'Wymiana wody',
    'feeding': 'Karmienie',
    'cleaning': 'Czyszczenie',
    'testing': 'Testowanie parametrów',
    'maintenance': 'Konserwacja',
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final task = Task(
      title: _titleController.text,
      taskType: _selectedTaskType,
      dueDate: _selectedDate!,
      aquariumId: widget.aquariumId,
    );

    final newTask = await ApiService.addTask(task);
    setState(() => isLoading = false);

    if (newTask != null) {
      widget.onTaskAdded(newTask);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zadanie zostało dodane!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Błąd podczas dodawania zadania'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj Zadanie'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tytuł zadania',
                  prefixIcon: Icon(Icons.task),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Podaj tytuł zadania';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTaskType,
                decoration: const InputDecoration(
                  labelText: 'Typ zadania',
                  prefixIcon: Icon(Icons.category),
                ),
                items: taskTypes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedTaskType = value!);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Data wykonania'),
                subtitle: Text(
                  '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                ),
                leading: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate!,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _submitForm,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Dodaj'),
        ),
      ],
    );
  }
}
