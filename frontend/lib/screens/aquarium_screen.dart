import 'package:aquamanager_frontend/models/aquarium.dart';
import 'package:aquamanager_frontend/models/fish.dart';
import 'package:aquamanager_frontend/models/task.dart';
import 'package:aquamanager_frontend/services/api_service.dart';
import 'package:aquamanager_frontend/widgets/calendar_tab.dart';
import 'package:aquamanager_frontend/widgets/fish_tab.dart';
import 'package:flutter/material.dart';

class AquariumScreen extends StatefulWidget {
  final Aquarium aquarium;

  const AquariumScreen({super.key, required this.aquarium});

  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Fish> fishList = [];
  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🐠 ${widget.aquarium.name}'),
        backgroundColor: Colors.blue[600],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pets), text: 'Rybki'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Kalendarz'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                FishTab(
                  aquarium: widget.aquarium,
                  fishList: fishList,
                  onFishAdded: (newFish) {
                    setState(() => fishList.add(newFish));
                  },
                ),
                CalendarTab(
                  aquarium: widget.aquarium,
                  tasks: tasks,
                  onTaskAdded: (newTask) {
                    setState(() => tasks.add(newTask));
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
    );
  }
}
