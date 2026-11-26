import 'package:flutter/material.dart';
import '../data/world_brands_engineering.dart';
import '../models/brand_theme_config.dart';
import '../models/live_api_models.dart';
import '../models/user_garage_vehicle.dart';
import '../services/car_info_service.dart';
import '../state/app_state.dart';
import '../widgets/brand_emblem.dart';

class CarEncyclopediaScreen extends StatefulWidget {
  final OtonomAppState appState;

  const CarEncyclopediaScreen({super.key, required this.appState});

  @override
  State<CarEncyclopediaScreen> createState() => _CarEncyclopediaScreenState();
}

class _CarEncyclopediaScreenState extends State<CarEncyclopediaScreen> {
  int _sectionIndex = 0; // 0: Genel & Motor, 1: Cıvata & Tork, 2: Yağ & Bakım, 3: Ekspertiz, 4: Recall & Şikayet
  bool _customSearchExpanded = false;

  final TextEditingController _customMakeCtrl = TextEditingController();
  final TextEditingController _customModelCtrl = TextEditingController();
  final TextEditingController _customYearCtrl =
      TextEditingController(text: '2023');
  PowertrainType _customPowertrain = PowertrainType.gasoline;

  UserGarageVehicle? _customInspectedVehicle;
  LiveWikipediaVehicleSummary? _customWiki;
  List<LiveEpaVehicleSpec> _customEpa = [];
  List<LiveRecallItem> _customRecalls = [];
  List<LiveComplaintItem> _customComplaints = [];
  bool _loadingCustom = false;

  @override
  void dispose() {
    _customMakeCtrl.dispose();
    _customModelCtrl.dispose();
    _customYearCtrl.dispose();
    super.dispose();
  }

  Future<void> _runCustomLookup() async {
    final make = _customMakeCtrl.text.trim();
    final model = _customModelCtrl.text.trim();
    final year = int.tryParse(_customYearCtrl.text.trim()) ?? 2023;
    if (make.isEmpty || model.isEmpty) return;

    final tempVehicle = UserGarageVehicle(
      id: 'temp_lookup',
      make: make,
      model: model,
      year: year,
      powertrain: _customPowertrain,
    );

    setState(() {
      _customInspectedVehicle = tempVehicle;
      _loadingCustom = true;
      _customSearchExpanded = false;
    });

    try {
      final yStr = year.toString();
      final res = await Future.wait([
        widget.appState.liveApis.fetchVehicleWikipediaSummary(
          make: make,
          model: model,
        ),
        widget.appState.liveApis.fetchEpaVehicleSpecs(
          year: yStr,
          make: make,
          model: model,
        ),
        widget.appState.liveApis.fetchRecallsAndComplaints(
          make: make,
          model: model,
          year: yStr,
        ),
      ]);
      if (!mounted) return;
      final safety = res[2]
          as ({List<LiveRecallItem> recalls, List<LiveComplaintItem> complaints});
      setState(() {
        _customWiki = res[0] as LiveWikipediaVehicleSummary?;
        _customEpa = res[1] as List<LiveEpaVehicleSpec>;
        _customRecalls = safety.recalls;
        _customComplaints = safety.complaints;
      });
    } finally {
      if (mounted) {
        setState(() => _loadingCustom = false);
      }
    }
  }

  void _resetToMyGarageCar() {
    setState(() {
      _customInspectedVehicle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final garageCar = widget.appState.activeGarageVehicle;
    final targetCar = _customInspectedVehicle ?? garageCar;
    final brand = WorldBrandsEngineering.buildThemeForVehicle(targetCar);

    final isShowingCustom = _customInspectedVehicle != null;
    final isLoading = isShowingCustom
        ? _loadingCustom
        : widget.appState.isLoadingEncyclopediaDossier;
    final wiki =
        isShowingCustom ? _customWiki : widget.appState.activeWikiSummary;
    final epaSpecs =
        isShowingCustom ? _customEpa : widget.appState.activeEpaSpecs;
    final recalls =
        isShowingCustom ? _customRecalls : widget.appState.activeRecalls;
    final complaints =
        isShowingCustom ? _customComplaints : widget.appState.activeComplaints;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      children: [
        // Top Toolbar: Active Garage Car vs Custom World Car Lookup
        Row(
          children: [
            if (isShowingCustom && garageCar != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  avatar: const Icon(Icons.garage_rounded, size: 16),
                  label: Text('Aracıma Dön (${garageCar.make})'),
                  onPressed: _resetToMyGarageCar,
                ),
              ),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(
                  () => _customSearchExpanded = !_customSearchExpanded,
                ),
                icon: Icon(
                  _customSearchExpanded
                      ? Icons.expand_less_rounded
                      : Icons.manage_search_rounded,
                  size: 18,
                ),
                label: Text(
                  _customSearchExpanded
                      ? 'Arama Panelini Kapat'
                      : 'Başka Bir Aracı Sorgula (Tüm Dünya)',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),

        if (_customSearchExpanded) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141B29),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: brand.primaryColor.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dünyadaki Herhangi Bir Aracı Anında İncele',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _customMakeCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Marka (Örn: Porsche, Honda)',
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
                    Expanded(
                      child: TextField(
                        controller: _customYearCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Yıl',
                          isDense: true,
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _customModelCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Model (Örn: 911, Civic, Passat, Egea)',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final pt in PowertrainType.values)
                      ChoiceChip(
                        visualDensity: VisualDensity.compact,
                        selected: _customPowertrain == pt,
                        label: Text(
                          pt.labelTr,
                          style: const TextStyle(fontSize: 11),
                        ),
                        onSelected: (_) =>
                            setState(() => _customPowertrain = pt),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _runCustomLookup,
                    icon: const Icon(Icons.search_rounded, size: 18),
                    label: const Text('Tüm Mühendislik Dosyasını Çek'),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),

        // Empty State if user hasn't added a car yet and hasn't searched one
        if (targetCar == null)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF131924),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 52,
                  color: brand.secondaryColor,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Kişisel Araç Ansiklopediniz Hazır',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Garajım sekmesinden kendi aracınızı eklediğiniz anda; aracınızın gerçek görseli, motor & tüketim verileri, bijon/karter/kaliper cıvata lokma ölçüleri ve sıkma torkları (Nm), OEM yağ onay kodları, ağır bakım takvimi ve kronik arıza kayıtları burada en ince detayına kadar otomatik açılır.\n\nDilerseniz yukarıdaki "Başka Bir Aracı Sorgula" butonundan hemen şimdi istediğiniz aracı inceleyebilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white70,
                    height: 1.48,
                  ),
                ),
              ],
            ),
          )
        else ...[
          // HERO DOSSIER CARD FOR USER'S CAR
          _VehicleHeroDossierCard(
            vehicle: targetCar,
            brand: brand,
            wiki: wiki,
            isGarageVehicle: !isShowingCustom,
            isLoading: isLoading,
            onRefresh: () => isShowingCustom
                ? _runCustomLookup()
                : widget.appState.refreshActiveVehicleEncyclopediaDossier(),
          ),
          const SizedBox(height: 14),

          // 5 Deep Technical Section Selector Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _SectionTabChip(
                  label: '⚙️ Motor, Tarihçe & Tüketim',
                  selected: _sectionIndex == 0,
                  accent: brand.primaryColor,
                  onTap: () => setState(() => _sectionIndex = 0),
                ),
                const SizedBox(width: 8),
                _SectionTabChip(
                  label: '🔩 Cıvata, Lokma & Tork (Nm)',
                  selected: _sectionIndex == 1,
                  accent: brand.primaryColor,
                  onTap: () => setState(() => _sectionIndex = 1),
                ),
                const SizedBox(width: 8),
                _SectionTabChip(
                  label: '🛢️ OEM Yağ, Sıvı & Bakım',
                  selected: _sectionIndex == 2,
                  accent: brand.primaryColor,
                  onTap: () => setState(() => _sectionIndex = 2),
                ),
                const SizedBox(width: 8),
                _SectionTabChip(
                  label: '🩺 Ekspertiz & Kronik Rehber',
                  selected: _sectionIndex == 3,
                  accent: brand.primaryColor,
                  onTap: () => setState(() => _sectionIndex = 3),
                ),
                const SizedBox(width: 8),
                _SectionTabChip(
                  label:
                      '⚠️ Recall (${recalls.length}) & Şikayet (${complaints.length})',
                  selected: _sectionIndex == 4,
                  accent: brand.primaryColor,
                  onTap: () => setState(() => _sectionIndex = 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (_sectionIndex == 0)
            _EngineAndHistorySection(
              vehicle: targetCar,
              brand: brand,
              wiki: wiki,
              epaSpecs: epaSpecs,
              isLoading: isLoading,
            )
          else if (_sectionIndex == 1)
            _FastenerAndTorqueSection(vehicle: targetCar, brand: brand)
          else if (_sectionIndex == 2)
            _FluidsAndMaintenanceSection(vehicle: targetCar, brand: brand)
          else if (_sectionIndex == 3)
            _ExpertiseAndChronicSection(vehicle: targetCar, brand: brand)
          else
            _SafetyRecallsAndComplaintsSection(
              vehicle: targetCar,
              recalls: recalls,
              complaints: complaints,
              isLoading: isLoading,
            ),
        ],
      ],
    );
  }
}

class _VehicleHeroDossierCard extends StatelessWidget {
  final UserGarageVehicle vehicle;
  final BrandThemeConfig brand;
  final LiveWikipediaVehicleSummary? wiki;
  final bool isGarageVehicle;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _VehicleHeroDossierCard({
    required this.vehicle,
    required this.brand,
    required this.wiki,
    required this.isGarageVehicle,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final matchedProfile = WorldBrandsEngineering.resolveProfile(vehicle.make);
    final boltPattern =
        '${matchedProfile.wheelPcd} · Göbek ${matchedProfile.centerBore}';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            brand.primaryColor.withValues(alpha: 0.28),
            const Color(0xFF121824),
          ],
        ),
        border: Border.all(
          color: brand.primaryColor.withValues(alpha: 0.55),
          width: 1.4,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wiki?.imageUrl != null)
            Stack(
              children: [
                SizedBox(
                  height: 175,
                  width: double.infinity,
                  child: Image.network(
                    wiki!.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isGarageVehicle ? 'GARAJIMDAKİ ARAÇ' : 'CANLI SORGULAMA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: brand.secondaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BrandEmblem(
                      brandId: brand.id,
                      brandName: vehicle.make,
                      primaryColor: brand.primaryColor,
                      secondaryColor: brand.secondaryColor,
                      size: 46,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.fullTitle,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${matchedProfile.make} Mühendislik Dosyası · ${vehicle.powertrain.labelTr}',
                            style: TextStyle(
                              fontSize: 12,
                              color: brand.secondaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Canlı Verileri Yenile',
                      onPressed: onRefresh,
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickBadge(label: 'Yıl', value: '${vehicle.year}'),
                    if (vehicle.horsepower != null)
                      _QuickBadge(
                        label: 'Güç',
                        value: '${vehicle.horsepower} HP',
                      ),
                    if (vehicle.transmission.isNotEmpty)
                      _QuickBadge(
                        label: 'Şanzıman',
                        value: vehicle.transmission,
                      ),
                    if (vehicle.plate.isNotEmpty)
                      _QuickBadge(label: 'Plaka', value: vehicle.plate),
                    if (vehicle.odometerKm != null)
                      _QuickBadge(
                        label: 'Sayaç',
                        value: '${vehicle.odometerKm} km',
                      ),
                    _QuickBadge(label: 'Bijon / Göbek', value: boltPattern),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final slugMake = vehicle.make
                              .toLowerCase()
                              .replaceAll(RegExp(r'[^a-z0-9]+'), '-');
                          CarInfoService.openUrl(
                            'https://www.car.info/en-se/$slugMake',
                          );
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: Text(
                          'car.info ${vehicle.make} Katalog Sayfası',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickBadge extends StatelessWidget {
  final String label;
  final String value;

  const _QuickBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11.5, color: Colors.white),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(color: Colors.white54),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _SectionTabChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? accent : const Color(0xFF151C28),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? accent : Colors.white12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

class _EngineAndHistorySection extends StatelessWidget {
  final UserGarageVehicle vehicle;
  final BrandThemeConfig brand;
  final LiveWikipediaVehicleSummary? wiki;
  final List<LiveEpaVehicleSpec> epaSpecs;
  final bool isLoading;

  const _EngineAndHistorySection({
    required this.vehicle,
    required this.brand,
    required this.wiki,
    required this.epaSpecs,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (wiki != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        size: 18,
                        color: brand.secondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Model Tarihçesi & Nesil Ansiklopedisi (${wiki!.title})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    wiki!.extract,
                    style: const TextStyle(
                      fontSize: 12.8,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  if (wiki!.pageUrl != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => CarInfoService.openUrl(wiki!.pageUrl!),
                        icon: const Icon(Icons.open_in_new_rounded, size: 15),
                        label: const Text('Tam Ansiklopedi Maddesini Aç'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        const Text(
          'Canlı Motor, Şanzıman & Fabrika Tüketim Verileri',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),

        if (isLoading && epaSpecs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (epaSpecs.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.fullTitle} — Mühendislik Konfigürasyonu',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SpecLine('Güç Aktarma Mimarisi', vehicle.powertrain.labelTr),
                  _SpecLine(
                    'Seçilen Donanım / Motor Paketi',
                    vehicle.trim.isNotEmpty
                        ? vehicle.trim
                        : 'Standart Üretim Konfigürasyonu',
                  ),
                  _SpecLine(
                    'Şanzıman Mimarisi',
                    vehicle.transmission.isNotEmpty
                        ? vehicle.transmission
                        : (vehicle.powertrain.isElectric
                            ? 'Tek Oranlı Redüktör Şanzıman'
                            : 'Otomatik / Manuel Şanzıman'),
                  ),
                  _SpecLine(
                    'Beygir Gücü',
                    vehicle.horsepower != null
                        ? '${vehicle.horsepower} HP (${(vehicle.horsepower! * 0.7355).round()} kW)'
                        : 'Model paketine göre değişken',
                  ),
                  _SpecLine(
                    'OBD-II / Teşhis Protokolü',
                    vehicle.year >= 2008
                        ? 'ISO 15765-4 CAN-Bus (11/29 bit, 500 kbps) · 16-Pin J1962'
                        : 'ISO 9141-2 / KWP2000 OBD Portu',
                  ),
                  _SpecLine(
                    'Elektrik / Akü Mimarisi',
                    vehicle.powertrain.isElectric
                        ? '400V–800V HV Lityum-İyon Batarya + 12V Yardımcı Akü'
                        : '12V EFB/AGM Start-Stop Akü Sistemi (13.8V–14.7V Şarj)',
                  ),
                ],
              ),
            ),
          )
        else
          for (final s in epaSpecs)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${s.year} ${s.make} ${s.model} — ${s.trimDescription}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Divider(height: 18, color: Colors.white12),
                    _SpecLine('Motor Hacmi', s.displacementL),
                    _SpecLine('Silindir / Motor', s.cylinders),
                    _SpecLine('Şanzıman', s.transmission),
                    _SpecLine('Çekiş Sistemi', s.drive),
                    _SpecLine('Yakıt / Enerji', s.fuelType),
                    _SpecLine('Karma Tüketim', s.combinedConsumption),
                    _SpecLine('Şehir İçi / Otoyol',
                        '${s.cityConsumption} / ${s.highwayConsumption}'),
                    _SpecLine('CO₂ Emisyonu', s.co2GramsPerKm),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _FastenerAndTorqueSection extends StatelessWidget {
  final UserGarageVehicle vehicle;
  final BrandThemeConfig brand;

  const _FastenerAndTorqueSection({
    required this.vehicle,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final fasteners = WorldBrandsEngineering.buildDetailedBoltSpecs(vehicle);
    final profile = WorldBrandsEngineering.resolveProfile(vehicle.make);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: brand.primaryColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: brand.primaryColor.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Icon(Icons.build_circle_rounded, color: brand.secondaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${vehicle.make} Fabrika Şasi Standardı · Bijon Aralığı (PCD): ${profile.wheelPcd} · Merkez Göbek (CB): ${profile.centerBore}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final f in fasteners)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          f.partName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: brand.primaryColor.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          f.torqueValue,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: brand.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SpecLine('Diş / Cıvata Ölçüsü', f.threadSpec),
                  _SpecLine('Lokma / Anahtar Ucu', f.socketSize),
                  const SizedBox(height: 4),
                  Text(
                    '💡 ${f.notes}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _FluidsAndMaintenanceSection extends StatelessWidget {
  final UserGarageVehicle vehicle;
  final BrandThemeConfig brand;

  const _FluidsAndMaintenanceSection({
    required this.vehicle,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final specs = WorldBrandsEngineering.buildDetailedFluidSpecs(vehicle);
    return Column(
      children: [
        for (final item in specs)
          Card(
            margin: const EdgeInsets.only(bottom: 9),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.systemName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: brand.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _SpecLine('OEM Onay / Spesifikasyon', item.specification),
                  _SpecLine('Dolum Kapasitesi', item.capacity),
                  const SizedBox(height: 4),
                  Text(
                    '🔧 Bakım Periyodu: ${item.interval}',
                    style: const TextStyle(
                      fontSize: 11.8,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ExpertiseAndChronicSection extends StatelessWidget {
  final UserGarageVehicle vehicle;
  final BrandThemeConfig brand;

  const _ExpertiseAndChronicSection({
    required this.vehicle,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final checks = WorldBrandsEngineering.buildExpertiseChecklist(vehicle);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${vehicle.fullTitle} — Ekspertiz & Kronik Kontrol Noktaları',
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < checks.length; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                radius: 15,
                backgroundColor: brand.primaryColor.withValues(alpha: 0.25),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: brand.secondaryColor,
                  ),
                ),
              ),
              title: Text(
                checks[i],
                style: const TextStyle(fontSize: 12.8, height: 1.45),
              ),
            ),
          ),
      ],
    );
  }
}

class _SafetyRecallsAndComplaintsSection extends StatelessWidget {
  final UserGarageVehicle vehicle;
  final List<LiveRecallItem> recalls;
  final List<LiveComplaintItem> complaints;
  final bool isLoading;

  const _SafetyRecallsAndComplaintsSection({
    required this.vehicle,
    required this.recalls,
    required this.complaints,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resmi Geri Çağırma Kayıtları (${recalls.length})',
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (recalls.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                '✅ Bu model/yıl kombinasyonu için aktif küresel NHTSA geri çağırma bülteni bulunmadı.',
                style: TextStyle(fontSize: 12.5, color: Colors.white70),
              ),
            ),
          )
        else
          for (final r in recalls)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ Kampanya #${r.campaignNumber} · ${r.component}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.amberAccent,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      r.summary,
                      style: const TextStyle(fontSize: 12.3, height: 1.4),
                    ),
                    if (r.remedy.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Ücretsiz Çözüm: ${r.remedy}',
                        style: const TextStyle(
                          fontSize: 11.8,
                          color: Color(0xFF34D399),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        const SizedBox(height: 14),
        Text(
          'Sürücü Arıza Bildirimleri (${complaints.length})',
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (complaints.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Bu model/yıl için kayıtlı küresel sürücü arıza bildirimi bulunmuyor.',
                style: TextStyle(fontSize: 12.5, color: Colors.white70),
              ),
            ),
          )
        else
          for (final c in complaints)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ODI #${c.odiNumber} · ${c.components}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.summary,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _SpecLine extends StatelessWidget {
  final String k;
  final String v;

  const _SpecLine(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              k,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
