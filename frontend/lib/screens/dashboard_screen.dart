import 'package:aquamanager_frontend/models/aquarium.dart';
import 'package:aquamanager_frontend/screens/aquarium_screen.dart';
import 'package:aquamanager_frontend/services/api_service.dart';
import 'package:aquamanager_frontend/widgets/add_aquarium_dialog.dart';
import 'package:aquamanager_frontend/widgets/aquarium_card.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Aquarium> aquariums = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAquariums();
  }

  Future<void> loadAquariums() async {
    setState(() => isLoading = true);
    final loadedAquariums = await ApiService.getAquariums();
    setState(() {
      aquariums = loadedAquariums;
      isLoading = false;
    });
  }

  void _showAddAquariumDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAquariumDialog(
        onAquariumAdded: (newAquarium) {
          setState(() {
            aquariums.add(newAquarium);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐠 AquaManager Dashboard'),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Moje Akwaria',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Add Aquarium Button
                  ElevatedButton.icon(
                    onPressed: _showAddAquariumDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Dodaj Nowe Akwarium'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Aquarium Grid
                  Expanded(
                    child: aquariums.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Brak akwariów',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Dodaj swoje pierwsze akwarium!',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  MediaQuery.of(context).size.width > 800
                                      ? 3
                                      : 2,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: aquariums.length,
                            itemBuilder: (context, index) {
                              final aquarium = aquariums[index];
                              return AquariumCard(
                                aquarium: aquarium,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AquariumScreen(aquarium: aquarium),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
