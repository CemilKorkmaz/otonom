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
        titleSpacing: 14,
        title: Row(
          children: [
            BrandEmblem(
              brandId: theme.id,
              size: 38,
              primaryColor: theme.primaryColor,
              secondaryColor: theme.secondaryColor,
              asAppIconTile: true,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'OTONOM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
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
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.appState.selectedVehicle.modelName,
                    style: const TextStyle(fontSize: 11, color: Colors.white60),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Instant 112 SOS button always reachable from top bar
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () =>
                  RoadsideSosScreen.show112EmergencyModal(context, widget.appState),
              icon: const Icon(Icons.sos_rounded, size: 18),
              label: const Text(
                '112',
                style: TextStyle(fontWeight: FontWeight.w900),
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
}
