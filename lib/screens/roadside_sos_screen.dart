import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mock_automotive_catalog.dart';
import '../models/brand_theme_config.dart';
import '../models/tow_truck.dart';
import '../services/emergency_service.dart';
import '../state/app_state.dart';
import '../widgets/interactive_cockpit_map.dart';

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
  bool _filterFlatbedOnly = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.appState.brandTheme;
    final trucks = AutomotiveCatalog.towTrucks
        .where((t) => !_filterFlatbedOnly || t.supportsLowClearance)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // 112 CRASH EMERGENCY BANNER
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF7F1D1D), Color(0xFF28090D)],
            ),
            border: Border.all(color: const Color(0xFFEF4444), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.32),
                blurRadius: 18,
              ),
            ],
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
                      'KAZA & ACİL DURUM ASİSTANI (112)',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Kaza anında tek dokunuşla doğrudan 112 Acil Çağrı Merkezi’ni arar; açık GPS koordinatlarınızı, araç yüksek voltaj/yakıt bilginizi ve kan grubunuzu ekrana getirir.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFFFECACA)),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () =>
                      RoadsideSosScreen.show112EmergencyModal(context, widget.appState),
                  icon: const Icon(Icons.phone_in_talk_rounded),
                  label: const Text(
                    'ACİL 112’Yİ HEMEN ARA & KONUM GÖSTER',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Nearest Tow Truck Radar Header
        Row(
          children: [
            const Icon(Icons.fire_truck_rounded, color: Color(0xFFFBBF24)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'En Yakın Çekici & Kurtarıcı Radarı',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
            FilterChip(
              label: const Text('Basık / Spor Kayar Kasa'),
              selected: _filterFlatbedOnly,
              onSelected: (v) => setState(() => _filterFlatbedOnly = v),
            ),
          ],
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 220,
          child: InteractiveCockpitMap(
            mode: CockpitMapMode.towRadar,
            accentColor: theme.primaryColor,
            towTrucks: trucks,
            onTowTruckTap: (truck) =>
                RoadsideSosScreen.showTowCallModal(context, truck, widget.appState),
          ),
        ),
        const SizedBox(height: 14),

        for (final truck in trucks)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
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
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${truck.distanceKm} km · ${truck.etaMinutes} dk içinde yanınızda',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFDE68A),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '★ ${truck.rating} (${truck.completedJobs})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  truck.companyName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Operatör: ${truck.driverName} · Plaka: ${truck.plateNumber} · ${truck.district}',
                  style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  truck.truckType,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF93C5FD)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Açılış: ₺${truck.baseFeeTry} + ₺${truck.perKmFeeTry}/km',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          truck.phoneNumber,
                          style: const TextStyle(fontSize: 11.5, color: Colors.white54),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => RoadsideSosScreen.showTowCallModal(
                        context,
                        truck,
                        widget.appState,
                      ),
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: const Text('Hemen Ara'),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
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
    final v = widget.appState.selectedVehicle;
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
              '112 ACİL ÇAĞRI MERKEZİ BAĞLANIYOR · $mins:$secs',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '112 Operatörüne Okuyabileceğiniz Konum & Araç Kartı',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
                const Text(
                  '📍 GPS: 40.9819° K, 29.0576° D (D-100 Kozyatağı Kuzey Yan Yol, Kadıköy/İST)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  '🚗 Araç: ${v.brandName} ${v.modelName} · Plaka: ${widget.appState.userPlate}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  '🩸 Sürücü: ${widget.appState.driverName} · Kan Grubu: ${widget.appState.bloodType}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  v.powertrain.isElectric
                      ? '⚡ İTFAİYE UYARISI: Yüksek Voltajlı Elektrikli Araç (HV Batarya Kesici Ön Kaput Altı)'
                      : '⛽ YAKIT TİPİ: İçten Yanmalı (${v.powertrain.labelTr})',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFDE68A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
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
                  label: const Text('Çağrıyı Sonlandır'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TowOperatorCallSheet extends StatefulWidget {
  final TowTruckOperator truck;
  final OtonomAppState appState;

  const _TowOperatorCallSheet({required this.truck, required this.appState});

  @override
  State<_TowOperatorCallSheet> createState() => _TowOperatorCallSheetState();
}

class _TowOperatorCallSheetState extends State<_TowOperatorCallSheet> {
  bool _locationShared = true;

  @override
  Widget build(BuildContext context) {
    final t = widget.truck;
    final v = widget.appState.selectedVehicle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFFF59E0B),
                child: Icon(Icons.fire_truck_rounded, color: Colors.black, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.companyName,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${t.driverName} · Plaka: ${t.plateNumber}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📍 Uzaklık: ${t.distanceKm} km · Tahmini Varış: ${t.etaMinutes} dakika'),
                const SizedBox(height: 6),
                Text('🛻 Kasa Tipi: ${t.truckType}'),
                const SizedBox(height: 6),
                Text(
                  '🔧 Gönderilen Araç Bilgisi: ${v.brandName} ${v.modelName} (${v.curbWeightKg} kg · ${v.drivetrainLayout})',
                  style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _locationShared,
            title: const Text(
              'Canlı GPS Konumumu & Çekme Halkası/Şasi Bilgimi Gönder',
              style: TextStyle(fontSize: 13),
            ),
            onChanged: (val) => setState(() => _locationShared = val),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kapat'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    EmergencyService.dialPhoneNumber(t.phoneNumber);
                  },
                  icon: const Icon(Icons.phone_forwarded_rounded),
                  label: Text('${t.phoneNumber} Ara'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
