import 'brand_theme_config.dart';

class UserGarageVehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  final String trimOrEngine;
  final PowertrainType powertrain;
  final String plate;
  final int? customHp;
  final String transmission;
  final int? odometerKm;
  final String? vin;

  const UserGarageVehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.trimOrEngine = '',
    required this.powertrain,
    this.plate = '',
    this.customHp,
    this.transmission = '',
    this.odometerKm,
    this.vin,
  });

  String get trim => trimOrEngine;
  int? get horsepower => customHp;

  String get fullTitle =>
      '$year $make $model${trimOrEngine.isNotEmpty ? " $trimOrEngine" : ""}';

  String get shortTitle => '$make $model ($year)';

  Map<String, dynamic> toJson() => {
        'id': id,
        'make': make,
        'model': model,
        'year': year,
        'trimOrEngine': trimOrEngine,
        'powertrain': powertrain.name,
        'plate': plate,
        'customHp': customHp,
        'transmission': transmission,
        'odometerKm': odometerKm,
        'vin': vin,
      };

  factory UserGarageVehicle.fromJson(Map<String, dynamic> json) {
    final ptName = json['powertrain']?.toString() ?? 'gasoline';
    final pt = PowertrainType.values.firstWhere(
      (e) => e.name == ptName,
      orElse: () => PowertrainType.gasoline,
    );
    return UserGarageVehicle(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      make: json['make']?.toString() ?? 'Otomobil',
      model: json['model']?.toString() ?? 'Model',
      year: (json['year'] as num?)?.toInt() ?? 2023,
      trimOrEngine: json['trimOrEngine']?.toString() ?? '',
      powertrain: pt,
      plate: json['plate']?.toString() ?? '',
      customHp: (json['customHp'] as num?)?.toInt(),
      transmission: json['transmission']?.toString() ?? '',
      odometerKm: (json['odometerKm'] as num?)?.toInt(),
      vin: json['vin']?.toString(),
    );
  }
}
