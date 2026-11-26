import 'package:flutter/material.dart';
import '../data/mock_automotive_catalog.dart';
import '../models/brand_theme_config.dart';
import '../state/app_state.dart';
import '../widgets/brand_emblem.dart';

class ProfileGarageScreen extends StatefulWidget {
  final OtonomAppState appState;

  const ProfileGarageScreen({super.key, required this.appState});

  @override
  State<ProfileGarageScreen> createState() => _ProfileGarageScreenState();
}

class _ProfileGarageScreenState extends State<ProfileGarageScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _plateCtrl;
  late final TextEditingController _bloodCtrl;
  late final TextEditingController _icePhoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.appState.driverName);
    _plateCtrl = TextEditingController(text: widget.appState.userPlate);
    _bloodCtrl = TextEditingController(text: widget.appState.bloodType);
    _icePhoneCtrl = TextEditingController(text: widget.appState.emergencyContact);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _plateCtrl.dispose();
    _bloodCtrl.dispose();
    _icePhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.appState.brandTheme;
    final activeVehicle = widget.appState.selectedVehicle;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Active Profile & Dynamic Brand App Icon Showcase
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor.withValues(alpha: 0.30),
                theme.cardColor,
              ],
            ),
            border: Border.all(color: theme.primaryColor.withValues(alpha: 0.55)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  BrandEmblem(
                    brandId: theme.id,
                    size: 64,
                    primaryColor: theme.primaryColor,
                    secondaryColor: theme.secondaryColor,
                    asAppIconTile: true,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktif Garaj Aracı: ${activeVehicle.brandName}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: theme.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeVehicle.modelName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Plaka: ${widget.appState.userPlate} · ${activeVehicle.powertrain.labelTr}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Simulated Phone Home Screen App Icon Preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.36),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        BrandEmblem(
                          brandId: theme.id,
                          size: 50,
                          primaryColor: theme.primaryColor,
                          secondaryColor: theme.secondaryColor,
                          asAppIconTile: true,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Otonom',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dinamik Uygulama İkonu & Tema: ${theme.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'iOS (CFBundleAlternateIcons: "${theme.dynamicIconKey}") ve Android (activity-alias) üzerinden telefon ana ekranındaki Otonom logosu aracınıza dönüşür.',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Garajım — Kendi Aracınızı Seçin',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Aracınızı değiştirdiğiniz anda uygulamanın logosu, renk teması ve navigasyondaki istasyon türü (Elektrik Şarj / Benzinlik) otomatik güncellenir.',
          style: TextStyle(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 12),

        for (final vehicle in AutomotiveCatalog.vehicles) ...[
          Builder(
            builder: (context) {
              final vTheme = AutomotiveCatalog.brandThemes[vehicle.brandId]!;
              final isSelected = vehicle.id == activeVehicle.id;
              return GestureDetector(
                onTap: () => widget.appState.selectGarageVehicle(vehicle),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? vTheme.primaryColor.withValues(alpha: 0.18)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? vTheme.primaryColor : Colors.white12,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      BrandEmblem(
                        brandId: vehicle.brandId,
                        size: 46,
                        primaryColor: vTheme.primaryColor,
                        secondaryColor: vTheme.secondaryColor,
                        asAppIconTile: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vehicle.brandName} ${vehicle.modelName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${vehicle.powertrain.labelTr} · ${vehicle.horsepowerHp} HP · ${vehicle.generationChassis}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isSelected ? vTheme.primaryColor : Colors.white38,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],

        const SizedBox(height: 18),
        // Battery / Fuel Slider for Telemetry testing
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mevcut ${widget.appState.isElectricVehicle ? "Batarya Şarj Seviyesi" : "Yakıt Depo Doluluğu"}: %${widget.appState.currentSocOrFuelPercent}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Slider(
                value: widget.appState.currentSocOrFuelPercent.toDouble(),
                min: 5,
                max: 100,
                divisions: 19,
                activeColor: theme.primaryColor,
                onChanged: (v) => widget.appState.updateSocOrFuelPercent(v.round()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 112 Emergency Profile Form
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
              const Text(
                '🩸 112 Kaza & Acil Sağlık Künyesi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Sürücü Ad Soyad'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _plateCtrl,
                decoration: const InputDecoration(labelText: 'Araç Plakası'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bloodCtrl,
                decoration: const InputDecoration(labelText: 'Kan Grubu'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _icePhoneCtrl,
                decoration: const InputDecoration(labelText: 'Acil Durum Yakını Tel'),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    widget.appState.updateEmergencyProfile(
                      driverName: _nameCtrl.text,
                      plate: _plateCtrl.text,
                      bloodType: _bloodCtrl.text,
                      emergencyContact: _icePhoneCtrl.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil ve 112 Acil Künyesi kaydedildi.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Bilgileri Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
