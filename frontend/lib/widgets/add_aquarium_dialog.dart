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
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  int get calculatedVolume {
    try {
      final length = int.parse(_lengthController.text);
      final width = int.parse(_widthController.text);
      final height = int.parse(_heightController.text);
      return (length * width * height / 1000).round();
    } catch (e) {
      return 0;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final aquarium = Aquarium(
      name: _nameController.text,
      lengthCm: int.parse(_lengthController.text),
      widthCm: int.parse(_widthController.text),
      heightCm: int.parse(_heightController.text),
      volumeLiters: calculatedVolume,
    );

    final newAquarium = await ApiService.createAquarium(aquarium);
    setState(() => isLoading = false);

    if (newAquarium != null) {
      widget.onAquariumAdded(newAquarium);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akwarium zostało dodane!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Błąd podczas dodawania akwarium'),
          backgroundColor: Colors.red,
        ),
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lengthController,
                      decoration: const InputDecoration(
                        labelText: 'Długość (cm)',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Wymagane';
                        if (int.tryParse(value!) == null) return 'Liczba';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _widthController,
                      decoration: const InputDecoration(
                        labelText: 'Szerokość (cm)',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Wymagane';
                        if (int.tryParse(value!) == null) return 'Liczba';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Wysokość (cm)',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Wymagane';
                        if (int.tryParse(value!) == null) return 'Liczba';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('Objętość', style: TextStyle(fontSize: 12)),
                        Text(
                          '${calculatedVolume}L',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
