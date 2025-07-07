class Aquarium {
  final int? id;
  final String name;
  final double capacity;
  final String waterType;
  final double? temperature;
  final double? ph;
  final int fishCount;
  final String status;
  final DateTime? createdAt;

  Aquarium({
    this.id,
    required this.name,
    required this.capacity,
    required this.waterType,
    this.temperature,
    this.ph,
    this.fishCount = 0,
    this.status = 'healthy',
    this.createdAt,
  });

  factory Aquarium.fromJson(Map<String, dynamic> json) {
    return Aquarium(
      id: json['id'],
      name: json['name'],
      capacity: _parseDouble(json['capacity']),
      waterType: json['waterType'] ?? 'freshwater',
      temperature: _parseDouble(json['temperature']),
      ph: _parseDouble(json['ph']),
      fishCount: json['fishCount'] ?? 0,
      status: json['status'] ?? 'healthy',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'capacity': capacity,
      'waterType': waterType,
      'temperature': temperature,
      'ph': ph,
      'status': status,
    };
  }
}
