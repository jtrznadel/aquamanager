import 'package:aquamanager_frontend/models/fish.dart';
import 'package:aquamanager_frontend/services/api_service.dart';
import 'package:flutter/material.dart';

class AddFishDialog extends StatefulWidget {
  final int aquariumId;
  final Function(Fish) onFishAdded;

  const AddFishDialog({
    super.key,
    required this.aquariumId,
    required this.onFishAdded,
  });

  @override
  _AddFishDialogState createState() => _AddFishDialogState();
}

class _AddFishDialogState extends State<AddFishDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedHealth = 'good';
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final fish = Fish(
      name: _nameController.text,
      species: _speciesController.text,
      aquariumId: widget.aquariumId,
      age: _ageController.text.isEmpty ? null : int.tryParse(_ageController.text),
      health: _selectedHealth,
    );

    final newFish = await ApiService.addFish(fish);
    setState(() => isLoading = false);

    if (newFish != null) {
      widget.onFishAdded(newFish);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rybka została dodana!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Błąd podczas dodawania rybki'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj Rybkę'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nazwa/Imię rybki',
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Podaj nazwę rybki';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(
                  labelText: 'Gatunek',
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Podaj gatunek';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Wiek (opcjonalnie)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isNotEmpty ?? false) {
                    final age = int.tryParse(value!);
                    if (age == null || age < 0) {
                      return 'Podaj poprawny wiek';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedHealth,
                decoration: const InputDecoration(
                  labelText: 'Stan zdrowia',
                  prefixIcon: Icon(Icons.health_and_safety),
                ),
                items: const [
                  DropdownMenuItem(value: 'poor', child: Text('Słaby')),
                  DropdownMenuItem(value: 'fair', child: Text('Przeciętny')),
                  DropdownMenuItem(value: 'good', child: Text('Dobry')),
                  DropdownMenuItem(value: 'excellent', child: Text('Doskonały')),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedHealth = newValue;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
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
