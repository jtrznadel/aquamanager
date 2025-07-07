import 'package:aquamanager_frontend/config/theme.dart';
import 'package:aquamanager_frontend/models/aquarium.dart';
import 'package:aquamanager_frontend/screens/compact_aquarium_screen.dart';
import 'package:aquamanager_frontend/services/api_service.dart';
import 'package:aquamanager_frontend/widgets/modern_add_aquarium_dialog.dart';
import 'package:aquamanager_frontend/widgets/modern_aquarium_card.dart';
import 'package:aquamanager_frontend/widgets/stats_card.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  List<Aquarium> aquariums = [];
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    loadAquariums();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadAquariums() async {
    setState(() => isLoading = true);
    final loadedAquariums = await ApiService.getAquariums();
    setState(() {
      aquariums = loadedAquariums;
      isLoading = false;
    });
    _animationController.forward();
  }

  void _showAddAquariumDialog() {
    showDialog(
      context: context,
      builder: (context) => ModernAddAquariumDialog(
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
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: Container(
                      decoration: const BoxDecoration(
                        gradient: AppGradients.primaryGradient,
                      ),
                      child: FlexibleSpaceBar(
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.waves,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'AquaManager Pro',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        centerTitle: true,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Witaj z powrotem! 👋',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Zarządzaj swoimi akwariami w jednym miejscu',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.dashboard,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          Row(
                            children: [
                              Expanded(
                                child: StatsCard(
                                  title: 'Akwaria',
                                  value: aquariums.length.toString(),
                                  icon: Icons.water_drop,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: StatsCard(
                                  title: 'Ryby',
                                  value: aquariums
                                      .fold(0, (sum, a) => sum + a.fishCount)
                                      .toString(),
                                  icon: Icons.pets,
                                  color: AppColors.accentTeal,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: StatsCard(
                                  title: 'Pojemność',
                                  value:
                                      '${aquariums.fold(0.0, (sum, a) => sum + a.capacity).toStringAsFixed(0)}L',
                                  icon: Icons.water,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Moje Akwaria',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: AppGradients.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _showAddAquariumDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Dodaj Akwarium'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Aquariums Grid
                          if (aquariums.isEmpty)
                            _buildEmptyState()
                          else
                            _buildAquariumsGrid(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.water_drop_outlined,
              size: 64,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Brak akwariów',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Rozpocznij swoją podwodną przygodę, dodając pierwsze akwarium!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddAquariumDialog,
            icon: const Icon(Icons.add),
            label: const Text('Dodaj Pierwsze Akwarium'),
          ),
        ],
      ),
    );
  }

  Widget _buildAquariumsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid columns based on screen width
        int crossAxisCount = 2;
        if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }
        if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.4, // Compact ratio for new design
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: aquariums.length,
          itemBuilder: (context, index) {
            return ModernAquariumCard(
              aquarium: aquariums[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompactAquariumScreen(
                      aquarium: aquariums[index],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
