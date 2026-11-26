import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mock_automotive_catalog.dart';
import '../models/brand_theme_config.dart';
import '../models/live_api_models.dart';
import '../models/tow_truck.dart';
import '../services/emergency_service.dart';
import '../state/app_state.dart';
import '../widgets/live_osm_cockpit_map.dart';

class RoadsideSosScreen extends StatefulWidget {
  final OtonomAppState appState;

  const RoadsideSosScreen({super.key, required this.appState});

  @override
  State<RoadsideSosScreen> createState() => _RoadsideSosScreenState();

  static void show112EmergencyModal(BuildContext context, OtonomAppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14070A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _Emergency112CallSheet(appState: appState),
    );
  }

  static void showTowCallModal(
    BuildContext context,
    TowTruckOperator truck,
    OtonomAppState appState,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101520),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _TowOperatorCallSheet(truck: truck, appState: appState),
    );
  }
}

class _RoadsideSosScreenState extends State<RoadsideSosScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final theme = appState.brandTheme;
    final liveRepairs = appState.liveTowRepairs;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // 112 CRASH EMERGENCY BANNER WITH LIVE GPS + NOMINATIM STREET ADDRESS
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF7F1D1D), Color(0xFF28090D)],
            ),
            border: Border.all(color: const Color(0xFFEF4444), width: 1.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.emergency_share_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'KAZA & ACİL 112 ASİSTANI (CANLI KONUM)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '📍 Canlı Açık Adresiniz: ${appState.liveStreetAddress}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFDE68A),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () =>
                      RoadsideSosScreen.show112EmergencyModal(context, appState),
                  icon: const Icon(Icons.phone_in_talk_rounded),
                  label: const Text(
                    'ACİL 112’Yİ HEMEN ARA & KONUM KARTINI AÇ',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Live OSM Map of Nearby Tow & Car Repair Services
        Row(
          children: [
            const Icon(Icons.fire_truck_rounded, color: Color(0xFFFBBF24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Çevrenizdeki Canlı Yol Yardım & Servisler (${liveRepairs.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              onPressed: appState.refreshAllLiveApis,
              icon: const Icon(Icons.my_location_rounded, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 250,
          child: LiveOsmCockpitMap(
            userLocation: appState.currentLocation,
            pois: liveRepairs,
            accentColor: theme.primaryColor,
            darkTiles: appState.darkMapTiles,
            onToggleTileStyle: appState.toggleMapTileStyle,
            onRecenterGps: appState.refreshAllLiveApis,
            onPoiTap: (poi) => _showLiveRepairCallSheet(context, poi),
          ),
        ),
        const SizedBox(height: 14),

        if (liveRepairs.isNotEmpty) ...[
          const Text(
            '🟢 OpenStreetMap Üzerinden Konumunuza En Yakın Gerçek İşletmeler',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF34D399),
            ),
          ),
          const SizedBox(height: 8),
          for (final poi in liveRepairs.take(10))
            Container(
              margin: const EdgeInsets.only(bottom: 10),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${poi.distanceKm.toStringAsFixed(2)} km uzakta',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFDE68A),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Canlı OSM Kaydı',
                        style: TextStyle(fontSize: 11, color: Colors.white54),
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
                  if (poi.address != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        '📍 ${poi.address}',
                        style: const TextStyle(fontSize: 11.5, color: Colors.white54),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        poi.phone ?? 'Harita Konumu Mevcut',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF93C5FD),
                        ),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => _showLiveRepairCallSheet(context, poi),
                        icon: Icon(
                          poi.phone != null
                              ? Icons.call_rounded
                              : Icons.directions_rounded,
                          size: 17,
                        ),
                        label: Text(poi.phone != null ? 'Hemen Ara' : 'Detay & Rota'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
        ],

        const Text(
          '🛻 7/24 Nöbetçi Kayar Kasa Kurtarıcı Hattı',
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        for (final truck in AutomotiveCatalog.towTrucks)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        truck.companyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${truck.truckType} · ₺${truck.baseFeeTry} + ₺${truck.perKmFeeTry}/km',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => RoadsideSosScreen.showTowCallModal(
                    context,
                    truck,
                    appState,
                  ),
                  icon: const Icon(Icons.call_rounded, size: 16),
                  label: const Text('Ara'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showLiveRepairCallSheet(BuildContext context, LivePoiItem poi) {
    final activeTitle = widget.appState.activeVehicleTitle;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101520),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
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
              '📍 Uzaklık: ${poi.distanceKm.toStringAsFixed(2)} km · ${poi.address ?? "${poi.point.latitude.toStringAsFixed(4)}, ${poi.point.longitude.toStringAsFixed(4)}"}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              '🚗 Sizin Konumunuz: ${widget.appState.liveStreetAddress}',
              style: const TextStyle(fontSize: 12, color: Color(0xFFFDE68A)),
            ),
            const SizedBox(height: 6),
            Text(
              '🔧 Araç Bilgisi: $activeTitle',
              style: const TextStyle(fontSize: 12, color: Color(0xFF93C5FD)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Kapat'),
                  ),
                ),
                const SizedBox(width: 10),
                if (poi.phone != null)
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () => EmergencyService.dialPhoneNumber(poi.phone!),
                      icon: const Icon(Icons.phone_forwarded_rounded),
                      label: Text('${poi.phone} Ara'),
                    ),
                  )
                else
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
                      icon: const Icon(Icons.navigation_rounded),
                      label: const Text('Konuma Rota Çiz'),
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

class _Emergency112CallSheet extends StatefulWidget {
  final OtonomAppState appState;

  const _Emergency112CallSheet({required this.appState});

  @override
  State<_Emergency112CallSheet> createState() => _Emergency112CallSheetState();
}

class _Emergency112CallSheetState extends State<_Emergency112CallSheet> {
  int _secondsConnected = 0;
  bool _speakerOn = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    EmergencyService.dialEmergency112();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _secondsConnected++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCar = widget.appState.activeGarageVehicle;
    final pt = widget.appState.currentLocation;
    final mins = (_secondsConnected ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsConnected % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '112 ACİL ÇAĞRI MERKEZİ · $mins:$secs',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '112 Operatörüne Okuyabileceğiniz Canlı Konum & Araç Kartı',
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📍 Canlı GPS: ${pt.latitude.toStringAsFixed(5)}° K, ${pt.longitude.toStringAsFixed(5)}° D',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 5),
                Text(
                  '🗺️ Açık Adres (Nominatim): ${widget.appState.liveStreetAddress}',
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFFFDE68A)),
                ),
                const SizedBox(height: 6),
                Text(
                  '🚗 Araç: ${activeCar?.fullTitle ?? "Belirtilmedi"} · Plaka: ${widget.appState.userPlate}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 5),
                Text(
                  '🩸 Sürücü: ${widget.appState.driverName} · Kan Grubu: ${widget.appState.bloodType}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.appState.isElectricVehicle
                      ? '⚡ İTFAİYE UYARISI: Yüksek Voltajlı Elektrikli Araç (HV Batarya Kesici Ön Kaput Altı)'
                      : '⛽ YAKIT TİPİ: ${activeCar?.powertrain.labelTr ?? "İçten Yanmalı"}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF93C5FD),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _speakerOn = !_speakerOn),
                  icon: Icon(_speakerOn ? Icons.volume_up : Icons.volume_off),
                  label: Text(_speakerOn ? 'Hoparlör Açık' : 'Ahize Modu'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.call_end_rounded),
                  label: const Text('Kapat'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TowOperatorCallSheet extends StatelessWidget {
  final TowTruckOperator truck;
  final OtonomAppState appState;

  const _TowOperatorCallSheet({required this.truck, required this.appState});

  @override
  Widget build(BuildContext context) {
    final activeTitle = appState.activeVehicleTitle;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            truck.companyName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'Operatör: ${truck.driverName} · Plaka: ${truck.plateNumber}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Text('📍 İletilecek Canlı Konumunuz: ${appState.liveStreetAddress}'),
          const SizedBox(height: 6),
          Text(
            '🔧 Araç: $activeTitle',
            style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Vazgeç'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () => EmergencyService.dialPhoneNumber(truck.phoneNumber),
                  icon: const Icon(Icons.phone_forwarded_rounded),
                  label: Text('${truck.phoneNumber} Ara'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
