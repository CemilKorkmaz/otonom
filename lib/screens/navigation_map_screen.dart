import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/brand_theme_config.dart';
import '../models/live_api_models.dart';
import '../services/emergency_service.dart';
import '../state/app_state.dart';
import '../widgets/ios_liquid_glass.dart';
import '../widgets/live_osm_cockpit_map.dart';
import 'fullscreen_turn_by_turn_screen.dart';

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
  Timer? _searchDebounce;
  List<LivePlaceSearchResult> _searchResults = [];
  bool _searchingPlace = false;
  bool _buildingAndLaunchingRoute = false;
  bool? _manualEvOverride;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _destSearchCtrl.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged(String value) {
    _searchDebounce?.cancel();
    if (value.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 380), _runPlaceSearch);
  }

  Future<void> _runPlaceSearch() async {
    final q = _destSearchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _searchingPlace = true);
    final res = await widget.appState.liveApis.searchPlaces(
      q,
      biasPoint: widget.appState.currentLocation,
    );
    if (mounted) {
      setState(() {
        _searchResults = res;
        _searchingPlace = false;
      });
    }
  }

  /// Searches first result if user typed text & tapped "Rota Oluştur", calculates OSRM route,
  /// and opens Fullscreen Google/Apple Maps Turn-by-Turn Navigation!
  Future<void> _createRouteAndEnterFullscreen([
    LivePlaceSearchResult? pickedPlace,
  ]) async {
    if (_buildingAndLaunchingRoute) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    setState(() {
      _buildingAndLaunchingRoute = true;
      _searchResults = [];
    });

    try {
      LivePlaceSearchResult? target = pickedPlace;
      if (target == null) {
        final q = _destSearchCtrl.text.trim();
        if (q.isNotEmpty) {
          final found = await widget.appState.liveApis.searchPlaces(
            q,
            biasPoint: widget.appState.currentLocation,
          );
          if (found.isNotEmpty) {
            target = found.first;
          }
        }
      }

      bool ok = true;
      if (target != null) {
        ok = await widget.appState.setLiveDestination(target);
      } else if (widget.appState.liveRoute == null) {
        await widget.appState.refreshAllLiveApis();
        ok = widget.appState.liveRoute != null;
      }

      if (!mounted) return;
      final activeRoute = widget.appState.liveRoute;
      if (!ok || activeRoute == null || activeRoute.polyline.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.appState.lastRouteError ??
                  'Hedefe karayolu rotası oluşturulamadı. Lütfen aramayı kontrol edin.',
            ),
          ),
        );
        return;
      }

      await Navigator.of(context, rootNavigator: true).push<void>(
        CupertinoPageRoute(
          fullscreenDialog: true,
          builder: (_) => FullscreenTurnByTurnScreen(
            appState: widget.appState,
            initialRoute: activeRoute,
            destinationTitle: widget.appState.destinationName,
            destinationPoint: widget.appState.destinationPoint,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _buildingAndLaunchingRoute = false);
      }
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
      children: [
        // 1. iPhone Search & "Rota Oluştur" Card
        IosGroupedCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: IosSearchField(
                      controller: _destSearchCtrl,
                      placeholder: 'Nereye gidiyoruz? (İlçe, cadde, mekan...)',
                      onChanged: _onSearchQueryChanged,
                      onSubmitted: (_) => _createRouteAndEnterFullscreen(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0A84FF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _buildingAndLaunchingRoute
                        ? null
                        : () => _createRouteAndEnterFullscreen(),
                    icon: _buildingAndLaunchingRoute || _searchingPlace
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : const Icon(
                            CupertinoIcons.location_north_fill,
                            size: 16,
                          ),
                    label: const Text(
                      'Rota Oluştur',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),

              // Autocomplete Suggestions List
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 10),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                for (final r in _searchResults)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    dense: true,
                    leading: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A84FF).withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.placemark_fill,
                        color: Color(0xFF0A84FF),
                        size: 17,
                      ),
                    ),
                    title: Text(
                      r.shortName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    subtitle: Text(
                      r.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    trailing: const Text(
                      'Başlat →',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF30D158),
                      ),
                    ),
                    onTap: () {
                      _destSearchCtrl.text = r.shortName;
                      _createRouteAndEnterFullscreen(r);
                    },
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Interactive Map Preview + Instant Fullscreen Launch Button
        Stack(
          children: [
            SizedBox(
              height: 285,
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
            Positioned(
              left: 12,
              top: 12,
              child: IosLiquidGlassSurface(
                borderRadius: 999,
                tintColor: const Color(0xFF0B3B2E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                onTap: () => _createRouteAndEnterFullscreen(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.arrow_up_left_arrow_down_right,
                      size: 14,
                      color: Color(0xFF30D158),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Tam Ekran Sürüş Modu',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Active Route Summary + Big Apple Maps "Navigasyonu Başlat" CTA
        IosGroupedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.destinationName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          osrm != null
                              ? '${osrm.distanceKm.toStringAsFixed(1)} km · ${osrm.durationMinutes} dk · ${osrm.maneuvers.length} dönüş adımı'
                              : 'Konumunuzdan rota hazırlandığında süre hesaplanır',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF30D158),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: _buildingAndLaunchingRoute
                        ? null
                        : () => _createRouteAndEnterFullscreen(),
                    icon: const Icon(
                      CupertinoIcons.location_north_fill,
                      size: 16,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'Başlat',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              if (weather != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.cloud_sun_fill,
                      color: Color(0xFF5AC8FA),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${weather.temperatureC.toStringAsFixed(1)}°C · ${weather.conditionTr} — ${weather.drivingAdvisoryTr}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 4. iOS Cupertino Sliding Segmented Control: Fuel vs EV + Active Garage Car Switcher
        IosGroupedCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    showEv
                        ? CupertinoIcons.bolt_circle_fill
                        : Icons.local_gas_station_rounded,
                    color: showEv
                        ? const Color(0xFF5AC8FA)
                        : const Color(0xFFFFD60A),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activeCar != null
                          ? '${activeCar.shortTitle} · ${activeCar.powertrain.shortFuelTag}'
                          : 'İstasyon Tipi Seçimi',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CupertinoSlidingSegmentedControl<bool>(
                groupValue: showEv,
                backgroundColor: const Color(0xFF2C2C2E),
                thumbColor: theme.primaryColor,
                children: const {
                  false: Padding(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    child: Text(
                      '⛽ Akaryakıt İstasyonları',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  true: Padding(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    child: Text(
                      '⚡ Elektrikli Şarj (EV)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                },
                onValueChanged: (val) {
                  if (val != null) {
                    HapticFeedback.selectionClick();
                    setState(() => _manualEvOverride = val);
                  }
                },
              ),
              if (appState.garageVehicles.length > 1) ...[
                const SizedBox(height: 10),
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
                          HapticFeedback.selectionClick();
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
        const SizedBox(height: 16),

        // 5. Nearby Live Stations List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              showEv
                  ? 'Yakındaki Şarj İstasyonları (${livePois.length})'
                  : 'Yakındaki Akaryakıt İstasyonları (${livePois.length})',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(28, 28),
              onPressed: appState.refreshAllLiveApis,
              child: const Icon(CupertinoIcons.refresh, size: 19),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (appState.isLoadingLive && livePois.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CupertinoActivityIndicator(radius: 14)),
          )
        else if (livePois.isEmpty)
          const IosGroupedCard(
            child: Text(
              'Konum çevresindeki istasyonlar taranıyor. Sağ üstteki yenile simgesine dokunabilirsiniz.',
              style: TextStyle(fontSize: 12.5, color: Colors.white70),
            ),
          )
        else
          for (final poi in livePois.take(12))
            IosGroupedCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(13),
              onTap: () => _showStationSheet(context, poi),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: showEv
                          ? const Color(0xFF5AC8FA).withValues(alpha: 0.16)
                          : const Color(0xFFFFD60A).withValues(alpha: 0.16),
                    ),
                    child: Icon(
                      showEv
                          ? CupertinoIcons.bolt_fill
                          : Icons.local_gas_station_rounded,
                      size: 19,
                      color: showEv
                          ? const Color(0xFF5AC8FA)
                          : const Color(0xFFFFD60A),
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
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${poi.distanceKm.toStringAsFixed(1)} km · ${poi.subtitle}',
                          style: const TextStyle(
                            fontSize: 11.8,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    color: const Color(0xFF0A84FF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    minimumSize: Size.zero,
                    onPressed: () => _createRouteAndEnterFullscreen(
                      LivePlaceSearchResult(
                        displayName: poi.name,
                        shortName: poi.name,
                        point: poi.point,
                      ),
                    ),
                    child: const Text(
                      'Git',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5AC8FA),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  void _showStationSheet(BuildContext context, LivePoiItem poi) {
    showIosGlassBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poi.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
                      icon: const Icon(CupertinoIcons.phone_fill, size: 16),
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
                      _createRouteAndEnterFullscreen(
                        LivePlaceSearchResult(
                          displayName: poi.name,
                          shortName: poi.name,
                          point: poi.point,
                        ),
                      );
                    },
                    icon: const Icon(
                      CupertinoIcons.location_north_fill,
                      size: 16,
                    ),
                    label: const Text('Tam Ekran Navigasyonu Başlat'),
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
