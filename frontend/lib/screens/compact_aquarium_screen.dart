import 'package:aquamanager_frontend/config/theme.dart';
import 'package:aquamanager_frontend/models/aquarium.dart';
import 'package:aquamanager_frontend/models/fish.dart';
import 'package:aquamanager_frontend/models/task.dart';
import 'package:aquamanager_frontend/services/api_service.dart';
import 'package:aquamanager_frontend/widgets/compact_fish_tab.dart';
import 'package:aquamanager_frontend/widgets/compact_calendar_tab.dart';
import 'package:flutter/material.dart';

class CompactAquariumScreen extends StatefulWidget {
  final Aquarium aquarium;

  const CompactAquariumScreen({super.key, required this.aquarium});

  @override
  _CompactAquariumScreenState createState() => _CompactAquariumScreenState();
}

class _CompactAquariumScreenState extends State<CompactAquariumScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<Fish> fishList = [];
  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final fish = await ApiService.getFish(widget.aquarium.id!);
    final taskList = await ApiService.getTasks(widget.aquarium.id!);
    setState(() {
      fishList = fish;
      tasks = taskList;
      isLoading = false;
    });
    _animationController.forward();
  }

  Color _getWaterTypeColor() {
    switch (widget.aquarium.waterType.toLowerCase()) {
      case 'saltwater':
        return AppColors.accentTeal;
      case 'freshwater':
        return AppColors.primaryBlue;
      case 'brackish':
        return AppColors.success;
      default:
        return AppColors.primaryBlue;
    }
  }

  String _getWaterTypeIcon() {
    switch (widget.aquarium.waterType.toLowerCase()) {
      case 'saltwater':
        return '🌊';
      case 'freshwater':
        return '💧';
      case 'brackish':
        return '🌿';
      default:
        return '💧';
    }
  }

  Widget _buildCompactStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final waterTypeColor = _getWaterTypeColor();
    
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Compact Header
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          waterTypeColor,
                          waterTypeColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top row with back button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getWaterTypeIcon(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Aquarium info
                            Column(
                              children: [
                                Text(
                                  widget.aquarium.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        widget.aquarium.waterType,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${widget.aquarium.capacity.toStringAsFixed(0)}L',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Compact Stats Row
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCompactStatCard(
                          'Ryby',
                          '${fishList.length}',
                          Icons.pets,
                          AppColors.accentTeal,
                        ),
                        _buildCompactStatCard(
                          'Temp',
                          widget.aquarium.temperature != null
                              ? '${widget.aquarium.temperature!.toStringAsFixed(1)}°C'
                              : '--',
                          Icons.thermostat,
                          AppColors.primaryBlue,
                        ),
                        _buildCompactStatCard(
                          'pH',
                          widget.aquarium.ph != null
                              ? '${widget.aquarium.ph!.toStringAsFixed(1)}'
                              : '--',
                          Icons.science,
                          AppColors.success,
                        ),
                        _buildCompactStatCard(
                          'Zadania',
                          '${tasks.where((t) => !t.isCompleted).length}',
                          Icons.task_alt,
                          AppColors.warning,
                        ),
                      ],
                    ),
                  ),

                  // Compact Tab Bar
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: waterTypeColor,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: waterTypeColor,
                      indicatorWeight: 2,
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.pets, size: 18),
                          text: 'Ryby',
                        ),
                        Tab(
                          icon: Icon(Icons.calendar_today, size: 18),
                          text: 'Zadania',
                        ),
                        Tab(
                          icon: Icon(Icons.analytics, size: 18),
                          text: 'Parametry',
                        ),
                      ],
                    ),
                  ),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        CompactFishTab(
                          aquarium: widget.aquarium,
                          fishList: fishList,
                          onFishAdded: (fish) {
                            setState(() {
                              fishList.add(fish);
                            });
                          },
                        ),
                        CompactCalendarTab(
                          aquarium: widget.aquarium,
                          tasks: tasks,
                          onTaskAdded: (task) {
                            setState(() {
                              tasks.add(task);
                            });
                          },
                          onTaskCompleted: (taskId) async {
                            try {
                              await ApiService.completeTask(taskId);
                              setState(() {
                                final taskIndex = tasks.indexWhere((t) => t.id == taskId);
                                if (taskIndex != -1) {
                                  tasks[taskIndex] = Task(
                                    id: tasks[taskIndex].id,
                                    title: tasks[taskIndex].title,
                                    taskType: tasks[taskIndex].taskType,
                                    dueDate: tasks[taskIndex].dueDate,
                                    isCompleted: true,
                                    aquariumId: tasks[taskIndex].aquariumId,
                                  );
                                }
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Błąd przy aktualizacji zadania: $e')),
                              );
                            }
                          },
                        ),
                        ParametersTab(aquarium: widget.aquarium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Simple Parameters Tab Widget
class ParametersTab extends StatelessWidget {
  final Aquarium aquarium;

  const ParametersTab({super.key, required this.aquarium});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildParameterCard(
            'Temperatura',
            aquarium.temperature?.toStringAsFixed(1) ?? '--',
            '°C',
            Icons.thermostat,
            AppColors.primaryBlue,
          ),
          const SizedBox(height: 12),
          _buildParameterCard(
            'pH',
            aquarium.ph?.toStringAsFixed(1) ?? '--',
            '',
            Icons.science,
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildParameterCard(
            'Pojemność',
            aquarium.capacity.toStringAsFixed(0),
            'L',
            Icons.water,
            AppColors.accentTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$value$unit',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
