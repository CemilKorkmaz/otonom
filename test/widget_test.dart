import 'package:flutter_test/flutter_test.dart';
import 'package:otonom/data/mock_automotive_catalog.dart';
import 'package:otonom/models/brand_theme_config.dart';
import 'package:otonom/models/route_station.dart';
import 'package:otonom/main.dart';
import 'package:otonom/state/app_state.dart';

void main() {
  test('Switching from Tesla EV to BMW M4 switches theme and station category', () async {
    final state = OtonomAppState();

    // Default vehicle is Tesla Model Y (Electric)
    expect(state.selectedVehicle.brandId, CarBrandId.tesla);
    expect(state.isElectricVehicle, isTrue);
    expect(
      state.relevantRouteStations.every((s) => s.category == StationCategory.evCharger),
      isTrue,
    );

    // Switch to BMW M4 Competition (Gasoline)
    final bmw = AutomotiveCatalog.vehicles
        .firstWhere((v) => v.brandId == CarBrandId.bmw);
    await state.selectGarageVehicle(bmw);

    expect(state.selectedVehicle.brandId, CarBrandId.bmw);
    expect(state.brandTheme.shortCode, 'BMW');
    expect(state.isElectricVehicle, isFalse);
    expect(
      state.relevantRouteStations
          .every((s) => s.category == StationCategory.fuelStation),
      isTrue,
    );
  });

  test('Every vehicle contains detailed fastener bolt torque specifications', () {
    for (final v in AutomotiveCatalog.vehicles) {
      expect(v.boltTorqueSpecs, isNotEmpty);
      expect(v.gearRatios, isNotEmpty);
    }
  });

  testWidgets('Otonom app renders main shell and 112 emergency button', (tester) async {
    final state = OtonomAppState();
    await tester.pumpWidget(OtonomApp(appState: state));
    expect(find.text('OTONOM'), findsOneWidget);
    expect(find.text('112'), findsOneWidget);
  });
}
