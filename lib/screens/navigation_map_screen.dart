import 'package:flutter/material.dart';
import '../data/mock_automotive_catalog.dart';
import '../models/brand_theme_config.dart';
import '../models/live_api_models.dart';
import '../services/emergency_service.dart';
import '../state/app_state.dart';
import '../widgets/live_osm_cockpit_map.dart';

class NavigationMapScreen extends StatefulWidget {
  final OtonomAppState appState;
  final VoidCallback onOpenTowQuick;
  final VoidCallback onOpen112Quick;

  const NavigationMapScreen({
    super.key,
    required this.appState,
    required this.onOpenTowQuick,
    required this.onOpen112Quick,
  });

  @override
  State<NavigationMapScreen> createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends State<NavigationMapScreen> {
  final TextEditingController _destSearchCtrl = TextEditingController();
  List<LivePlaceSearchResult> _searchResults = [];
  bool _searchingPlace = false;

  @override
  void dispose() {
    _destSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _runPlaceSearch() async {
    final q = _destSearchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _searchingPlace = true);
    final res = await widget.appState.liveApis.searchPlaces(q);
    if (mounted) {
      setState(() {
        _searchResults = res;
        _searchingPlace = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final theme = appState.brandTheme;
    final vehicle = appState.selectedVehicle;
    final isEv = appState.isElectricVehicle;
    final weather = appState.liveWeather;
    final osrm = appState.liveRoute;
    final livePois = appState.liveRouteStations;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Active Vehicle + Brand Switcher Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withValues(alpha: 0.26),
                theme.cardColor,
              ],
            ),
            border: Border.all(color: theme.primaryColor.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isEv ? '⚡ CANLI EV ŞARJ ROTASI' : '⛽ CANLI AKARYAKIT ROTASI',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (appState.isLoadingLive)
                    const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    InkWell(
                      onTap: appState.refreshAllLiveApis,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.gps_fixed_rounded,
                            size: 14,
                            color: Color(0xFF34D399),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appState.locationSource.split(' ').take(2).join(' '),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF34D399),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${vehicle.brandName} ${vehicle.modelName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '📍 Konum: ${appState.liveStreetAddress}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AutomotiveCatalog.vehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final v = AutomotiveCatalog.vehicles[index];
                    return ChoiceChip(
                      label: Text(
                        '${v.brandName} (${v.powertrain.isElectric ? "EV" : "Benzin"})',
                      ),
                      selected: v.id == vehicle.id,
                      onSelected: (_) => appState.selectGarageVehicle(v),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Live Open-Meteo Road & Weather Telemetry Strip
        if (weather != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.thermostat_rounded, size: 18, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 6),
                    Text(
                      'Canlı Yol Hava (Open-Meteo): ${weather.temperatureC.toStringAsFixed(1)}°C · ${weather.conditionTr}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  weather.drivingAdvisoryTr,
                  style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                ),
              ],
            ),
          ),

        // Emergency Quick Triggers
        Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.onOpenTowQuick,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFF231B0C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fire_truck_rounded, color: Color(0xFFFBBF24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'En Yakın Çekici',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              appState.liveTowRepairs.isNotEmpty
                                  ? '${appState.liveTowRepairs.first.distanceKm.toStringAsFixed(1)} km (Canlı OSM)'
                                  : 'Radar & Arama Ekranı',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFFDE68A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.onOpen112Quick,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B0B10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEF4444), width: 1.4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.sos_rounded, color: Color(0xFFF87171), size: 26),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACİL KAZA · 112',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Canlı Adres + 112 Ara',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFFECACA),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Live Nominatim Destination Search Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _destSearchCtrl,
                onSubmitted: (_) => _runPlaceSearch(),
                decoration: InputDecoration(
                  hintText: 'Hedef ara (Örn: Ankara, Taksim, Bursa, İzmir)...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: theme.primaryColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _searchingPlace ? null : _runPlaceSearch,
              child: Text(_searchingPlace ? '...' : 'Rota Bul'),
            ),
          ],
        ),

        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.primaryColor),
            ),
            child: Column(
              children: _searchResults
                  .map(
                    (place) => ListTile(
                      dense: true,
                      leading: Icon(Icons.place_rounded, color: theme.primaryColor),
                      title: Text(
                        place.shortName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        place.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Text('Seç →'),
                      onTap: () {
                        setState(() => _searchResults = []);
                        appState.setLiveDestination(place);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),

        const SizedBox(height: 12),

        // LIVE OPENSTREETMAP + OSRM POLYLINE + OVERPASS STATIONS
        SizedBox(
          height: 295,
          child: LiveOsmCockpitMap(
            userLocation: appState.currentLocation,
            destinationPoint: appState.destinationPoint,
            routePolyline: osrm?.polyline ?? const [],
            pois: livePois,
            accentColor: theme.primaryColor,
            darkTiles: appState.darkMapTiles,
            onToggleTileStyle: appState.toggleMapTileStyle,
            onRecenterGps: appState.refreshAllLiveApis,
            onPoiTap: (poi) => _showLivePoiSheet(context, poi),
          ),
        ),
        const SizedBox(height: 12),

        // Live OSRM Route Summary Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.alt_route_rounded, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hedef: ${appState.destinationName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  if (osrm != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${osrm.distanceKm.toStringAsFixed(1)} km · ${osrm.durationMinutes} dk',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              if (osrm != null && osrm.stepInstructions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'İlk Yönlendirme: ${osrm.stepInstructions.first}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF93C5FD)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),

        // LIVE OVERPASS STATIONS LIST
        Row(
          children: [
            Icon(
              isEv ? Icons.ev_station_rounded : Icons.local_gas_station_rounded,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isEv
                    ? 'Canlı Şarj İstasyonları (${livePois.length} Gerçek Nokta)'
                    : 'Canlı Akaryakıt İstasyonları (${livePois.length} Gerçek Nokta)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: 'Canlı İstasyonları Yenile',
              onPressed: appState.refreshAllLiveApis,
              icon: const Icon(Icons.refresh_rounded, size: 20),
            ),
          ],
        ),
        const Text(
          'OpenStreetMap Overpass API üzerinden gerçek GPS konumunuz ve OSRM yol güzergâhınız üzerindeki istasyonlar çekilmektedir.',
          style: TextStyle(fontSize: 11.5, color: Colors.white60),
        ),
        const SizedBox(height: 10),

        if (livePois.isNotEmpty)
          for (final poi in livePois)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: appState.addedWaypointStationIds.contains(poi.id)
                      ? theme.primaryColor
                      : Colors.white10,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${poi.distanceKm.toStringAsFixed(1)} km uzakta',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '🟢 Canlı OSM',
                        style: TextStyle(fontSize: 11, color: Color(0xFF34D399)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    poi.name,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    poi.subtitle,
                    style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                  ),
                  if (poi.address != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      '📍 ${poi.address}',
                      style: const TextStyle(fontSize: 11.5, color: Colors.white54),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          poi.tags.join(' · '),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF93C5FD),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => appState.setLiveDestination(
                          LivePlaceSearchResult(
                            displayName: poi.name,
                            shortName: poi.name,
                            point: poi.point,
                          ),
                        ),
                        icon: const Icon(Icons.turn_right_rounded, size: 16),
                        label: const Text('Buraya Rota Çiz'),
                      ),
                    ],
                  ),
                ],
              ),
            )
        else
          // Offline fallback cards if user is temporarily offline
          for (final st in appState.relevantRouteStations)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${st.name} — +${st.distanceAlongRouteKm} km (Çevrimdışı Yedek Veri)',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
      ],
    );
  }

  void _showLivePoiSheet(BuildContext context, LivePoiItem poi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.appState.brandTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poi.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(poi.subtitle, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text(
              'Uzaklık: ${poi.distanceKm.toStringAsFixed(2)} km · Koordinat: ${poi.point.latitude.toStringAsFixed(4)}, ${poi.point.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (poi.phone != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => EmergencyService.dialPhoneNumber(poi.phone!),
                      icon: const Icon(Icons.call_rounded),
                      label: const Text('İstasyonu Ara'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.appState.setLiveDestination(
                        LivePlaceSearchResult(
                          displayName: poi.name,
                          shortName: poi.name,
                          point: poi.point,
                        ),
                      );
                    },
                    icon: const Icon(Icons.navigation_rounded),
                    label: const Text('Rota Başlat'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
