import 'package:aquamanager_frontend/models/aquarium.dart';
import 'package:aquamanager_frontend/models/task.dart';
import 'package:aquamanager_frontend/services/api_service.dart';
import 'package:aquamanager_frontend/widgets/add_task_dialog.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarTab extends StatefulWidget {
  final Aquarium aquarium;
  final List<Task> tasks;
  final Function(Task) onTaskAdded;
  final Function(int) onTaskCompleted;

  const CalendarTab({
    super.key,
    required this.aquarium,
    required this.tasks,
    required this.onTaskAdded,
    required this.onTaskCompleted,
  });

  @override
  _CalendarTabState createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  List<Task> _getTasksForDay(DateTime day) {
    return widget.tasks.where((task) {
      return isSameDay(task.dueDate, day);
    }).toList();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        aquariumId: widget.aquarium.id!,
        selectedDate: _selectedDay,
        onTaskAdded: widget.onTaskAdded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksForSelectedDay = _getTasksForDay(_selectedDay);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kalendarz Zadań',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddTaskDialog,
                icon: const Icon(Icons.add),
                label: const Text('Dodaj Zadanie'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Calendar
          TableCalendar<Task>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getTasksForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue[400],
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue[600],
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.orange[600],
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tasks for selected day
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zadania na ${_selectedDay.day}.${_selectedDay.month}.${_selectedDay.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: tasksForSelectedDay.isEmpty
                      ? Center(
                          child: Text(
                            'Brak zadań na ten dzień',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: tasksForSelectedDay.length,
                          itemBuilder: (context, index) {
                            final task = tasksForSelectedDay[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Checkbox(
                                  value: task.isCompleted,
                                  onChanged: task.isCompleted
                                      ? null
                                      : (value) async {
                                          if (value == true) {
                                            final success =
                                                await ApiService.completeTask(
                                                    task.id!);
                                            if (success) {
                                              widget.onTaskCompleted(task.id!);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Zadanie wykonane!')),
                                              );
                                            }
                                          }
                                        },
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Text(_getTaskTypeText(task.taskType)),
                                trailing: task.isCompleted
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : const Icon(Icons.circle_outlined,
                                        color: Colors.grey),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTaskTypeText(String taskType) {
    switch (taskType) {
      case 'water_change':
        return 'Wymiana wody';
      case 'feeding':
        return 'Karmienie';
      case 'cleaning':
        return 'Czyszczenie';
      case 'testing':
        return 'Testowanie parametrów';
      case 'maintenance':
        return 'Konserwacja';
      default:
        return taskType;
    }
  }
}
