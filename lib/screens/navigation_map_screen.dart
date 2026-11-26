import 'package:flutter/material.dart';
import '../data/mock_automotive_catalog.dart';
import '../models/brand_theme_config.dart';
import '../models/route_station.dart';
import '../state/app_state.dart';
import '../widgets/interactive_cockpit_map.dart';

class NavigationMapScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = appState.brandTheme;
    final vehicle = appState.selectedVehicle;
    final corridor = appState.activeCorridor;
    final stations = appState.relevantRouteStations;
    final isEv = appState.isElectricVehicle;
    final traveledKm = corridor.totalDistanceKm * appState.routeProgress;
    final remainingKm =
        (corridor.totalDistanceKm - traveledKm).clamp(0.0, corridor.totalDistanceKm);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Active Vehicle Telemetry & Quick Brand Switcher Strip
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withValues(alpha: 0.24),
                theme.cardColor,
              ],
            ),
            border: Border.all(color: theme.primaryColor.withValues(alpha: 0.45)),
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
                      isEv ? '⚡ ELEKTRİKLİ ROTA MODU' : '⛽ AKARYAKIT ROTA MODU',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${isEv ? "Batarya" : "Depo"}: %${appState.currentSocOrFuelPercent}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${vehicle.brandName} ${vehicle.modelName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                theme.slogan,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 12),
              // Quick Brand Test Bar
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AutomotiveCatalog.vehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final v = AutomotiveCatalog.vehicles[index];
                    final selected = v.id == vehicle.id;
                    return ChoiceChip(
                      label: Text(
                        '${v.brandName} (${v.powertrain.isElectric ? "EV" : "Benzin"})',
                      ),
                      selected: selected,
                      onSelected: (_) => appState.selectGarageVehicle(v),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Emergency Quick Actions Row (Nearest Tow Truck & 112 Crash Button)
        Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onOpenTowQuick,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF231B0C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.fire_truck_rounded, color: Color(0xFFFBBF24)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'En Yakın Çekici',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '0.9 km · 4 dk uzaklıkta',
                              style: TextStyle(
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
                onTap: onOpen112Quick,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Tek Tuş Sesli 112 Çağrı',
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
        const SizedBox(height: 14),

        // Route Selector
        Row(
          children: [
            const Icon(Icons.route_rounded, size: 18, color: Colors.white70),
            const SizedBox(width: 6),
            const Text(
              'Aktif Navigasyon Rotası:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
            const Spacer(),
            DropdownButton<String>(
              value: corridor.id,
              dropdownColor: theme.cardColor,
              underline: const SizedBox.shrink(),
              items: AutomotiveCatalog.routes
                  .map(
                    (r) => DropdownMenuItem(
                      value: r.id,
                      child: Text(
                        '${r.originName.split(" ").first} → ${r.destinationName.split(" ").first}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                if (id == null) return;
                final found =
                    AutomotiveCatalog.routes.firstWhere((r) => r.id == id);
                appState.selectCorridor(found);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Interactive Navigation Map
        SizedBox(
          height: 255,
          child: InteractiveCockpitMap(
            mode: CockpitMapMode.navigation,
            accentColor: theme.primaryColor,
            isElectric: isEv,
            routeProgress: appState.routeProgress,
            stations: stations,
            waypointIds: appState.addedWaypointStationIds,
            onStationTap: (station) => _showStationSheet(context, station, isEv),
          ),
        ),
        const SizedBox(height: 12),

        // Live Navigation HUD & Progress Simulator
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${corridor.originName} → ${corridor.destinationName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Kalan: ${remainingKm.toStringAsFixed(1)} km · ${corridor.highwaySummary}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: appState.toggleNavigation,
                    icon: Icon(
                      appState.isNavigating
                          ? Icons.pause_circle_filled_rounded
                          : Icons.navigation_rounded,
                      size: 18,
                    ),
                    label: Text(appState.isNavigating ? 'Canlı Rota' : 'Başlat'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Yolculuk Konumu:',
                    style: TextStyle(fontSize: 11.5, color: Colors.white70),
                  ),
                  Expanded(
                    child: Slider(
                      value: appState.routeProgress,
                      activeColor: theme.primaryColor,
                      onChanged: appState.updateRouteProgress,
                    ),
                  ),
                  Text(
                    '${traveledKm.toStringAsFixed(0)} km',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Powertrain-aware Stations Header
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
                    ? 'Yol Üstü Şarj İstasyonları (${vehicle.brandName} EV)'
                    : 'Yol Üstü Akaryakıt İstasyonları (${vehicle.brandName} Benzin)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isEv
              ? 'Aracınız elektrikli olduğu için rotanızdaki yüksek hızlı DC şarj istasyonları, kaç km kaldığı ve varış batarya yüzdesi listeleniyor.'
              : 'Aracınız içten yanmalı olduğu için rotanızdaki akaryakıt istasyonları, kaç km uzakta oldukları ve güncel litre fiyatları listeleniyor.',
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 12),

        for (final station in stations)
          _RouteStationCard(
            station: station,
            traveledKm: traveledKm,
            isEv: isEv,
            accentColor: theme.primaryColor,
            cardColor: theme.cardColor,
            isAdded: appState.addedWaypointStationIds.contains(station.id),
            onToggleWaypoint: () => appState.toggleWaypointStation(station.id),
          ),
      ],
    );
  }

  void _showStationSheet(
    BuildContext context,
    RouteStation station,
    bool isEv,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: appState.brandTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final added = appState.addedWaypointStationIds.contains(station.id);
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                station.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                isEv
                    ? '${station.operatorBrand} · ${station.connectorTypes} · ₺${station.pricePerKwhTry}/kWh'
                    : '${station.operatorBrand} · Kurşunsuz 95: ₺${station.gasoline95PriceTry}/L · Motorin: ₺${station.dieselPriceTry}/L',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: station.amenities
                    .map((a) => Chip(label: Text(a)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    appState.toggleWaypointStation(station.id);
                    Navigator.pop(ctx);
                  },
                  icon: Icon(added ? Icons.check_circle : Icons.add_location_alt),
                  label: Text(
                    added ? 'Rotaya Eklendi (Kaldır)' : 'Bu İstasyonu Rotaya Ekle',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RouteStationCard extends StatelessWidget {
  final RouteStation station;
  final double traveledKm;
  final bool isEv;
  final Color accentColor;
  final Color cardColor;
  final bool isAdded;
  final VoidCallback onToggleWaypoint;

  const _RouteStationCard({
    required this.station,
    required this.traveledKm,
    required this.isEv,
    required this.accentColor,
    required this.cardColor,
    required this.isAdded,
    required this.onToggleWaypoint,
  });

  @override
  Widget build(BuildContext context) {
    final deltaKm = station.distanceAlongRouteKm - traveledKm;
    final passed = deltaKm < 0;
    final distanceLabel = passed
        ? '${deltaKm.abs().toStringAsFixed(1)} km geride kaldı'
        : '${deltaKm.toStringAsFixed(1)} km ileride';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAdded ? accentColor : Colors.white.withValues(alpha: 0.08),
          width: isAdded ? 1.6 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: passed
                      ? Colors.white10
                      : accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  distanceLabel,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: passed ? Colors.white54 : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+${station.detourMinutes} dk sapma',
                style: const TextStyle(fontSize: 11.5, color: Colors.white60),
              ),
              const Spacer(),
              if (isEv && station.availableStalls != null)
                Text(
                  '${station.availableStalls}/${station.totalStalls} Soket Boş',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF34D399),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            station.name,
            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            isEv
                ? '⚡ ${station.maxPowerKw} kW DC (${station.connectorTypes}) · ₺${station.pricePerKwhTry}/kWh · Tahmini Varış Şarjı: %${station.estimatedArrivalSocPercent}'
                : '⛽ Kurşunsuz 95: ₺${station.gasoline95PriceTry}/L · Motorin: ₺${station.dieselPriceTry}/L${station.lpgPriceTry != null ? " · LPG: ₺${station.lpgPriceTry}/L" : ""}',
            style: const TextStyle(fontSize: 12.5, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  station.amenities.join(' · '),
                  style: const TextStyle(fontSize: 11.5, color: Colors.white54),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onToggleWaypoint,
                icon: Icon(
                  isAdded ? Icons.check_rounded : Icons.add_road_rounded,
                  size: 16,
                ),
                label: Text(isAdded ? 'Durak Eklendi' : 'Durak Ekle'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
