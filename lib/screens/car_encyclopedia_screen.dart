import 'package:flutter/material.dart';
import '../models/vehicle_spec.dart';
import '../services/car_info_service.dart';
import '../services/emergency_service.dart';
import '../state/app_state.dart';

class CarEncyclopediaScreen extends StatefulWidget {
  final OtonomAppState appState;

  const CarEncyclopediaScreen({super.key, required this.appState});

  @override
  State<CarEncyclopediaScreen> createState() => _CarEncyclopediaScreenState();
}

class _CarEncyclopediaScreenState extends State<CarEncyclopediaScreen> {
  final CarInfoService _service = CarInfoService();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _vinCtrl =
      TextEditingController(text: 'WBS33AZ090CP12345');
  String _query = '';
  VehicleSpec? _selectedSpec;
  VinLookupResult? _vinResult;
  bool _loadingVin = false;

  @override
  void initState() {
    super.initState();
    _selectedSpec = widget.appState.selectedVehicle;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _vinCtrl.dispose();
    super.dispose();
  }

  Future<void> _runVinDecode() async {
    setState(() => _loadingVin = true);
    try {
      final res = await _service.decodeVin(_vinCtrl.text);
      setState(() => _vinResult = res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingVin = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.appState.brandTheme;
    final filtered = _service.searchCatalog(_query);
    final active = _selectedSpec ?? widget.appState.selectedVehicle;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Header + Car.info & VIN Lookup Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.primaryColor.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.precision_manufacturing_rounded, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Teknik Ansiklopedi (En Küçük Cıvatasına Kadar)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Car.info katalog indeksleri + OEM fabrika atölye kılavuzları (bijon/karter/kapak sıkma torkları, dişli oranları, sıvı onayları ve kronik ekspertiz noktaları).',
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _query = val),
                decoration: InputDecoration(
                  hintText: 'Model, motor kodu (S58, M254) veya cıvata (M14) ara...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Live VIN Decoder Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _vinCtrl,
                      decoration: InputDecoration(
                        labelText: '17 Haneli Şasi (VIN) Sorgula',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _loadingVin ? null : _runVinDecode,
                    child: Text(_loadingVin ? '...' : 'VIN Çöz'),
                  ),
                ],
              ),
              if (_vinResult != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VIN Sonucu: ${_vinResult!.make} ${_vinResult!.model} (${_vinResult!.modelYear})',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Üretim: ${_vinResult!.plantCountry} · Yakıt: ${_vinResult!.fuelType}',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => EmergencyService.openExternalCarInfo(
                            _vinResult!.carInfoSearchUrl,
                          ),
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          label: const Text('Car.info Üzerinde Aç'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Vehicle Selector Chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final spec = filtered[idx];
              final isSelected = spec.id == active.id;
              return ChoiceChip(
                label: Text('${spec.brandName} ${spec.modelName}'),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedSpec = spec),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // Selected Vehicle Master Blueprint Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
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
                          '${active.brandName} ${active.modelName}',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${active.generationChassis} · ${active.productionYears}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Car.info Kaynağını Aç',
                    onPressed: () =>
                        EmergencyService.openExternalCarInfo(active.carInfoReferenceUrl),
                    icon: const Icon(Icons.open_in_new_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricBadge(label: 'Güç', value: '${active.horsepowerHp} HP'),
                  _MetricBadge(label: 'Tork', value: '${active.torqueNm} Nm'),
                  _MetricBadge(label: '0-100', value: '${active.zeroToHundredSec} sn'),
                  _MetricBadge(label: 'Maks Hız', value: '${active.topSpeedKmh} km/s'),
                  _MetricBadge(label: 'Boş Ağırlık', value: '${active.curbWeightKg} kg'),
                  _MetricBadge(label: 'Menzil', value: '${active.rangeOrTankKm} km'),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => widget.appState.selectGarageVehicle(active),
                  icon: const Icon(Icons.garage_rounded, size: 18),
                  label: const Text('Bu Aracı Profilime Seç & Uygulama Temasını Dönüştür'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 1. BOLTS, SOCKETS & TORQUE SPECS ("En Küçük Cıvatasına Kadar")
        _SectionCard(
          title: '🔩 Cıvata, Diş Ölçüsü, Lokma & Sıkma Torkları (Nm)',
          cardColor: theme.cardColor,
          accentColor: theme.primaryColor,
          children: active.boltTorqueSpecs
              .map(
                (b) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              b.partName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              b.torqueValue,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Diş / Ölçü: ${b.threadSpec}  ·  Anahtar: ${b.socketSize}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF93C5FD),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Atölye Notu: ${b.notes}',
                        style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),

        // 2. ENGINE / MOTOR & TRANSMISSION GEAR RATIOS
        _SectionCard(
          title: '⚙️ Motor / Batarya & Şanzıman Dişli Oranları',
          cardColor: theme.cardColor,
          accentColor: theme.primaryColor,
          children: [
            _SpecRow('Motor / Ünite Kodu', active.engineOrMotorCode),
            _SpecRow('Hacim / Batarya Kapasitesi', active.displacementOrBattery),
            _SpecRow('Çap×Strok / Mimari', active.boreStrokeOrVoltage),
            _SpecRow('Sıkıştırma / Hücre Kimyası', active.compressionOrChemistry),
            _SpecRow('Ateşleme / İnvertör', active.firingOrderOrInverter),
            _SpecRow('Şanzıman Ünitesi', active.transmissionName),
            _SpecRow('Çekiş Sistemi', active.drivetrainLayout),
            const Divider(height: 18),
            const Text(
              'Vites Dişli Oranları:',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
            ),
            const SizedBox(height: 6),
            for (final ratio in active.gearRatios)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '• $ratio',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
          ],
        ),

        // 3. CHASSIS, BRAKES & WHEEL PCD
        _SectionCard(
          title: '🛞 Şasi, Süspansiyon, Fren Disk & Bijon (PCD) Ölçüleri',
          cardColor: theme.cardColor,
          accentColor: theme.primaryColor,
          children: [
            _SpecRow('Ön Süspansiyon', active.frontSuspension),
            _SpecRow('Arka Süspansiyon', active.rearSuspension),
            _SpecRow('Ön Fren Sistemi', active.frontBrakes),
            _SpecRow('Arka Fren Sistemi', active.rearBrakes),
            _SpecRow('Bijon Aralığı (PCD)', active.wheelBoltPatternPcd),
            _SpecRow('Göbek Çapı (CB) & Jant ET', active.centerBoreMm),
            _SpecRow('Ön Lastik Fabrika Ebadı', active.frontTireSpec),
            _SpecRow('Arka Lastik Fabrika Ebadı', active.rearTireSpec),
            _SpecRow('Soğuk Lastik Basıncı', active.tirePressureColdBar),
          ],
        ),

        // 4. FLUIDS & MAINTENANCE
        _SectionCard(
          title: '🛢️ Sıvı Kapasiteleri, Fabrika Onay Kodları & Bakım',
          cardColor: theme.cardColor,
          accentColor: theme.primaryColor,
          children: active.fluidSpecs
              .map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${f.systemName} — ${f.capacity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Onay: ${f.specification}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFFA7F3D0)),
                      ),
                      Text(
                        'Periyot: ${f.interval}',
                        style: const TextStyle(fontSize: 11.5, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),

        // 5. ECU, ELECTRICAL & CHRONIC ISSUES
        _SectionCard(
          title: '⚡ ECU, Elektrik Mimarisi & Kronik Ekspertiz Rehberi',
          cardColor: theme.cardColor,
          accentColor: theme.primaryColor,
          children: [
            _SpecRow('Beyin / Kontrol Ünitesi (ECU)', active.ecuOrController),
            _SpecRow('Yardımcı Akü (12V/48V)', active.auxBatterySpec),
            const SizedBox(height: 8),
            const Text(
              'Sensör, Sigorta & Servis Kritik Notları:',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
            ),
            const SizedBox(height: 4),
            for (final note in active.sensorAndFuseNotes)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('• $note', style: const TextStyle(fontSize: 12)),
              ),
            const Divider(height: 18),
            const Text(
              'Kronik Noktalar & İkinci El Ekspertiz Kontrol Listesi:',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: Color(0xFFFDE68A),
              ),
            ),
            const SizedBox(height: 4),
            for (final tip in active.chronicIssuesAndTips)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('⚠️ $tip', style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ],
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.white54)),
          Text(
            value,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Color cardColor;
  final Color accentColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.cardColor,
    required this.accentColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
