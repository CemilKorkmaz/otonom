import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_automotive_catalog.dart';
import '../models/brand_theme_config.dart';
import '../models/live_api_models.dart';
import '../models/route_station.dart';
import '../models/vehicle_spec.dart';
import '../services/dynamic_icon_service.dart';
import '../services/live_apis_service.dart';

class OtonomAppState extends ChangeNotifier {
  final LiveApisService liveApis = LiveApisService();

  VehicleSpec _selectedVehicle = AutomotiveCatalog.vehicles.first;
  NavigationCorridor _activeCorridor = AutomotiveCatalog.routes.first;
  bool _isNavigating = true;
  double _routeProgress = 0.14;
  final Set<String> _addedWaypointStationIds = {};

  // Live Geolocation, Weather, Routing & Overpass POIs
  LatLng _currentLocation = const LatLng(40.9903, 29.0292);
  String _locationSource = 'Başlatılıyor...';
  String _liveStreetAddress = 'Canlı adres çözümleniyor...';
  LiveRoadWeather? _liveWeather;

  LatLng _destinationPoint = const LatLng(40.7654, 29.9408); // İzmit/Sapanca yönü varsayılan
  String _destinationName = 'Kocaeli / Sapanca Otoyol Aksı';
  LiveOsrmRoute? _liveRoute;

  List<LivePoiItem> _liveRouteStations = [];
  List<LivePoiItem> _liveTowRepairs = [];
  List<LivePoiItem> _liveRentalPlaces = [];
  bool _isLoadingLive = false;
  bool _darkMapTiles = true;

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

  LatLng get currentLocation => _currentLocation;
  String get locationSource => _locationSource;
  String get liveStreetAddress => _liveStreetAddress;
  LiveRoadWeather? get liveWeather => _liveWeather;
  LatLng get destinationPoint => _destinationPoint;
  String get destinationName => _destinationName;
  LiveOsrmRoute? get liveRoute => _liveRoute;
  List<LivePoiItem> get liveRouteStations => _liveRouteStations;
  List<LivePoiItem> get liveTowRepairs => _liveTowRepairs;
  List<LivePoiItem> get liveRentalPlaces => _liveRentalPlaces;
  bool get isLoadingLive => _isLoadingLive;
  bool get darkMapTiles => _darkMapTiles;

  String get driverName => _driverName;
  String get userPlate => _userPlate;
  String get bloodType => _bloodType;
  String get emergencyContact => _emergencyContact;
  int get currentSocOrFuelPercent => _currentSocOrFuelPercent;
  bool get lastDynamicIconSynced => _lastDynamicIconSynced;

  bool get isElectricVehicle => _selectedVehicle.powertrain.isElectric;

  int get onlineApiCount =>
      liveApis.statuses.values.where((s) => s.online).length;

  /// Offline/curated fallback stations when user has no internet
  List<RouteStation> get relevantRouteStations {
    final targetCategory = isElectricVehicle
        ? StationCategory.evCharger
        : StationCategory.fuelStation;
    final list = _activeCorridor.stations
        .where((s) => s.category == targetCategory)
        .toList();
    list.sort(
      (a, b) => a.distanceAlongRouteKm.compareTo(b.distanceAlongRouteKm),
    );
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
    } catch (_) {}
  }

  /// Connects to GPS/GeoJS, Nominatim, Open-Meteo, OSRM & Overpass APIs live!
  Future<void> refreshAllLiveApis() async {
    if (_isLoadingLive) return;
    _isLoadingLive = true;
    notifyListeners();

    try {
      final loc = await liveApis.resolveCurrentLocation();
      _currentLocation = loc.point;
      _locationSource = loc.source;
      notifyListeners();

      // Run Reverse Geocoding, Weather & OSRM Routing in parallel
      final addrFuture = liveApis.reverseGeocodeAddress(_currentLocation);
      final weatherFuture = liveApis.fetchRoadWeather(_currentLocation);
      final routeFuture =
          liveApis.fetchDrivingRoute(_currentLocation, _destinationPoint);

      final results = await Future.wait([addrFuture, weatherFuture, routeFuture]);
      _liveStreetAddress = results[0] as String;
      _liveWeather = results[1] as LiveRoadWeather?;
      _liveRoute = results[2] as LiveOsrmRoute?;
      notifyListeners();

      // Fetch live Overpass POIs for EV/Fuel stations, Tow/Repair, and Car Rentals
      await _refreshStationPoisOnly();
      final towFuture = liveApis.fetchNearbyAutomotivePois(
        center: _currentLocation,
        category: 'tow_repair',
        radiusMeters: 10000,
      );
      final rentFuture = liveApis.fetchNearbyAutomotivePois(
        center: _currentLocation,
        category: 'car_rental',
        radiusMeters: 15000,
      );
      final poiResults = await Future.wait([towFuture, rentFuture]);
      _liveTowRepairs = poiResults[0];
      _liveRentalPlaces = poiResults[1];
    } catch (_) {
      // Graceful fallback preserved
    } finally {
      _isLoadingLive = false;
      notifyListeners();
    }
  }

  Future<void> _refreshStationPoisOnly() async {
    final cat = isElectricVehicle ? 'ev' : 'fuel';
    _liveRouteStations = await liveApis.fetchNearbyAutomotivePois(
      center: _currentLocation,
      category: cat,
      sampleAlongPolyline: _liveRoute?.polyline ?? const [],
      radiusMeters: 15000,
    );
    notifyListeners();
  }

  Future<void> setLiveDestination(LivePlaceSearchResult dest) async {
    _destinationPoint = dest.point;
    _destinationName = dest.shortName;
    _isLoadingLive = true;
    notifyListeners();

    try {
      _liveRoute =
          await liveApis.fetchDrivingRoute(_currentLocation, _destinationPoint);
      await _refreshStationPoisOnly();
    } finally {
      _isLoadingLive = false;
      notifyListeners();
    }
  }

  void toggleMapTileStyle() {
    _darkMapTiles = !_darkMapTiles;
    notifyListeners();
  }

  Future<void> selectGarageVehicle(VehicleSpec vehicle) async {
    final previousIsEv = isElectricVehicle;
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

    if (previousIsEv != isElectricVehicle) {
      await _refreshStationPoisOnly();
    }
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
