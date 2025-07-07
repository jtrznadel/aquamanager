class Fish {
  final int? id;
  final String name;
  final String species;
  final int quantity;
  final String? notes;
  final int aquariumId;

  Fish({
    this.id,
    required this.name,
    required this.species,
    required this.quantity,
    this.notes,
    required this.aquariumId,
  });

  factory Fish.fromJson(Map<String, dynamic> json) {
    return Fish(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      quantity: json['quantity'],
      notes: json['notes'],
      aquariumId: json['aquarium_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'quantity': quantity,
      'notes': notes,
      'aquarium_id': aquariumId,
    };
  }
}
