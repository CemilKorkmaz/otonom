import 'package:flutter/material.dart';
import '../models/brand_theme_config.dart';
import '../models/live_api_models.dart';
import '../services/emergency_service.dart';
import '../state/app_state.dart';
import '../widgets/live_osm_cockpit_map.dart';

class NavigationMapScreen extends StatefulWidget {
  final OtonomAppState appState;

  const NavigationMapScreen({
    super.key,
    required this.appState,
  });

  @override
  State<NavigationMapScreen> createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends State<NavigationMapScreen> {
  final TextEditingController _destSearchCtrl = TextEditingController();
  List<LivePlaceSearchResult> _searchResults = [];
  bool _searchingPlace = false;
  bool? _manualEvOverride; // Lets user toggle EV vs Fuel stations even without adding a car yet

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
    final activeCar = appState.activeGarageVehicle;
    final showEv = _manualEvOverride ?? appState.isElectricVehicle;
    final weather = appState.liveWeather;
    final osrm = appState.liveRoute;
    final livePois = showEv ? appState.liveEvStations : appState.liveFuelStations;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 36),
      children: [
        // 1. Active Vehicle & Station Filter Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withValues(alpha: 0.25),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      showEv ? '⚡ CANLI EV ŞARJ ROTASI' : '⛽ CANLI AKARYAKIT ROTASI',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SegmentedButton<bool>(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    segments: const [
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('⛽ Yakıt', style: TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('⚡ Şarj', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                    selected: {showEv},
                    onSelectionChanged: (s) =>
                        setState(() => _manualEvOverride = s.first),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                activeCar != null
                    ? '${activeCar.fullTitle} (${activeCar.powertrain.labelTr})'
                    : 'Garajım sekmesinden kendi aracınızı ekleyerek otomatik yakıt/şarj modunu aktif edebilirsiniz.',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (appState.garageVehicles.length > 1) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: appState.garageVehicles.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (ctx, idx) {
                      final gv = appState.garageVehicles[idx];
                      final selected = gv.id == activeCar?.id;
                      return ChoiceChip(
                        visualDensity: VisualDensity.compact,
                        selected: selected,
                        label: Text(
                          gv.shortTitle,
                          style: const TextStyle(fontSize: 11.5),
                        ),
                        onSelected: (_) {
                          setState(() => _manualEvOverride = null);
                          appState.selectActiveGarageVehicle(gv.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Nominatim Live Destination Search Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _destSearchCtrl,
                onSubmitted: (_) => _runPlaceSearch(),
                decoration: InputDecoration(
                  hintText: 'Hedef Ara (Örn: Ankara, Kadıköy, İzmir, Bolu...)',
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFF131924),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
              ),
              onPressed: _searchingPlace ? null : _runPlaceSearch,
              child: _searchingPlace
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Rota Bul'),
            ),
          ],
        ),

        if (_searchResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF141B29),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                for (final r in _searchResults)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.place_rounded,
                      color: theme.secondaryColor,
                    ),
                    title: Text(
                      r.shortName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      r.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                      setState(() => _searchResults = []);
                      appState.setLiveDestination(r);
                    },
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),

        // 3. LIVE INTERACTIVE OPENSTREETMAP (Dark & Light Mode Working 100%!)
        SizedBox(
          height: 310,
          child: LiveOsmCockpitMap(
            userLocation: appState.currentLocation,
            destinationPoint: appState.destinationPoint,
            routePolyline: osrm?.polyline ?? const [],
            pois: livePois,
            accentColor: theme.primaryColor,
            darkTiles: appState.darkMapTiles,
            onToggleTileStyle: appState.toggleMapTileStyle,
            onRecenterGps: appState.refreshAllLiveApis,
            onPoiTap: (poi) => _showStationSheet(context, poi),
          ),
        ),
        const SizedBox(height: 12),

        // 4. Live OSRM Route Telemetry + Open-Meteo Weather Bar
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
                  Icon(Icons.route_rounded, color: theme.secondaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hedef: ${appState.destinationName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  if (osrm != null)
                    Text(
                      '${osrm.distanceKm.toStringAsFixed(1)} km · ${osrm.durationMinutes} dk',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: theme.secondaryColor,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
              if (weather != null) ...[
                const Divider(height: 18, color: Colors.white12),
                Text(
                  '🌡️ ${weather.temperatureC.toStringAsFixed(1)}°C (${weather.conditionTr}) · ${weather.drivingAdvisoryTr}',
                  style: const TextStyle(fontSize: 11.8, color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 5. Live Nearby Stations List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                showEv
                    ? '⚡ Yakınınızdaki Canlı Şarj İstasyonları (${livePois.length})'
                    : '⛽ Yakınınızdaki Canlı Akaryakıt İstasyonları (${livePois.length})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: 'İstasyonları Yenile',
              onPressed: appState.refreshAllLiveApis,
              icon: const Icon(Icons.refresh_rounded, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 6),

        if (appState.isLoadingLive && livePois.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (livePois.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Konum çevresindeki istasyonlar aranıyor. Sağ üstteki yenile butonuna dokunarak tekrar tarayabilirsiniz.',
                style: TextStyle(fontSize: 12.5, color: Colors.white70),
              ),
            ),
          )
        else
          for (final poi in livePois.take(12))
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: showEv
                        ? const Color(0xFF22D3EE).withValues(alpha: 0.18)
                        : const Color(0xFFFBBF24).withValues(alpha: 0.18),
                    child: Icon(
                      showEv
                          ? Icons.bolt_rounded
                          : Icons.local_gas_station_rounded,
                      color: showEv
                          ? const Color(0xFF22D3EE)
                          : const Color(0xFFFBBF24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poi.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${poi.distanceKm.toStringAsFixed(1)} km · ${poi.subtitle}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.white70,
                          ),
                        ),
                        if (poi.address != null)
                          Text(
                            poi.address!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white54,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Bu İstasyona Rota Çiz',
                    onPressed: () => appState.setLiveDestination(
                      LivePlaceSearchResult(
                        displayName: poi.name,
                        shortName: poi.name,
                        point: poi.point,
                      ),
                    ),
                    icon: Icon(
                      Icons.directions_rounded,
                      color: theme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  void _showStationSheet(BuildContext context, LivePoiItem poi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101520),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poi.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              '${poi.distanceKm.toStringAsFixed(2)} km · ${poi.subtitle}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (poi.address != null) ...[
              const SizedBox(height: 4),
              Text(
                '📍 ${poi.address}',
                style: const TextStyle(fontSize: 12.5, color: Colors.white60),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (poi.phone != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          EmergencyService.dialPhoneNumber(poi.phone!),
                      icon: const Icon(Icons.call_rounded, size: 16),
                      label: const Text('Ara'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: 2,
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
                    icon: const Icon(Icons.navigation_rounded, size: 17),
                    label: const Text('Bu İstasyona Rota Çiz'),
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
