import 'package:flutter_test/flutter_test.dart';
import 'package:otonom/data/world_brands_engineering.dart';
import 'package:otonom/main.dart';
import 'package:otonom/models/brand_theme_config.dart';
import 'package:otonom/models/user_garage_vehicle.dart';
import 'package:otonom/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Garage starts empty and allows adding any vehicle in the world', () async {
    final state = OtonomAppState();
    expect(state.garageVehicles, isEmpty);
    expect(state.activeGarageVehicle, isNull);

    const passat = UserGarageVehicle(
      id: 'vw_passat_2021',
      make: 'Volkswagen',
      model: 'Passat',
      year: 2021,
      trimOrEngine: '1.5 TSI Elegance DSG',
      powertrain: PowertrainType.gasoline,
      plate: '34 OTN 120',
      customHp: 150,
    );
    await state.addGarageVehicle(passat);

    expect(state.garageVehicles.length, 1);
    expect(state.activeGarageVehicle?.make, 'Volkswagen');
    expect(state.isElectricVehicle, isFalse);

    final bolts = WorldBrandsEngineering.buildDetailedBoltSpecs(passat);
    final fluids = WorldBrandsEngineering.buildDetailedFluidSpecs(passat);
    expect(bolts.length, greaterThanOrEqualTo(10));
    expect(fluids, isNotEmpty);

    const togg = UserGarageVehicle(
      id: 'togg_t10x_2024',
      make: 'Togg',
      model: 'T10X',
      year: 2024,
      trimOrEngine: 'V2 Uzun Menzil',
      powertrain: PowertrainType.electric,
    );
    await state.addGarageVehicle(togg);
    expect(state.activeGarageVehicle?.make, 'Togg');
    expect(state.brandTheme.id, CarBrandId.togg);
    expect(state.isElectricVehicle, isTrue);
  });

  testWidgets('Otonom v1.2.0 renders Acil single-word navigation label', (tester) async {
    final state = OtonomAppState();
    await tester.pumpWidget(OtonomApp(appState: state));
    expect(find.text('OTONOM'), findsOneWidget);
    expect(find.text('Rota'), findsOneWidget);
    expect(find.text('Acil'), findsOneWidget);
    expect(find.text('Ansiklopedi'), findsOneWidget);
    expect(find.text('Kiralama'), findsOneWidget);
    expect(find.text('Garajım'), findsOneWidget);
  });
}
