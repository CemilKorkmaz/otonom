import 'package:flutter/material.dart';
import '../data/mock_automotive_catalog.dart';
import '../models/brand_theme_config.dart';
import '../models/live_api_models.dart';
import '../models/rental_listing.dart';
import '../services/emergency_service.dart';
import '../state/app_state.dart';
import '../widgets/live_osm_cockpit_map.dart';

class CarRentalScreen extends StatefulWidget {
  final OtonomAppState appState;

  const CarRentalScreen({super.key, required this.appState});

  @override
  State<CarRentalScreen> createState() => _CarRentalScreenState();
}

class _CarRentalScreenState extends State<CarRentalScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final theme = appState.brandTheme;
    final liveRentals = appState.liveRentalPlaces;

    final p2pListings = AutomotiveCatalog.rentals.where((r) {
      if (_filter == 'ev') return r.powertrain.isElectric;
      if (_filter == 'keyless') return r.instantKeylessUnlock;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        const Text(
          'Canlı Haritalı Araç Kiralama (OSM + P2P)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        const Text(
          'OpenStreetMap Overpass API ile gerçek GPS konumunuzun çevresindeki kiralama ofisleri ve doğrulanmış P2P araç sahipleri listelenir.',
          style: TextStyle(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 255,
          child: LiveOsmCockpitMap(
            userLocation: appState.currentLocation,
            pois: liveRentals,
            accentColor: theme.primaryColor,
            darkTiles: appState.darkMapTiles,
            onToggleTileStyle: appState.toggleMapTileStyle,
            onRecenterGps: appState.refreshAllLiveApis,
            onPoiTap: (poi) => _openLiveRentalPoiSheet(context, poi),
          ),
        ),
        const SizedBox(height: 14),

        if (liveRentals.isNotEmpty) ...[
          Text(
            '🟢 Konumunuza En Yakın Canlı Kiralama Noktaları (${liveRentals.length})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF34D399),
            ),
          ),
          const SizedBox(height: 8),
          for (final poi in liveRentals.take(8))
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poi.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${poi.distanceKm.toStringAsFixed(2)} km uzakta · ${poi.address ?? poi.subtitle}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _openLiveRentalPoiSheet(context, poi),
                    child: const Text('Detay'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
        ],

        Row(
          children: [
            const Expanded(
              child: Text(
                '🔑 P2P Sahibinden Anında Kiralık Araçlar',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
            ChoiceChip(
              label: const Text('⚡ EV'),
              selected: _filter == 'ev',
              onSelected: (v) => setState(() => _filter = v ? 'ev' : 'all'),
            ),
          ],
        ),
        const SizedBox(height: 10),

        for (final item in p2pListings)
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
                Text(
                  item.vehicleTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  'Sahibi: ${item.hostName} ✓ · ★ ${item.hostRating} · ${item.neighborhood}',
                  style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '₺${item.dailyPriceTry}/gün · ₺${item.hourlyPriceTry}/saat',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
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

  void _openLiveRentalPoiSheet(BuildContext context, LivePoiItem poi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.appState.brandTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poi.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(poi.subtitle, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text(
              'Uzaklık: ${poi.distanceKm.toStringAsFixed(2)} km',
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (poi.phone != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => EmergencyService.dialPhoneNumber(poi.phone!),
                      icon: const Icon(Icons.call_rounded),
                      label: const Text('Ofisi Ara'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
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
                    label: const Text('Ofise Rota Çiz'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
      builder: (ctx) => StatefulBuilder(
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Kiralama Süresi:'),
                    const Spacer(),
                    IconButton(
                      onPressed:
                          days > 1 ? () => setSheetState(() => days--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$days Gün',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      onPressed: () => setSheetState(() => days++),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${item.vehicleTitle} için $days günlük rezervasyon talebi iletildi!',
                          ),
                        ),
                      );
                    },
                    child: Text('Onayla (₺$total)'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
