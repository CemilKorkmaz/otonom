class TowTruckOperator {
  final String id;
  final String companyName;
  final String driverName;
  final String plateNumber;
  final String phoneNumber;
  final String truckType; // Kayar Kasa / Gözlü Çekici / Kapalı VIP EV Kurtarıcı
  final double distanceKm;
  final int etaMinutes;
  final double rating;
  final int completedJobs;
  final int baseFeeTry;
  final int perKmFeeTry;
  final bool supportsLowClearance;
  final bool supportsElectricFlatbed;
  final double mapX; // Normalized 0..1 interactive map coord
  final double mapY;
  final String district;

  const TowTruckOperator({
    required this.id,
    required this.companyName,
    required this.driverName,
    required this.plateNumber,
    required this.phoneNumber,
    required this.truckType,
    required this.distanceKm,
    required this.etaMinutes,
    required this.rating,
    required this.completedJobs,
    required this.baseFeeTry,
    required this.perKmFeeTry,
    required this.supportsLowClearance,
    required this.supportsElectricFlatbed,
    required this.mapX,
    required this.mapY,
    required this.district,
  });
}
