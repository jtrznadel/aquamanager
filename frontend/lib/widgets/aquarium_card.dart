import 'package:aquamanager_frontend/models/aquarium.dart';
import 'package:flutter/material.dart';

class AquariumCard extends StatelessWidget {
  final Aquarium aquarium;
  final VoidCallback onTap;

  const AquariumCard({
    super.key,
    required this.aquarium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.water_drop, color: Colors.blue[600], size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      aquarium.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Wymiary: ${aquarium.lengthCm}×${aquarium.widthCm}×${aquarium.heightCm} cm',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'Objętość: ${aquarium.volumeLiters}L',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
