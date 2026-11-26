import 'package:flutter/material.dart';
import '../data/world_brands_engineering.dart';
import '../models/brand_theme_config.dart';
import '../models/user_garage_vehicle.dart';
import '../state/app_state.dart';
import '../widgets/brand_emblem.dart';

class ProfileGarageScreen extends StatefulWidget {
  final OtonomAppState appState;
  final VoidCallback? onNavigateToEncyclopedia;

  const ProfileGarageScreen({
    super.key,
    required this.appState,
    this.onNavigateToEncyclopedia,
  });

  @override
  State<ProfileGarageScreen> createState() => _ProfileGarageScreenState();
}

class _ProfileGarageScreenState extends State<ProfileGarageScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _plateController;
  late final TextEditingController _emergencyContactController;
  String _selectedBloodType = 'A Rh (+)';

  static const _bloodTypes = [
    'A Rh (+)',
    'A Rh (-)',
    'B Rh (+)',
    'B Rh (-)',
    'AB Rh (+)',
    'AB Rh (-)',
    '0 Rh (+)',
    '0 Rh (-)',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.appState.driverName == 'Sürücü'
          ? ''
          : widget.appState.driverName,
    );
    _plateController = TextEditingController(
      text: widget.appState.userPlate == 'Belirtilmedi'
          ? ''
          : widget.appState.userPlate,
    );
    _emergencyContactController = TextEditingController(
      text: widget.appState.emergencyContact,
    );
    _selectedBloodType = widget.appState.bloodType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _openAddWorldVehicleSheet() async {
    final added = await showModalBottomSheet<UserGarageVehicle>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0E1420),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => _AddWorldVehicleSheet(appState: widget.appState),
    );

    if (added != null && mounted) {
      await widget.appState.addGarageVehicle(added);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${added.fullTitle} garajınıza eklendi! Tema ve Ansiklopedi aracınıza göre güncellendi.',
          ),
          action: widget.onNavigateToEncyclopedia != null
              ? SnackBarAction(
                  label: 'Ansiklopediyi Aç',
                  onPressed: widget.onNavigateToEncyclopedia!,
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = widget.appState.brandTheme;
    final garage = widget.appState.garageVehicles;
    final activeCar = widget.appState.activeGarageVehicle;
    final statuses = widget.appState.liveApis.statuses.values.toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // 1. Personal Garage Header & Add Any Car CTA
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                brand.primaryColor.withValues(alpha: 0.30),
                const Color(0xFF121824),
              ],
            ),
            border: Border.all(
              color: brand.primaryColor.withValues(alpha: 0.55),
              width: 1.4,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BrandEmblem(
                    brandId: brand.id,
                    brandName: brand.brandName,
                    primaryColor: brand.primaryColor,
                    secondaryColor: brand.secondaryColor,
                    size: 56,
                    asAppIconTile: true,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeCar != null
                              ? activeCar.fullTitle
                              : 'Kişisel Garajım',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          activeCar != null
                              ? '${activeCar.powertrain.labelTr} · "${brand.slogan}"'
                              : 'Dünya üzerindeki dilediğiniz marka, model ve paketteki aracı garajınıza ekleyin.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: brand.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _openAddWorldVehicleSheet,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text(
                    'Dünya Üzerindeki Herhangi Bir Aracı Ekle',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. User's Own Vehicles (Zero hardcoded sample vehicles!)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Garajımdaki Araçlar (${garage.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            if (garage.isNotEmpty)
              TextButton.icon(
                onPressed: _openAddWorldVehicleSheet,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Yeni Ekle'),
              ),
          ],
        ),
        const SizedBox(height: 8),

        if (garage.isEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF121824),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.directions_car_filled_rounded,
                  size: 46,
                  color: brand.secondaryColor.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Garajınızda Henüz Araç Yok',
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Hazır örnek araçlar kaldırıldı. Klasik, modern, yerli veya ithal — dünya üzerindeki istediğiniz herhangi bir aracı ekleyerek uygulama temasını, yakıt/şarj istasyonlarını ve Ansiklopedi teknik dosyasını kendi aracınıza göre kişiselleştirin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _openAddWorldVehicleSheet,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('İlk Aracımı Ekle'),
                ),
              ],
            ),
          )
        else
          for (final vehicle in garage) ...[
            _UserGarageCarCard(
              vehicle: vehicle,
              isSelected: activeCar?.id == vehicle.id,
              onSelect: () =>
                  widget.appState.selectActiveGarageVehicle(vehicle.id),
              onDelete: () => widget.appState.removeGarageVehicle(vehicle.id),
              onOpenEncyclopedia: () async {
                await widget.appState.selectActiveGarageVehicle(vehicle.id);
                widget.onNavigateToEncyclopedia?.call();
              },
            ),
            const SizedBox(height: 12),
          ],

        const SizedBox(height: 16),

        // 3. Emergency & Driver Profile
        const Text(
          '112 Acil Yardım & Sürücü Kimliği',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Sürücü Ad Soyad',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _plateController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'Varsayılan Plaka',
                          hintText: '34 ABC 123',
                          prefixIcon: const Icon(Icons.pin_outlined),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedBloodType,
                        decoration: InputDecoration(
                          labelText: 'Kan Grubu',
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: _bloodTypes
                            .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedBloodType = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emergencyContactController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Yakın / Acil İletişim Numarası',
                    prefixIcon: const Icon(Icons.contact_phone_outlined),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: brand.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () async {
                      await widget.appState.updateEmergencyProfile(
                        driverName: _nameController.text.trim(),
                        plate: _plateController.text.trim(),
                        bloodType: _selectedBloodType,
                        emergencyContact:
                            _emergencyContactController.text.trim(),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Sürücü ve 112 profili kaydedildi.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Profili Kaydet'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 4. Live API Telemetry Monitor
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Canlı API Bağlantı Durumu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            TextButton.icon(
              onPressed: () => widget.appState.refreshAllLiveApis(),
              icon: const Icon(Icons.sync_rounded, size: 16),
              label: const Text('Tümünü Yenile'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: statuses.isEmpty
                ? const Text(
                    'Canlı servisler kontrol ediliyor...',
                    style: TextStyle(fontSize: 12.5, color: Colors.white70),
                  )
                : Column(
                    children: [
                      for (final st in statuses)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                st.online
                                    ? Icons.check_circle_rounded
                                    : Icons.error_outline_rounded,
                                size: 17,
                                color: st.online
                                    ? const Color(0xFF34D399)
                                    : Colors.amber,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${st.name} (${st.provider})',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      st.summary,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${st.latencyMs} ms',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
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

class _UserGarageCarCard extends StatelessWidget {
  final UserGarageVehicle vehicle;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onDelete;
  final VoidCallback onOpenEncyclopedia;

  const _UserGarageCarCard({
    required this.vehicle,
    required this.isSelected,
    required this.onSelect,
    required this.onDelete,
    required this.onOpenEncyclopedia,
  });

  @override
  Widget build(BuildContext context) {
    final vTheme = WorldBrandsEngineering.buildThemeForVehicle(vehicle);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? vTheme.primaryColor.withValues(alpha: 0.16)
              : const Color(0xFF131924),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? vTheme.primaryColor : Colors.white12,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BrandEmblem(
                  brandId: vTheme.id,
                  brandName: vehicle.make,
                  primaryColor: vTheme.primaryColor,
                  secondaryColor: vTheme.secondaryColor,
                  size: 46,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: vTheme.primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'AKTİF ARAÇ',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              vehicle.fullTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            vehicle.powertrain.labelTr,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: vTheme.secondaryColor,
                            ),
                          ),
                          if (vehicle.plate.isNotEmpty)
                            Text(
                              '· 🪪 ${vehicle.plate}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.white70,
                              ),
                            ),
                          if (vehicle.horsepower != null)
                            Text(
                              '· ${vehicle.horsepower} HP',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.white70,
                              ),
                            ),
                          if (vehicle.transmission.isNotEmpty)
                            Text(
                              '· ${vehicle.transmission}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.white60,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Aracı Garajdan Kaldır',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenEncyclopedia,
                    icon: const Icon(Icons.menu_book_rounded, size: 16),
                    label: const Text(
                      'Ansiklopedide Tüm Detaylarını Gör',
                      style: TextStyle(fontSize: 12),
                    ),
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

class _AddWorldVehicleSheet extends StatefulWidget {
  final OtonomAppState appState;

  const _AddWorldVehicleSheet({required this.appState});

  @override
  State<_AddWorldVehicleSheet> createState() => _AddWorldVehicleSheetState();
}

class _AddWorldVehicleSheetState extends State<_AddWorldVehicleSheet> {
  final TextEditingController _makeCtrl = TextEditingController();
  final TextEditingController _modelCtrl = TextEditingController();
  final TextEditingController _trimCtrl = TextEditingController();
  final TextEditingController _yearCtrl = TextEditingController(text: '2023');
  final TextEditingController _plateCtrl = TextEditingController();
  final TextEditingController _hpCtrl = TextEditingController();
  final TextEditingController _transmissionCtrl = TextEditingController();
  final TextEditingController _kmCtrl = TextEditingController();

  PowertrainType _powertrain = PowertrainType.gasoline;
  String _brandFilter = '';
  List<String> _liveFetchedModels = [];
  bool _loadingLiveModels = false;

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _trimCtrl.dispose();
    _yearCtrl.dispose();
    _plateCtrl.dispose();
    _hpCtrl.dispose();
    _transmissionCtrl.dispose();
    _kmCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchModelsFromGlobalApis() async {
    final make = _makeCtrl.text.trim();
    final year = _yearCtrl.text.trim();
    if (make.isEmpty || year.length != 4) return;

    setState(() => _loadingLiveModels = true);
    final list = await widget.appState.liveApis.fetchGlobalModelsForMakeYear(
      make: make,
      year: year,
    );
    if (!mounted) return;
    setState(() {
      _liveFetchedModels = list;
      _loadingLiveModels = false;
    });
  }

  void _selectBrandPreset(BrandEngineeringProfile preset) {
    setState(() {
      _makeCtrl.text = preset.make;
      if (preset.make == 'Tesla' ||
          preset.make == 'Togg' ||
          preset.make == 'BYD') {
        _powertrain = PowertrainType.electric;
      }
    });
    _fetchModelsFromGlobalApis();
  }

  void _submitVehicle() {
    final make = _makeCtrl.text.trim();
    final model = _modelCtrl.text.trim();
    final year = int.tryParse(_yearCtrl.text.trim()) ?? 2023;

    if (make.isEmpty || model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az Marka ve Model alanlarını doldurun.'),
        ),
      );
      return;
    }

    final vehicle = UserGarageVehicle(
      id: 'car_${DateTime.now().millisecondsSinceEpoch}',
      make: make,
      model: model,
      year: year.clamp(1920, 2027),
      trimOrEngine: _trimCtrl.text.trim(),
      powertrain: _powertrain,
      plate: _plateCtrl.text.trim().toUpperCase(),
      transmission: _transmissionCtrl.text.trim(),
      customHp: int.tryParse(_hpCtrl.text.trim()),
      odometerKm: int.tryParse(_kmCtrl.text.trim()),
    );
    Navigator.pop(context, vehicle);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final filteredBrands = WorldBrandsEngineering.brands.where((b) {
      if (_brandFilter.trim().isEmpty) return true;
      return b.make.toLowerCase().contains(_brandFilter.trim().toLowerCase());
    }).toList();

    final matchedPreset =
        WorldBrandsEngineering.resolveProfile(_makeCtrl.text.trim());
    final combinedSuggestedModels = <String>{
      ...matchedPreset.popularModels,
      ..._liveFetchedModels,
    }.toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 16, 18, 22 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Dünya Üzerindeki Herhangi Bir Aracı Ekle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'Listeden seçebilir veya dünyada üretilmiş herhangi bir marka, model ve motor paketini doğrudan yazabilirsiniz.',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 14),

            // Step 1: Quick Global Brand Picker + Free Make Input
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filteredBrands.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (ctx, i) {
                  final b = filteredBrands[i];
                  final selected =
                      _makeCtrl.text.trim().toLowerCase() == b.make.toLowerCase();
                  return ActionChip(
                    backgroundColor: selected
                        ? b.primaryColor.withValues(alpha: 0.32)
                        : Colors.white10,
                    side: BorderSide(
                      color: selected ? b.primaryColor : Colors.white12,
                    ),
                    label: Text(
                      b.make,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () => _selectBrandPreset(b),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _makeCtrl,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (v) => setState(() => _brandFilter = v),
                    onSubmitted: (_) => _fetchModelsFromGlobalApis(),
                    decoration: InputDecoration(
                      labelText: 'Marka (Örn: Volkswagen, Fiat, BMW...)',
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _yearCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      if (v.trim().length == 4) _fetchModelsFromGlobalApis();
                    },
                    decoration: InputDecoration(
                      labelText: 'Model Yılı',
                      hintText: '2023',
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Model input + Instant Suggestions from Catalog + Live NHTSA/EPA API
            TextField(
              controller: _modelCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Model (Örn: Passat, Egea, Megane, 320i, Civic...)',
                suffixIcon: _loadingLiveModels
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        tooltip: 'Canlı Model Listesini Çek',
                        icon: const Icon(Icons.cloud_download_outlined),
                        onPressed: _fetchModelsFromGlobalApis,
                      ),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),

            if (combinedSuggestedModels.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: combinedSuggestedModels.take(35).length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (ctx, idx) {
                    final m = combinedSuggestedModels[idx];
                    return ActionChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(m, style: const TextStyle(fontSize: 11.5)),
                      onPressed: () => setState(() => _modelCtrl.text = m),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 10),

            TextField(
              controller: _trimCtrl,
              decoration: InputDecoration(
                labelText: 'Motor & Donanım Paketi (Opsiyonel)',
                hintText: 'Örn: 1.5 TSI Elegance / 1.3 Multijet / Long Range',
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'Yakıt / Güç Aktarma Tipi (Rota İstasyonlarını Belirler)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final pt in PowertrainType.values)
                  ChoiceChip(
                    selected: _powertrain == pt,
                    label: Text(
                      pt.labelTr,
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    onSelected: (_) => setState(() => _powertrain = pt),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _plateCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Plaka (Opsiyonel)',
                      hintText: '34 ABC 123',
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _hpCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Güç (HP)',
                      hintText: '150',
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _transmissionCtrl,
                    decoration: InputDecoration(
                      labelText: 'Şanzıman (Opsiyonel)',
                      hintText: 'DSG / ZF8 / Manuel',
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _kmCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Kilometre (Opsiyonel)',
                      hintText: '45000',
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _submitVehicle,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text(
                  'Garajıma Ekle ve Ansiklopediyi Hazırla',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
