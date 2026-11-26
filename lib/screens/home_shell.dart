import 'package:flutter/material.dart';
import '../data/mock_automotive_catalog.dart';
import '../state/app_state.dart';
import '../widgets/brand_emblem.dart';
import 'car_encyclopedia_screen.dart';
import 'car_rental_screen.dart';
import 'navigation_map_screen.dart';
import 'profile_garage_screen.dart';
import 'roadside_sos_screen.dart';

class HomeShell extends StatefulWidget {
  final OtonomAppState appState;

  const HomeShell({super.key, required this.appState});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = widget.appState.brandTheme;
    final onlineCount = widget.appState.onlineApiCount;

    final pages = [
      NavigationMapScreen(
        appState: widget.appState,
        onOpenTowQuick: () {
          setState(() => _currentIndex = 1);
          RoadsideSosScreen.showTowCallModal(
            context,
            AutomotiveCatalog.towTrucks.first,
            widget.appState,
          );
        },
        onOpen112Quick: () {
          RoadsideSosScreen.show112EmergencyModal(context, widget.appState);
        },
      ),
      RoadsideSosScreen(appState: widget.appState),
      CarEncyclopediaScreen(appState: widget.appState),
      CarRentalScreen(appState: widget.appState),
      ProfileGarageScreen(appState: widget.appState),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            BrandEmblem(
              brandId: theme.id,
              size: 36,
              primaryColor: theme.primaryColor,
              secondaryColor: theme.secondaryColor,
              asAppIconTile: true,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'OTONOM',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.7),
                          ),
                        ),
                        child: Text(
                          theme.shortCode,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.appState.selectedVehicle.modelName,
                    style: const TextStyle(fontSize: 10.5, color: Colors.white60),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Live API Telemetry Inspector Button
          IconButton(
            tooltip: 'Canlı API Bağlantı Merkezi',
            onPressed: () => _showLiveApiCenter(context),
            icon: Badge(
              backgroundColor: onlineCount > 0
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
              label: Text('$onlineCount'),
              child: const Icon(Icons.cloud_done_rounded, size: 21),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              ),
              onPressed: () =>
                  RoadsideSosScreen.show112EmergencyModal(context, widget.appState),
              icon: const Icon(Icons.sos_rounded, size: 17),
              label: const Text(
                '112',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: theme.cardColor,
        indicatorColor: theme.primaryColor.withValues(alpha: 0.28),
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.navigation_outlined),
            selectedIcon: Icon(Icons.navigation_rounded),
            label: 'Rota',
          ),
          NavigationDestination(
            icon: Icon(Icons.fire_truck_outlined),
            selectedIcon: Icon(Icons.fire_truck_rounded),
            label: 'Çekici & 112',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Ansiklopedi',
          ),
          NavigationDestination(
            icon: Icon(Icons.car_rental_outlined),
            selectedIcon: Icon(Icons.car_rental_rounded),
            label: 'Kiralama',
          ),
          NavigationDestination(
            icon: Icon(Icons.garage_outlined),
            selectedIcon: Icon(Icons.garage_rounded),
            label: 'Garajım',
          ),
        ],
      ),
    );
  }

  void _showLiveApiCenter(BuildContext context) {
    final statuses = widget.appState.liveApis.statuses.values.toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.appState.brandTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hub_rounded, color: Color(0xFF34D399)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Canlı API Bağlantı & Telemetri Merkezi',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.appState.refreshAllLiveApis();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: const Text('Yenile'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'public-apis ve OpenStreetMap ekosisteminden bağlı gerçek zamanlı ücretsiz servisler:',
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 12),
            if (statuses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('API bağlantıları başlatılıyor, lütfen birkaç saniye bekleyin...'),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: statuses.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (_, i) {
                    final s = statuses[i];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          s.online
                              ? Icons.check_circle_rounded
                              : Icons.warning_amber_rounded,
                          size: 18,
                          color: s.online
                              ? const Color(0xFF34D399)
                              : const Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${s.name} (${s.latencyMs} ms)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${s.provider} — ${s.summary}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
