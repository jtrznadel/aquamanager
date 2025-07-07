import 'package:aquamanager_frontend/config/theme.dart';
import 'package:aquamanager_frontend/models/aquarium.dart';
import 'package:aquamanager_frontend/models/fish.dart';
import 'package:aquamanager_frontend/models/task.dart';
import 'package:aquamanager_frontend/services/api_service.dart';
import 'package:aquamanager_frontend/widgets/fish_tab.dart';
import 'package:aquamanager_frontend/widgets/calendar_tab.dart';
import 'package:flutter/material.dart';

class ModernAquariumScreen extends StatefulWidget {
  final Aquarium aquarium;

  const ModernAquariumScreen({super.key, required this.aquarium});

  @override
  _ModernAquariumScreenState createState() => _ModernAquariumScreenState();
}

class _ModernAquariumScreenState extends State<ModernAquariumScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<Fish> fishList = [];
  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
              child: CustomScrollView(
                slivers: [
                  // Hero App Bar
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            waterTypeColor,
                            waterTypeColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: FlexibleSpaceBar(
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getWaterTypeIcon(),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.aquarium.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        centerTitle: true,
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                waterTypeColor,
                                waterTypeColor.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(height: 80),
                                // Aquarium Stats
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatItem(
                                      Icons.water,
                                      '${widget.aquarium.capacity.toStringAsFixed(0)}L',
                                      'Pojemność',
                                    ),
                                    _buildStatItem(
                                      Icons.pets,
                                      '${fishList.length}',
                                      'Ryby',
                                    ),
                                    _buildStatItem(
                                      Icons.task_alt,
                                      '${tasks.where((t) => !t.isCompleted).length}',
                                      'Zadania',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Parameters Row
                                if (widget.aquarium.temperature != null || 
                                    widget.aquarium.ph != null)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (widget.aquarium.temperature != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.thermostat,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${widget.aquarium.temperature!.toStringAsFixed(1)}°C',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      if (widget.aquarium.temperature != null && 
                                          widget.aquarium.ph != null)
                                        const SizedBox(width: 12),
                                      if (widget.aquarium.ph != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.science,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'pH ${widget.aquarium.ph!.toStringAsFixed(1)}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tab Bar
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        indicatorColor: waterTypeColor,
                        labelColor: waterTypeColor,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.pets),
                            text: 'Ryby',
                          ),
                          Tab(
                            icon: Icon(Icons.calendar_today),
                            text: 'Zadania',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab View Content
                  SliverFillRemaining(
                    child: Container(
                      color: AppColors.surfaceLight,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          FishTab(
                            aquarium: widget.aquarium,
                            fishList: fishList,
                            onFishAdded: (fish) {
                              setState(() {
                                fishList.add(fish);
                              });
                            },
                          ),
                          CalendarTab(
                            aquarium: widget.aquarium,
                            tasks: tasks,
                            onTaskAdded: (task) {
                              setState(() {
                                tasks.add(task);
                              });
                            },
                            onTaskCompleted: (taskId) {
                              setState(() {
                                final index = tasks.indexWhere((t) => t.id == taskId);
                                if (index != -1) {
                                  tasks[index] = Task(
                                    id: tasks[index].id,
                                    title: tasks[index].title,
                                    taskType: tasks[index].taskType,
                                    dueDate: tasks[index].dueDate,
                                    isCompleted: true,
                                    aquariumId: tasks[index].aquariumId,
                                  );
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
