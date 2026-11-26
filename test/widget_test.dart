import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:otonom/data/world_brands_engineering.dart';
import 'package:otonom/main.dart';
import 'package:otonom/models/brand_theme_config.dart';
import 'package:otonom/models/live_api_models.dart';
import 'package:otonom/models/user_garage_vehicle.dart';
import 'package:otonom/screens/fullscreen_turn_by_turn_screen.dart';
import 'package:otonom/services/live_apis_service.dart';
import 'package:otonom/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Garage starts empty, defaults to neutral Otonom icon, and supports any world car', () async {
    final state = OtonomAppState();
    expect(state.garageVehicles, isEmpty);
    expect(state.brandTheme.dynamicIconKey, 'otonom');

    const passat = UserGarageVehicle(
      id: 'vw_passat_2021',
      make: 'Volkswagen',
      model: 'Passat',
      year: 2021,
      trimOrEngine: '1.5 TSI Elegance DSG',
      powertrain: PowertrainType.gasoline,
      plate: '34 OTN 130',
      customHp: 150,
    );
    await state.addGarageVehicle(passat);

    expect(state.garageVehicles.length, 1);
    expect(state.activeGarageVehicle?.make, 'Volkswagen');
    expect(state.brandTheme.dynamicIconKey, 'otonom');
    expect(state.isElectricVehicle, isFalse);

    final bolts = WorldBrandsEngineering.buildDetailedBoltSpecs(passat);
    expect(bolts.length, greaterThanOrEqualTo(10));
    state.dispose();
  });

  test('Bearing calculation computes accurate compass headings for navigation rotation', () {
    const a = LatLng(41.0000, 29.0000);
    const north = LatLng(41.0500, 29.0000);
    const east = LatLng(41.0000, 29.0500);

    expect(LiveApisService.bearingDegrees(a, north), closeTo(0.0, 1.0));
    expect(LiveApisService.bearingDegrees(a, east), closeTo(90.0, 1.5));
  });

  testWidgets('Otonom v1.3.0 renders iOS Liquid-Glass shell and Fullscreen Turn-by-Turn HUD', (tester) async {
    final state = OtonomAppState();
    await tester.pumpWidget(OtonomApp(appState: state));

    expect(find.text('OTONOM'), findsOneWidget);
    expect(find.text('Rota'), findsOneWidget);
    expect(find.text('Acil'), findsOneWidget);
    expect(find.text('Ansiklopedi'), findsOneWidget);
    expect(find.text('Kiralama'), findsOneWidget);
    expect(find.text('Garajım'), findsOneWidget);

    const mockRoute = LiveOsrmRoute(
      polyline: [
        LatLng(40.9903, 29.0292),
        LatLng(40.9950, 29.0400),
        LatLng(41.0050, 29.0550),
      ],
      distanceKm: 4.8,
      durationMinutes: 9,
      stepInstructions: ['Bağdat Caddesi yönüne sağa dönün'],
      maneuvers: [
        LiveNavManeuverStep(
          location: LatLng(40.9903, 29.0292),
          roadName: 'Başlangıç',
          instructionTr: 'Rota üzerinden ilerleyin',
          turnKind: NavTurnKind.depart,
          distanceMeters: 400,
          durationSeconds: 40,
        ),
        LiveNavManeuverStep(
          location: LatLng(40.9950, 29.0400),
          roadName: 'Bağdat Caddesi',
          instructionTr: 'Bağdat Caddesi yönüne sağa dönün',
          turnKind: NavTurnKind.right,
          distanceMeters: 1200,
          durationSeconds: 110,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FullscreenTurnByTurnScreen(
          appState: state,
          initialRoute: mockRoute,
          destinationTitle: 'Kadıköy Meydan',
          destinationPoint: const LatLng(41.0050, 29.0550),
        ),
      ),
    );

    expect(find.text('Bağdat Caddesi yönüne sağa dönün'), findsOneWidget);
    expect(find.text('Bitir'), findsOneWidget);
    expect(find.text('km/s'), findsOneWidget);
    state.dispose();
  });
}
