import 'package:flutter/material.dart';
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
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final brand = widget.appState.brandTheme;
    final activeCar = widget.appState.activeGarageVehicle;
    final screens = [
      NavigationMapScreen(appState: widget.appState),
      RoadsideSosScreen(appState: widget.appState),
      CarEncyclopediaScreen(appState: widget.appState),
      CarRentalScreen(appState: widget.appState),
      ProfileGarageScreen(
        appState: widget.appState,
        onNavigateToEncyclopedia: () => setState(() => _selectedIndex = 2),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        titleSpacing: 16,
        title: GestureDetector(
          onTap: () => setState(() => _selectedIndex = 4),
          child: Row(
            children: [
              BrandEmblem(
                brandId: brand.id,
                brandName: brand.brandName,
                primaryColor: brand.primaryColor,
                secondaryColor: brand.secondaryColor,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'OTONOM',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: brand.primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: brand.primaryColor.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Text(
                              activeCar != null
                                  ? brand.brandName.toUpperCase()
                                  : 'ARAÇ EKLE +',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: brand.secondaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.appState.activeVehicleTitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => widget.appState.refreshAllLiveApis(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.appState.isLoadingLive)
                      const SizedBox(
                        width: 11,
                        height: 11,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF34D399),
                        ),
                      )
                    else
                      const Icon(
                        Icons.wifi_tethering_rounded,
                        size: 14,
                        color: Color(0xFF34D399),
                      ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.appState.onlineApiCount} API',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route_rounded),
            label: 'Rota',
          ),
          NavigationDestination(
            icon: Icon(Icons.emergency_outlined),
            selectedIcon: Icon(Icons.emergency_rounded),
            label: 'Acil',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Ansiklopedi',
          ),
          NavigationDestination(
            icon: Icon(Icons.vpn_key_outlined),
            selectedIcon: Icon(Icons.vpn_key_rounded),
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
