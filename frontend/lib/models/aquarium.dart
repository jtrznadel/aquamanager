class Aquarium {
  final int? id;
  final String name;
  final int lengthCm;
  final int widthCm;
  final int heightCm;
  final int volumeLiters;
  final DateTime? createdAt;

  Aquarium({
    this.id,
    required this.name,
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
    required this.volumeLiters,
    this.createdAt,
  });

  factory Aquarium.fromJson(Map<String, dynamic> json) {
    return Aquarium(
      id: json['id'],
      name: json['name'],
      lengthCm: json['length_cm'],
      widthCm: json['width_cm'],
      heightCm: json['height_cm'],
      volumeLiters: json['volume_liters'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'length_cm': lengthCm,
      'width_cm': widthCm,
      'height_cm': heightCm,
      'volume_liters': volumeLiters,
    };
  }
}
