import 'package:flutter/material.dart';
import '../models/live_api_models.dart';
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
      TextEditingController(text: '5YJYGDEE0MF123456');

  // Live Global NHTSA + EPA Query Controllers
  final TextEditingController _liveMakeCtrl = TextEditingController(text: 'BMW');
  final TextEditingController _liveModelCtrl = TextEditingController(text: 'M4');
  final TextEditingController _liveYearCtrl = TextEditingController(text: '2023');

  int _modeTab = 0; // 0 = OEM Cıvata/Tork Atölye Katalogu, 1 = Canlı NHTSA + EPA Global API
  String _query = '';
  VehicleSpec? _selectedSpec;
  VinLookupResult? _vinResult;
  bool _loadingVin = false;

  bool _loadingGlobalApi = false;
  List<String> _nhtsaModels = [];
  List<LiveEpaVehicleSpec> _epaSpecs = [];
  List<LiveRecallItem> _liveRecalls = [];
  List<LiveComplaintItem> _liveComplaints = [];

  @override
  void initState() {
    super.initState();
    _selectedSpec = widget.appState.selectedVehicle;
    _runLiveGlobalVehicleLookup();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _vinCtrl.dispose();
    _liveMakeCtrl.dispose();
    _liveModelCtrl.dispose();
    _liveYearCtrl.dispose();
    super.dispose();
  }

  Future<void> _runVinDecode() async {
    setState(() => _loadingVin = true);
    try {
      final res = await _service.decodeVin(_vinCtrl.text);
      if (mounted) setState(() => _vinResult = res);
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

  Future<void> _runLiveGlobalVehicleLookup() async {
    final make = _liveMakeCtrl.text.trim();
    final model = _liveModelCtrl.text.trim();
    final year = _liveYearCtrl.text.trim();
    if (make.isEmpty || year.isEmpty) return;

    setState(() => _loadingGlobalApi = true);
    try {
      final apis = widget.appState.liveApis;
      final modelsFuture =
          apis.fetchNhtsaModelsForMakeYear(make: make, year: year);
      final epaFuture = model.isNotEmpty
          ? apis.fetchEpaVehicleSpecs(year: year, make: make, model: model)
          : Future.value(<LiveEpaVehicleSpec>[]);
      final safetyFuture = model.isNotEmpty
          ? apis.fetchRecallsAndComplaints(make: make, model: model, year: year)
          : Future.value(
              (recalls: <LiveRecallItem>[], complaints: <LiveComplaintItem>[]),
            );

      final res = await Future.wait([modelsFuture, epaFuture, safetyFuture]);
      if (mounted) {
        final safety =
            res[2] as ({List<LiveRecallItem> recalls, List<LiveComplaintItem> complaints});
        setState(() {
          _nhtsaModels = res[0] as List<String>;
          _epaSpecs = res[1] as List<LiveEpaVehicleSpec>;
          _liveRecalls = safety.recalls;
          _liveComplaints = safety.complaints;
        });
      }
    } finally {
      if (mounted) setState(() => _loadingGlobalApi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.appState.brandTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Mode Selector: OEM Bolt/Torque vs Live Global NHTSA/EPA API
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 0,
              icon: Icon(Icons.build_rounded, size: 17),
              label: Text('Cıvata & OEM Atölye'),
            ),
            ButtonSegment(
              value: 1,
              icon: Icon(Icons.public_rounded, size: 17),
              label: Text('Canlı API (NHTSA+EPA)'),
            ),
          ],
          selected: {_modeTab},
          onSelectionChanged: (s) => setState(() => _modeTab = s.first),
        ),
        const SizedBox(height: 12),

        if (_modeTab == 1)
          _buildLiveGlobalApiView(theme.cardColor, theme.primaryColor)
        else
          _buildOemBoltWorkshopView(theme.cardColor, theme.primaryColor),
      ],
    );
  }

  Widget _buildLiveGlobalApiView(Color cardColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🌐 Canlı Global Araç Sorgulama (10.000+ Model)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'NHTSA vPIC + EPA FuelEconomy.gov + Resmi Geri Çağırma (Recall) & Kronik Kullanıcı Şikayetleri API’lerinden canlı veri çeker.',
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _liveMakeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Marka (BMW, Tesla, Honda...)',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _liveModelCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Model (M4, Model Y, Civic...)',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _liveYearCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Yıl',
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      _loadingGlobalApi ? null : _runLiveGlobalVehicleLookup,
                  icon: _loadingGlobalApi
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_download_rounded),
                  label: Text(
                    _loadingGlobalApi
                        ? 'Canlı API’lerden Çekiliyor...'
                        : 'Canlı Teknik Veri, Recall & Şikayetleri Çek',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Quick preset queries
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final preset in const [
                    ('Tesla', 'Model Y', '2023'),
                    ('BMW', 'M4', '2023'),
                    ('Porsche', 'Taycan', '2023'),
                    ('Mercedes-Benz', 'C300', '2023'),
                    ('Honda', 'Civic', '2022'),
                    ('Toyota', 'Corolla', '2022'),
                  ])
                    ActionChip(
                      label: Text('${preset.$1} ${preset.$2} (${preset.$3})'),
                      onPressed: () {
                        _liveMakeCtrl.text = preset.$1;
                        _liveModelCtrl.text = preset.$2;
                        _liveYearCtrl.text = preset.$3;
                        _runLiveGlobalVehicleLookup();
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 17-Digit Live NHTSA VIN Decoder
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔍 Canlı 17 Haneli Şasi Numarası (VIN) Çözümleyici (NHTSA API)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _vinCtrl,
                      decoration: const InputDecoration(
                        hintText: '17 Haneli VIN girin...',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _loadingVin ? null : _runVinDecode,
                    child: Text(_loadingVin ? '...' : 'Çözümle'),
                  ),
                ],
              ),
              if (_vinResult != null) ...[
                const SizedBox(height: 10),
                Text(
                  '✓ ${_vinResult!.make} ${_vinResult!.model} (${_vinResult!.modelYear}) — ${_vinResult!.bodyClass}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  'Motor: ${_vinResult!.displacementL}L (${_vinResult!.engineCylinders} Silindir) · Yakıt: ${_vinResult!.fuelType} · Üretim: ${_vinResult!.plantCountry}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // EPA FuelEconomy.gov Live Technical Specs
        _SectionCard(
          title: '⚙️ EPA FuelEconomy.gov Canlı Fabrika Verileri (${_epaSpecs.length})',
          cardColor: cardColor,
          accentColor: accentColor,
          children: _epaSpecs.isEmpty
              ? [
                  const Text(
                    'Bu model yılı için EPA paketi bulunamadı veya yükleniyor. Aşağıdaki resmi NHTSA model listesinden model adına dokunabilirsiniz.',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ]
              : _epaSpecs
                  .map(
                    (s) => Container(
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
                          Text(
                            '${s.year} ${s.make} ${s.model} — ${s.trimDescription}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Motor: ${s.displacementL} · Silindir: ${s.cylinders} · Şanzıman: ${s.transmission}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF93C5FD),
                            ),
                          ),
                          Text(
                            'Çekiş: ${s.drive} · Yakıt: ${s.fuelType} · Emisyon: ${s.co2GramsPerKm}',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ortalama: ${s.combinedConsumption} (Şehir İçi: ${s.cityConsumption} · Otoyol: ${s.highwayConsumption})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF34D399),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),

        // Live NHTSA Safety Recalls
        _SectionCard(
          title: '🚨 Resmi Fabrika Geri Çağırmaları / Recalls (${_liveRecalls.length})',
          cardColor: cardColor,
          accentColor: accentColor,
          children: _liveRecalls.isEmpty
              ? [
                  const Text(
                    'Bu model yılı için kayıtlı aktif geri çağırma bulunmadı.',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ]
              : _liveRecalls
                  .map(
                    (r) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kampanya #${r.campaignNumber} — ${r.component}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFCA5A5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(r.summary, style: const TextStyle(fontSize: 12)),
                          if (r.remedy.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Çözüm: ${r.remedy}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFFA7F3D0),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),

        // Live Real-Owner Complaints (Kronik Arıza & Şikayet Kayıtları)
        _SectionCard(
          title: '⚠️ Gerçek Sürücü Arıza & Şikayet Raporları (${_liveComplaints.length})',
          cardColor: cardColor,
          accentColor: accentColor,
          children: _liveComplaints.isEmpty
              ? [
                  const Text(
                    'Bu model yılı için şikayet kaydı bulunmadı.',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ]
              : _liveComplaints
                  .map(
                    (c) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bileşen: ${c.components} (${c.dateIncident})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                              color: Color(0xFFFDE68A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.summary,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),

        // All Official Models of Brand from NHTSA vPIC
        if (_nhtsaModels.isNotEmpty)
          _SectionCard(
            title:
                '📋 ${_liveYearCtrl.text} ${_liveMakeCtrl.text} Resmi Model Listesi (${_nhtsaModels.length})',
            cardColor: cardColor,
            accentColor: accentColor,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _nhtsaModels
                    .take(40)
                    .map(
                      (m) => ActionChip(
                        label: Text(m),
                        onPressed: () {
                          _liveModelCtrl.text = m;
                          _runLiveGlobalVehicleLookup();
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildOemBoltWorkshopView(Color cardColor, Color accentColor) {
    final filtered = _service.searchCatalog(_query);
    final active = _selectedSpec ?? widget.appState.selectedVehicle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: (val) => setState(() => _query = val),
          decoration: InputDecoration(
            hintText: 'Model, motor kodu (S58, M254) veya cıvata (M14) ara...',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final spec = filtered[idx];
              return ChoiceChip(
                label: Text('${spec.brandName} ${spec.modelName}'),
                selected: spec.id == active.id,
                onSelected: (_) => setState(() => _selectedSpec = spec),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
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
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Car.info Kaynağını Aç',
                    onPressed: () => EmergencyService.openExternalCarInfo(
                      active.carInfoReferenceUrl,
                    ),
                    icon: const Icon(Icons.open_in_new_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricBadge(label: 'Güç', value: '${active.horsepowerHp} HP'),
                  _MetricBadge(label: 'Tork', value: '${active.torqueNm} Nm'),
                  _MetricBadge(label: '0-100', value: '${active.zeroToHundredSec} sn'),
                  _MetricBadge(label: 'Maks Hız', value: '${active.topSpeedKmh} km/s'),
                  _MetricBadge(label: 'Ağırlık', value: '${active.curbWeightKg} kg'),
                  _MetricBadge(label: 'Menzil', value: '${active.rangeOrTankKm} km'),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => widget.appState.selectGarageVehicle(active),
                  icon: const Icon(Icons.garage_rounded, size: 18),
                  label: const Text('Aracı Profilime Seç & Temayı Dönüştür'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        _SectionCard(
          title: '🔩 Cıvata, Diş Ölçüsü, Lokma & Sıkma Torkları (Nm)',
          cardColor: cardColor,
          accentColor: accentColor,
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
                              color: accentColor,
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
                        'Diş: ${b.threadSpec} · Lokma: ${b.socketSize}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF93C5FD),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Not: ${b.notes}',
                        style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),

        _SectionCard(
          title: '⚙️ Motor / Batarya & Vites Dişli Oranları',
          cardColor: cardColor,
          accentColor: accentColor,
          children: [
            _SpecRow('Ünite Kodu', active.engineOrMotorCode),
            _SpecRow('Hacim / Batarya', active.displacementOrBattery),
            _SpecRow('Çap×Strok / Mimari', active.boreStrokeOrVoltage),
            _SpecRow('Şanzıman', active.transmissionName),
            _SpecRow('Çekiş', active.drivetrainLayout),
            const Divider(height: 16),
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

        _SectionCard(
          title: '🛞 Şasi, Fren Disk & Bijon (PCD) Ölçüleri',
          cardColor: cardColor,
          accentColor: accentColor,
          children: [
            _SpecRow('Ön Süspansiyon', active.frontSuspension),
            _SpecRow('Arka Süspansiyon', active.rearSuspension),
            _SpecRow('Ön Fren', active.frontBrakes),
            _SpecRow('Arka Fren', active.rearBrakes),
            _SpecRow('Bijon PCD', active.wheelBoltPatternPcd),
            _SpecRow('Göbek (CB) & ET', active.centerBoreMm),
            _SpecRow('Soğuk Basınç', active.tirePressureColdBar),
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
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
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
            width: 125,
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
