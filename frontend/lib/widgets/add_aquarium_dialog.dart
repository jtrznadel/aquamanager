import 'package:aquamanager_frontend/models/aquarium.dart';
import 'package:aquamanager_frontend/services/api_service.dart';
import 'package:flutter/material.dart';

class AddAquariumDialog extends StatefulWidget {
  final Function(Aquarium) onAquariumAdded;

  const AddAquariumDialog({super.key, required this.onAquariumAdded});

  @override
  _AddAquariumDialogState createState() => _AddAquariumDialogState();
}

class _AddAquariumDialogState extends State<AddAquariumDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _phController = TextEditingController();
  String _selectedWaterType = 'freshwater';
  bool isLoading = false;

  @override
  void dispose() {
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
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas dodawania akwarium')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj Nowe Akwarium'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nazwa akwarium',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Podaj nazwę akwarium';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Pojemność (L)',
                  prefixIcon: Icon(Icons.water_drop),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Podaj pojemność akwarium';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Podaj prawidłową liczbę';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedWaterType,
                decoration: const InputDecoration(
                  labelText: 'Typ wody',
                  prefixIcon: Icon(Icons.waves),
                ),
                items: const [
                  DropdownMenuItem(value: 'freshwater', child: Text('Słodka')),
                  DropdownMenuItem(value: 'saltwater', child: Text('Słona')),
                  DropdownMenuItem(value: 'brackish', child: Text('Słonawa')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedWaterType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _temperatureController,
                decoration: const InputDecoration(
                  labelText: 'Temperatura (°C) - opcjonalne',
                  prefixIcon: Icon(Icons.thermostat),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isNotEmpty == true &&
                      double.tryParse(value!) == null) {
                    return 'Podaj prawidłową temperaturę';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phController,
                decoration: const InputDecoration(
                  labelText: 'pH - opcjonalne',
                  prefixIcon: Icon(Icons.science),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isNotEmpty == true &&
                      double.tryParse(value!) == null) {
                    return 'Podaj prawidłową wartość pH';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _submitForm,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Dodaj'),
        ),
      ],
    );
  }
}
