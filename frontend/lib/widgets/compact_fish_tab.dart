import 'package:aquamanager_frontend/config/theme.dart';
import 'package:aquamanager_frontend/models/aquarium.dart';
import 'package:aquamanager_frontend/models/fish.dart';
import 'package:aquamanager_frontend/widgets/add_fish_dialog.dart';
import 'package:flutter/material.dart';

class CompactFishTab extends StatelessWidget {
  final Aquarium aquarium;
  final List<Fish> fishList;
  final Function(Fish) onFishAdded;

  const CompactFishTab({
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
                'Ryby (${fishList.length})',
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
                  onPressed: () => _showAddFishDialog(context),
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
          child: fishList.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: fishList.length,
                  itemBuilder: (context, index) {
                    final fish = fishList[index];
                    return _buildCompactFishCard(fish);
                  },
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
              Icons.pets,
              size: 40,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Brak rybek',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dodaj swoje pierwsze rybki!',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFishCard(Fish fish) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.pets,
              color: AppColors.accentTeal,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fish.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  fish.species,
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
              Text(
                '${fish.age ?? 0} lat',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                fish.health,
                style: TextStyle(
                  fontSize: 10,
                  color: fish.health.toLowerCase() == 'good'
                      ? AppColors.success
                      : AppColors.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
