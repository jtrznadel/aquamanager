import 'package:aquamanager_frontend/models/aquarium.dart';
import 'package:aquamanager_frontend/models/fish.dart';
import 'package:aquamanager_frontend/widgets/add_fish_dialog.dart';
import 'package:flutter/material.dart';

class FishTab extends StatelessWidget {
  final Aquarium aquarium;
  final List<Fish> fishList;
  final Function(Fish) onFishAdded;

  const FishTab({
    super.key,
    required this.aquarium,
    required this.fishList,
    required this.onFishAdded,
  });

  void _showAddFishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddFishDialog(
        aquariumId: aquarium.id!,
        onFishAdded: onFishAdded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Database Rybek',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddFishDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Dodaj Rybkę'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fish List
          Expanded(
            child: fishList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Brak rybek',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Dodaj swoje pierwsze rybki!',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: fishList.length,
                    itemBuilder: (context, index) {
                      final fish = fishList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Icon(Icons.pets, color: Colors.blue[600]),
                          ),
                          title: Text(
                            fish.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gatunek: ${fish.species}'),
                              if (fish.age != null)
                                Text('Wiek: ${fish.age} lat'),
                              Text('Zdrowie: ${fish.health}'),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
