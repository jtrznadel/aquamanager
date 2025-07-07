import 'package:aquamanager_frontend/config/theme.dart';
import 'package:aquamanager_frontend/models/aquarium.dart';
import 'package:aquamanager_frontend/services/api_service.dart';
import 'package:flutter/material.dart';

class ModernAddAquariumDialog extends StatefulWidget {
  final Function(Aquarium) onAquariumAdded;

  const ModernAddAquariumDialog({super.key, required this.onAquariumAdded});

  @override
  _ModernAddAquariumDialogState createState() => _ModernAddAquariumDialogState();
}

class _ModernAddAquariumDialogState extends State<ModernAddAquariumDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _phController = TextEditingController();
  String _selectedWaterType = 'freshwater';
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _capacityController.dispose();
    _temperatureController.dispose();
    _phController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final aquarium = Aquarium(
      name: _nameController.text,
      capacity: double.parse(_capacityController.text),
      waterType: _selectedWaterType,
      temperature: _temperatureController.text.isNotEmpty 
          ? double.parse(_temperatureController.text) 
          : null,
      ph: _phController.text.isNotEmpty 
          ? double.parse(_phController.text) 
          : null,
    );

    final newAquarium = await ApiService.createAquarium(aquarium);
    setState(() => isLoading = false);

    if (newAquarium != null) {
      widget.onAquariumAdded(newAquarium);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Błąd podczas dodawania akwarium'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Color _getWaterTypeColor() {
    switch (_selectedWaterType) {
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
    switch (_selectedWaterType) {
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 500,
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getWaterTypeColor(),
                          _getWaterTypeColor().withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getWaterTypeIcon(),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nowe Akwarium',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stwórz swój podwodny świat',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name Field
                            Text(
                              'Nazwa akwarium',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'np. Akwarium główne',
                                prefixIcon: Icon(
                                  Icons.label_outline,
                                  color: _getWaterTypeColor(),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Podaj nazwę akwarium';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Water Type Selection
                            Text(
                              'Typ wody',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildWaterTypeButton(
                                    'freshwater',
                                    'Słodka',
                                    '💧',
                                    AppColors.primaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildWaterTypeButton(
                                    'saltwater',
                                    'Słona',
                                    '🌊',
                                    AppColors.accentTeal,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildWaterTypeButton(
                                    'brackish',
                                    'Słonawa',
                                    '🌿',
                                    AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Capacity and Parameters
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pojemność (L)',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _capacityController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: '200',
                                          prefixIcon: Icon(
                                            Icons.water,
                                            color: _getWaterTypeColor(),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Podaj pojemność';
                                          }
                                          if (double.tryParse(value) == null) {
                                            return 'Nieprawidłowa pojemność';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Temperatura (°C)',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _temperatureController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: '25.0',
                                          prefixIcon: Icon(
                                            Icons.thermostat,
                                            color: _getWaterTypeColor(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // pH
                            Text(
                              'pH (opcjonalnie)',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '7.0',
                                prefixIcon: Icon(
                                  Icons.science,
                                  color: _getWaterTypeColor(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isLoading ? null : () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      side: BorderSide(color: _getWaterTypeColor()),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Anuluj',
                                      style: TextStyle(
                                        color: _getWaterTypeColor(),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _getWaterTypeColor(),
                                          _getWaterTypeColor().withOpacity(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _submitForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            )
                                          : const Text(
                                              'Dodaj Akwarium',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaterTypeButton(String type, String label, String emoji, Color color) {
    final isSelected = _selectedWaterType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWaterType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
