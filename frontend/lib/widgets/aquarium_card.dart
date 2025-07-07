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
                'Typ: ${aquarium.waterType}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'Pojemność: ${aquarium.capacity.toStringAsFixed(0)}L',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (aquarium.temperature != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Temperatura: ${aquarium.temperature!.toStringAsFixed(1)}°C',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
              if (aquarium.ph != null) ...[
                const SizedBox(height: 4),
                Text(
                  'pH: ${aquarium.ph!.toStringAsFixed(1)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.pets,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${aquarium.fishCount} ryb',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: aquarium.status == 'healthy'
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      aquarium.status == 'healthy' ? 'Zdrowe' : aquarium.status,
                      style: TextStyle(
                        color: aquarium.status == 'healthy'
                            ? Colors.green[700]
                            : Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
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
