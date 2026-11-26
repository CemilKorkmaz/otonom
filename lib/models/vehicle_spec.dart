import 'brand_theme_config.dart';

class FastenerTorqueSpec {
  final String partName;
  final String threadSpec; // e.g. M14 x 1.25 Konik 60°
  final String socketSize; // e.g. 17mm Hex / E14 Torx
  final String torqueValue; // e.g. 140 Nm or 30 Nm + 90° + 90°
  final String notes; // e.g. Loctite 243 / Yenisiyle değiştirin (TTY)

  const FastenerTorqueSpec({
    required this.partName,
    required this.threadSpec,
    required this.socketSize,
    required this.torqueValue,
    required this.notes,
  });
}

class FluidCapacitySpec {
  final String systemName;
  final String specification;
  final String capacity;
  final String interval;

  const FluidCapacitySpec({
    required this.systemName,
    required this.specification,
    required this.capacity,
    required this.interval,
  });
}

class VehicleSpec {
  final String id;
  final CarBrandId brandId;
  final String brandName;
  final String modelName;
  final String generationChassis; // e.g. G82 / Juniper / W206 / C8
  final String productionYears;
  final PowertrainType powertrain;
  final String carInfoReferenceUrl;

  // Headline performance
  final int horsepowerHp;
  final int torqueNm;
  final double zeroToHundredSec;
  final int topSpeedKmh;
  final int curbWeightKg;
  final int rangeOrTankKm;
  final String consumptionLabel; // e.g. 16.9 kWh/100km or 10.1 L/100km

  // Engine / Electric Drive deep specs
  final String engineOrMotorCode;
  final String displacementOrBattery;
  final String boreStrokeOrVoltage;
  final String compressionOrChemistry;
  final String firingOrderOrInverter;
  final String transmissionName;
  final List<String> gearRatios;
  final String drivetrainLayout;

  // Chassis, brakes & wheels
  final String frontSuspension;
  final String rearSuspension;
  final String frontBrakes;
  final String rearBrakes;
  final String wheelBoltPatternPcd;
  final String centerBoreMm;
  final String frontTireSpec;
  final String rearTireSpec;
  final String tirePressureColdBar;

  // Bolts & torque specs ("en küçük cıvatasına kadar")
  final List<FastenerTorqueSpec> boltTorqueSpecs;

  // Fluids & capacities
  final List<FluidCapacitySpec> fluidSpecs;

  // Electrical & ECU
  final String ecuOrController;
  final String auxBatterySpec;
  final List<String> sensorAndFuseNotes;

  // Known chronic issues & inspection tips
  final List<String> chronicIssuesAndTips;

  const VehicleSpec({
    required this.id,
    required this.brandId,
    required this.brandName,
    required this.modelName,
    required this.generationChassis,
    required this.productionYears,
    required this.powertrain,
    required this.carInfoReferenceUrl,
    required this.horsepowerHp,
    required this.torqueNm,
    required this.zeroToHundredSec,
    required this.topSpeedKmh,
    required this.curbWeightKg,
    required this.rangeOrTankKm,
    required this.consumptionLabel,
    required this.engineOrMotorCode,
    required this.displacementOrBattery,
    required this.boreStrokeOrVoltage,
    required this.compressionOrChemistry,
    required this.firingOrderOrInverter,
    required this.transmissionName,
    required this.gearRatios,
    required this.drivetrainLayout,
    required this.frontSuspension,
    required this.rearSuspension,
    required this.frontBrakes,
    required this.rearBrakes,
    required this.wheelBoltPatternPcd,
    required this.centerBoreMm,
    required this.frontTireSpec,
    required this.rearTireSpec,
    required this.tirePressureColdBar,
    required this.boltTorqueSpecs,
    required this.fluidSpecs,
    required this.ecuOrController,
    required this.auxBatterySpec,
    required this.sensorAndFuseNotes,
    required this.chronicIssuesAndTips,
  });
}
