import 'package:aquamanager_frontend/config/theme.dart';
import 'package:aquamanager_frontend/models/aquarium.dart';
import 'package:aquamanager_frontend/models/task.dart';
import 'package:aquamanager_frontend/widgets/add_task_dialog.dart';
import 'package:flutter/material.dart';

class CompactCalendarTab extends StatelessWidget {
  final Aquarium aquarium;
  final List<Task> tasks;
  final Function(Task) onTaskAdded;
  final Function(int) onTaskCompleted;

  const CompactCalendarTab({
    super.key,
    required this.aquarium,
    required this.tasks,
    required this.onTaskAdded,
    required this.onTaskCompleted,
  });

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        aquariumId: aquarium.id!,
        selectedDate: DateTime.now(),
        onTaskAdded: onTaskAdded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = tasks.where((task) => !task.isCompleted).toList();
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zadania (${pendingTasks.length} aktywnych)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddTaskDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(
                    'Dodaj',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (pendingTasks.isNotEmpty) ...[
                      _buildSectionHeader('Do zrobienia', pendingTasks.length,
                          AppColors.warning),
                      const SizedBox(height: 8),
                      ...pendingTasks
                          .map((task) => _buildCompactTaskCard(task, false)),
                      const SizedBox(height: 16),
                    ],
                    if (completedTasks.isNotEmpty) ...[
                      _buildSectionHeader('Ukończone', completedTasks.length,
                          AppColors.success),
                      const SizedBox(height: 8),
                      ...completedTasks
                          .map((task) => _buildCompactTaskCard(task, true)),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt,
              size: 40,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Brak zadań',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dodaj pierwsze zadanie dla akwarium!',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$title ($count)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTaskCard(Task task, bool isCompleted) {
    final isOverdue = !isCompleted && task.dueDate.isBefore(DateTime.now());
    final daysDiff = task.dueDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? AppColors.error.withOpacity(0.3)
              : isCompleted
                  ? AppColors.success.withOpacity(0.3)
                  : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Task type icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTaskTypeColor(task.taskType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTaskTypeIcon(task.taskType),
              color: _getTaskTypeColor(task.taskType),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  task.taskType,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isCompleted)
                GestureDetector(
                  onTap: () => onTaskCompleted(task.id!),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.success,
                      size: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                _formatDueDate(task.dueDate, daysDiff),
                style: TextStyle(
                  fontSize: 10,
                  color: isOverdue
                      ? AppColors.error
                      : isCompleted
                          ? AppColors.textSecondary
                          : AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTaskTypeColor(String taskType) {
    switch (taskType.toLowerCase()) {
      case 'feeding':
        return AppColors.warning;
      case 'cleaning':
        return AppColors.primaryBlue;
      case 'water_change':
        return AppColors.accentTeal;
      case 'testing':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTaskTypeIcon(String taskType) {
    switch (taskType.toLowerCase()) {
      case 'feeding':
        return Icons.restaurant;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'water_change':
        return Icons.water_drop;
      case 'testing':
        return Icons.science;
      default:
        return Icons.task;
    }
  }

  String _formatDueDate(DateTime dueDate, int daysDiff) {
    if (daysDiff == 0) return 'Dziś';
    if (daysDiff == 1) return 'Jutro';
    if (daysDiff == -1) return 'Wczoraj';
    if (daysDiff > 0) return '+${daysDiff}d';
    return '${daysDiff}d';
  }
}
