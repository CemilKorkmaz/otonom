import 'package:flutter/material.dart';
import '../data/mock_automotive_catalog.dart';
import '../models/brand_theme_config.dart';
import '../models/rental_listing.dart';
import '../state/app_state.dart';
import '../widgets/interactive_cockpit_map.dart';

class CarRentalScreen extends StatefulWidget {
  final OtonomAppState appState;

  const CarRentalScreen({super.key, required this.appState});

  @override
  State<CarRentalScreen> createState() => _CarRentalScreenState();
}

class _CarRentalScreenState extends State<CarRentalScreen> {
  String _filter = 'all'; // all, ev, keyless

  @override
  Widget build(BuildContext context) {
    final theme = widget.appState.brandTheme;
    final listings = AutomotiveCatalog.rentals.where((r) {
      if (_filter == 'ev') return r.powertrain.isElectric;
      if (_filter == 'keyless') return r.instantKeylessUnlock;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        const Text(
          'Yakındaki Araç Kiralayanlar (Haritalı P2P)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        const Text(
          'Çevrenizdeki doğrulanmış araç sahiplerini haritadan görün, saatlik/günlük fiyatları karşılaştırın ve dijital anahtarla anında kiralayın.',
          style: TextStyle(fontSize: 12.5, color: Colors.white60),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Tüm Araçlar'),
              selected: _filter == 'all',
              onSelected: (_) => setState(() => _filter = 'all'),
            ),
            ChoiceChip(
              label: const Text('⚡ Sadece Elektrikli'),
              selected: _filter == 'ev',
              onSelected: (_) => setState(() => _filter = 'ev'),
            ),
            ChoiceChip(
              label: const Text('📱 Dijital Anahtarsız Teslim'),
              selected: _filter == 'keyless',
              onSelected: (_) => setState(() => _filter = 'keyless'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 235,
          child: InteractiveCockpitMap(
            mode: CockpitMapMode.rentalMap,
            accentColor: theme.primaryColor,
            rentals: listings,
            onRentalTap: (item) => _openBookingSheet(context, item),
          ),
        ),
        const SizedBox(height: 14),

        for (final item in listings)
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.neighborhood,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (item.instantKeylessUnlock)
                      const Text(
                        '📱 Dijital Anahtar',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF34D399),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.vehicleTitle,
                  style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Araç Sahibi: ${item.hostName} ✓ · ★ ${item.hostRating} (${item.tripCount} kiralama)',
                  style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: item.features
                      .map(
                        (f) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            f,
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₺${item.dailyPriceTry} / gün  ·  ₺${item.hourlyPriceTry} / saat',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Depozito: ₺${item.depositTry} · Günlük ${item.dailyKmLimit} km dahil',
                          style: const TextStyle(fontSize: 11.5, color: Colors.white54),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => _openBookingSheet(context, item),
                      child: const Text('Kirala'),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _openBookingSheet(BuildContext context, RentalListing item) {
    int days = 2;
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.appState.brandTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final total = days * item.dailyPriceTry;
            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.vehicleTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kiralayan: ${item.hostName} (${item.neighborhood}) · Doluluk: %${item.fuelOrBatteryPercent}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Kiralama Süresi (Gün):',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: days > 1
                            ? () => setSheetState(() => days--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$days Gün',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setSheetState(() => days++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kira Tutarı ($days × ₺${item.dailyPriceTry})'),
                      Text(
                        '₺$total',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+ İade Edilebilir Provizyon: ₺${item.depositTry} (Tam Kasko Dahil)',
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${item.vehicleTitle} için $days günlük kiralama talebiniz ${item.hostName}’a iletildi!',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.verified_rounded),
                      label: Text('Rezervasyonu Onayla (₺$total)'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
