class Fish {
  final int? id;
  final String name;
  final String species;
  final int aquariumId;
  final int? age;
  final String health;
  final DateTime? createdAt;

  Fish({
    this.id,
    required this.name,
    required this.species,
    required this.aquariumId,
    this.age,
    this.health = 'good',
    this.createdAt,
  });

  factory Fish.fromJson(Map<String, dynamic> json) {
    return Fish(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      aquariumId: json['aquariumId'],
      age: json['age'],
      health: json['health'] ?? 'good',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'aquariumId': aquariumId,
      'age': age,
      'health': health,
    };
  }
}
