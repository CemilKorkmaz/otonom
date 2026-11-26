import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _selectTab(int idx) {
    if (_selectedIndex == idx) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = idx);
  }

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
        onNavigateToEncyclopedia: () => _selectTab(2),
      ),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xCC0D0D0F),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.10),
                    width: 0.6,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 64,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _selectTab(4),
                            child: Row(
                              children: [
                                BrandEmblem(
                                  brandId: brand.id,
                                  brandName: brand.brandName,
                                  primaryColor: brand.primaryColor,
                                  secondaryColor: brand.secondaryColor,
                                  size: 38,
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'OTONOM',
                                            style: TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.9,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 7),
                                          Flexible(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: brand.primaryColor
                                                    .withValues(alpha: 0.22),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                border: Border.all(
                                                  color: brand.primaryColor
                                                      .withValues(alpha: 0.55),
                                                  width: 0.7,
                                                ),
                                              ),
                                              child: Text(
                                                activeCar != null
                                                    ? brand.brandName
                                                        .toUpperCase()
                                                    : 'ARAÇ EKLE +',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: brand.secondaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.appState.activeVehicleTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF98989D),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Dynamic Island-style Live Telemetry Pill
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.appState.refreshAllLiveApis();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1E),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFF30D158)
                                    .withValues(alpha: 0.45),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.appState.isLoadingLive)
                                  const CupertinoActivityIndicator(radius: 6.5)
                                else
                                  Container(
                                    width: 7.5,
                                    height: 7.5,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF30D158),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                const SizedBox(width: 6),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),

      // Floating iOS 26 Liquid-Glass Capsule Tab Bar
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                height: 66,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.14),
                      const Color(0xD8161618),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 0.75,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.48),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _IosTabItem(
                      label: 'Rota',
                      icon: CupertinoIcons.location_north_line,
                      activeIcon: CupertinoIcons.location_north_fill,
                      selected: _selectedIndex == 0,
                      accent: brand.primaryColor,
                      onTap: () => _selectTab(0),
                    ),
                    _IosTabItem(
                      label: 'Acil',
                      icon: CupertinoIcons.exclamationmark_shield,
                      activeIcon: CupertinoIcons.exclamationmark_shield_fill,
                      selected: _selectedIndex == 1,
                      accent: const Color(0xFFFF453A),
                      onTap: () => _selectTab(1),
                    ),
                    _IosTabItem(
                      label: 'Ansiklopedi',
                      icon: CupertinoIcons.book,
                      activeIcon: CupertinoIcons.book_fill,
                      selected: _selectedIndex == 2,
                      accent: brand.primaryColor,
                      onTap: () => _selectTab(2),
                    ),
                    _IosTabItem(
                      label: 'Kiralama',
                      icon: CupertinoIcons.car_detailed,
                      activeIcon: CupertinoIcons.car_detailed,
                      selected: _selectedIndex == 3,
                      accent: brand.primaryColor,
                      onTap: () => _selectTab(3),
                    ),
                    _IosTabItem(
                      label: 'Garajım',
                      icon: CupertinoIcons.square_stack_3d_up,
                      activeIcon: CupertinoIcons.square_stack_3d_up_fill,
                      selected: _selectedIndex == 4,
                      accent: brand.primaryColor,
                      onTap: () => _selectTab(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IosTabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _IosTabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.24)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? activeIcon : icon,
                size: 21,
                color: selected ? Colors.white : const Color(0xFF8E8E93),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: -0.2,
                  color: selected ? Colors.white : const Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
