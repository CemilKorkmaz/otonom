import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_automotive_catalog.dart';
import '../models/brand_theme_config.dart';
import '../models/vehicle_spec.dart';
import '../models/route_station.dart';
import '../services/dynamic_icon_service.dart';

class OtonomAppState extends ChangeNotifier {
  VehicleSpec _selectedVehicle = AutomotiveCatalog.vehicles.first; // Default: Tesla Model Y
  NavigationCorridor _activeCorridor = AutomotiveCatalog.routes.first;
  bool _isNavigating = true;
  double _routeProgress = 0.14;
  final Set<String> _addedWaypointStationIds = {};

  String _driverName = 'Cemil & Ağabeyi';
  String _userPlate = '34 OTN 001';
  String _bloodType = 'A Rh (+)';
  String _emergencyContact = '+90 532 100 00 00';
  int _currentSocOrFuelPercent = 84;
  bool _lastDynamicIconSynced = true;

  VehicleSpec get selectedVehicle => _selectedVehicle;

  BrandThemeConfig get brandTheme =>
      AutomotiveCatalog.brandThemes[_selectedVehicle.brandId] ??
      AutomotiveCatalog.brandThemes[CarBrandId.tesla]!;

  NavigationCorridor get activeCorridor => _activeCorridor;
  bool get isNavigating => _isNavigating;
  double get routeProgress => _routeProgress;
  Set<String> get addedWaypointStationIds => _addedWaypointStationIds;

  String get driverName => _driverName;
  String get userPlate => _userPlate;
  String get bloodType => _bloodType;
  String get emergencyContact => _emergencyContact;
  int get currentSocOrFuelPercent => _currentSocOrFuelPercent;
  bool get lastDynamicIconSynced => _lastDynamicIconSynced;

  bool get isElectricVehicle => _selectedVehicle.powertrain.isElectric;

  /// Automatically returns EV charging stations if the user's selected car is Electric,
  /// or Gasoline/Diesel stations if the user's car is an internal combustion vehicle!
  List<RouteStation> get relevantRouteStations {
    final targetCategory = isElectricVehicle
        ? StationCategory.evCharger
        : StationCategory.fuelStation;
    final list = _activeCorridor.stations
        .where((s) => s.category == targetCategory)
        .toList();
    list.sort((a, b) => a.distanceAlongRouteKm.compareTo(b.distanceAlongRouteKm));
    return list;
  }

  Future<void> loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVehicleId = prefs.getString('selected_vehicle_id');
      if (savedVehicleId != null) {
        final match = AutomotiveCatalog.vehicles
            .where((v) => v.id == savedVehicleId)
            .toList();
        if (match.isNotEmpty) {
          _selectedVehicle = match.first;
        }
      }
      _userPlate = prefs.getString('user_plate') ?? _userPlate;
      _bloodType = prefs.getString('blood_type') ?? _bloodType;
      notifyListeners();
    } catch (_) {
      // Ignore storage errors in headless tests
    }
  }

  Future<void> selectGarageVehicle(VehicleSpec vehicle) async {
    _selectedVehicle = vehicle;
    _addedWaypointStationIds.clear();
    notifyListeners();

    final theme = brandTheme;
    _lastDynamicIconSynced =
        await DynamicIconService.setBrandAppIcon(theme.dynamicIconKey);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_vehicle_id', vehicle.id);
    } catch (_) {}
    notifyListeners();
  }

  void selectCorridor(NavigationCorridor corridor) {
    _activeCorridor = corridor;
    _routeProgress = 0.08;
    _addedWaypointStationIds.clear();
    notifyListeners();
  }

  void toggleNavigation() {
    _isNavigating = !_isNavigating;
    notifyListeners();
  }

  void updateRouteProgress(double value) {
    _routeProgress = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void toggleWaypointStation(String stationId) {
    if (_addedWaypointStationIds.contains(stationId)) {
      _addedWaypointStationIds.remove(stationId);
    } else {
      _addedWaypointStationIds.add(stationId);
    }
    notifyListeners();
  }

  Future<void> updateEmergencyProfile({
    required String driverName,
    required String plate,
    required String bloodType,
    required String emergencyContact,
  }) async {
    _driverName = driverName;
    _userPlate = plate;
    _bloodType = bloodType;
    _emergencyContact = emergencyContact;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_plate', plate);
      await prefs.setString('blood_type', bloodType);
    } catch (_) {}
  }

  void updateSocOrFuelPercent(int value) {
    _currentSocOrFuelPercent = value.clamp(5, 100);
    notifyListeners();
  }
}
