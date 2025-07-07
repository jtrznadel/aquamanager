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
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final fish = Fish(
      name: _nameController.text,
      species: _speciesController.text,
      quantity: int.parse(_quantityController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      aquariumId: widget.aquariumId,
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
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Ilość',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Wymagane';
                  final quantity = int.tryParse(value!);
                  if (quantity == null || quantity <= 0) {
                    return 'Podaj poprawną ilość';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notatki (opcjonalne)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
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
