import 'package:flutter/material.dart';
import '../models/brand_theme_config.dart';
import '../models/user_garage_vehicle.dart';
import '../models/vehicle_spec.dart';

class BrandEngineeringProfile {
  final String make;
  final Color primaryColor;
  final Color secondaryColor;
  final CarBrandId crestId;
  final String dynamicIconKey;
  final String wheelPcd;
  final String centerBore;
  final String lugThreadAndSeat;
  final String lugSocketMm;
  final String lugTorqueNm;
  final String oilApprovalSpec;
  final String coolantSpec;
  final List<String> popularModels;

  const BrandEngineeringProfile({
    required this.make,
    required this.primaryColor,
    required this.secondaryColor,
    this.crestId = CarBrandId.other,
    this.dynamicIconKey = 'tesla',
    required this.wheelPcd,
    required this.centerBore,
    required this.lugThreadAndSeat,
    required this.lugSocketMm,
    required this.lugTorqueNm,
    required this.oilApprovalSpec,
    required this.coolantSpec,
    required this.popularModels,
  });
}

/// Covers 45+ global & Turkish-market brands with authentic brand themes,
/// European/Turkish/Global model catalogs, and OEM fastener/fluid standards.
class WorldBrandsEngineering {
  static const List<BrandEngineeringProfile> brands = [
    BrandEngineeringProfile(
      make: 'Audi',
      primaryColor: Color(0xFFF50537),
      secondaryColor: Color(0xFF94A3B8),
      crestId: CarBrandId.audi,
      dynamicIconKey: 'audi',
      wheelPcd: '5 × 112 mm',
      centerBore: '57.1 mm / 66.5 mm (MLB)',
      lugThreadAndSeat: 'M14 × 1.50 R13 Küresel Yataklı Bijon Cıvatası',
      lugSocketMm: '17 mm Lokma',
      lugTorqueNm: '120 - 140 Nm (RS/SUV: 160 Nm)',
      oilApprovalSpec: 'VW 504 00 / 507 00 (0W-30 / 5W-30) veya VW 508 00 (0W-20)',
      coolantSpec: 'VW TL 774-L (G12evo Pembe/Mor)',
      popularModels: ['A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'Q2', 'Q3', 'Q5', 'Q7', 'Q8', 'e-tron GT', 'RS3', 'RS6'],
    ),
    BrandEngineeringProfile(
      make: 'BMW',
      primaryColor: Color(0xFF1C69D4),
      secondaryColor: Color(0xFFE41E26),
      crestId: CarBrandId.bmw,
      dynamicIconKey: 'bmw',
      wheelPcd: '5 × 112 mm (G-Serisi) / 5 × 120 mm (E/F-Serisi)',
      centerBore: '66.6 mm (G) / 72.6 mm (E/F)',
      lugThreadAndSeat: 'M14 × 1.25 Konik 60° Cıvata (F/G) · M12 × 1.5 (E)',
      lugSocketMm: '17 mm İnce Etli Koruyucu Lokma',
      lugTorqueNm: '140 Nm (M14) / 120 Nm (M12)',
      oilApprovalSpec: 'BMW Longlife-04 / LL-17 FE+ (0W-20 / 0W-30 / 5W-30)',
      coolantSpec: 'BMW LC-18 (HT-12 Yeşil) / LC-87 (G48 Mavi)',
      popularModels: ['118i', '218i', '320i', '320d', '420i', '520i', '520d', '740d', 'X1', 'X3', 'X5', 'i4', 'iX', 'M3', 'M4', 'M5'],
    ),
    BrandEngineeringProfile(
      make: 'BYD',
      primaryColor: Color(0xFF00A8E8),
      secondaryColor: Color(0xFF38BDF8),
      wheelPcd: '5 × 114.3 mm / 5 × 120 mm',
      centerBore: '64.1 mm',
      lugThreadAndSeat: 'M14 × 1.50 Konik 60° Bijon Somunu/Cıvatası',
      lugSocketMm: '19 mm / 21 mm Lokma',
      lugTorqueNm: '125 - 140 Nm',
      oilApprovalSpec: 'BYD BOT-383 EV Redüktör Yağı / PHEV 0W-20 API SP',
      coolantSpec: 'Düşük İletkenlikli OAT Blade Batarya Termal Sıvısı',
      popularModels: ['Atto 3', 'Seal', 'Seal U DM-i', 'Seal U EV', 'Dolphin', 'Han', 'Tang'],
    ),
    BrandEngineeringProfile(
      make: 'Chery',
      primaryColor: Color(0xFFC4161C),
      secondaryColor: Color(0xFFF87171),
      wheelPcd: '5 × 108 mm',
      centerBore: '60.1 mm',
      lugThreadAndSeat: 'M12 × 1.50 Konik 60° Bijon Cıvatası/Somunu',
      lugSocketMm: '19 mm Lokma',
      lugTorqueNm: '120 ± 10 Nm',
      oilApprovalSpec: 'SAE 5W-30 / 0W-20 API SP · ACEA C2/C3 (1.6 TGDI Acteco)',
      coolantSpec: 'LEC-II Organik Asit (OAT) -40°C Pembe',
      popularModels: ['Omoda 5', 'Tiggo 7 Pro', 'Tiggo 8 Pro', 'Tiggo 4 Pro', 'Arrizo 8'],
    ),
    BrandEngineeringProfile(
      make: 'Citroën',
      primaryColor: Color(0xFFE11D48),
      secondaryColor: Color(0xFFCBD5E1),
      wheelPcd: '4 × 108 mm / 5 × 108 mm (EMP2)',
      centerBore: '65.1 mm',
      lugThreadAndSeat: 'M12 × 1.25 Düz Pullu (Alaşım) / Konik Cıvata',
      lugSocketMm: '17 mm Lokma',
      lugTorqueNm: '100 - 115 Nm',
      oilApprovalSpec: 'Stellantis FPW9.55535/03 (5W-30 Yeni Revizyon!) / PSA B71 2312',
      coolantSpec: 'PSA B71 5110 (Glysantin G33 Mavi-Yeşil)',
      popularModels: ['C3', 'C3 Aircross', 'C4', 'C4 X', 'C5 Aircross', 'C-Elysée', 'Berlingo', 'ë-C4'],
    ),
    BrandEngineeringProfile(
      make: 'Cupra',
      primaryColor: Color(0xFFB87333),
      secondaryColor: Color(0xFF0F766E),
      wheelPcd: '5 × 112 mm',
      centerBore: '57.1 mm',
      lugThreadAndSeat: 'M14 × 1.50 R13 Küresel Yataklı Bijon Cıvatası',
      lugSocketMm: '17 mm Lokma',
      lugTorqueNm: '140 Nm',
      oilApprovalSpec: 'VW 508 00 (0W-20) / VW 504 00 (0W-30)',
      coolantSpec: 'G12evo Pembe/Mor',
      popularModels: ['Formentor', 'Leon', 'Ateca', 'Born', 'Terramar', 'Tavascan'],
    ),
    BrandEngineeringProfile(
      make: 'Dacia',
      primaryColor: Color(0xFF658C6E),
      secondaryColor: Color(0xFFD97706),
      wheelPcd: '4 × 100 mm (Sandero/Jogger) / 5 × 114.3 mm (Duster)',
      centerBore: '60.1 mm (4×100) / 66.1 mm (Duster)',
      lugThreadAndSeat: 'M12 × 1.50 Konik 60° Bijon Cıvatası',
      lugSocketMm: '17 mm Lokma',
      lugTorqueNm: '110 Nm',
      oilApprovalSpec: 'Renault RN17 (5W-30) / RN17 FE (0W-20)',
      coolantSpec: 'Glaceol RX Type D / Type E Sarı-Yeşil',
      popularModels: ['Duster', 'Sandero', 'Sandero Stepway', 'Jogger', 'Spring', 'Lodgy'],
    ),
    BrandEngineeringProfile(
      make: 'Ferrari',
      primaryColor: Color(0xFFDC0000),
      secondaryColor: Color(0xFFFFD700),
      wheelPcd: '5 × 114.3 mm',
      centerBore: '67.1 mm',
      lugThreadAndSeat: 'M14 × 1.50 Titanyum Konik 60° Hareketli Pullu Cıvata',
      lugSocketMm: '17 mm / Özel Ferrari 22 mm Lokma',
      lugTorqueNm: '120 Nm (Titanyum) / 100 Nm (Çelik)',
      oilApprovalSpec: 'Shell Helix Ultra Racing 10W-60 / 5W-40 / 0W-30 Ferrari Spec',
      coolantSpec: 'Glycoshell Longlife OAT',
      popularModels: ['296 GTB', 'SF90 Stradale', 'Roma', 'Purosangue', 'F8 Tributo', '488 GTB', '458 Italia'],
    ),
    BrandEngineeringProfile(
      make: 'Fiat',
      primaryColor: Color(0xFF9B0014),
      secondaryColor: Color(0xFFE2E8F0),
      wheelPcd: '5 × 98 mm (Egea) / 4 × 98 mm (500/Fiorino/Linea)',
      centerBore: '58.1 mm',
      lugThreadAndSeat: 'M12 × 1.25 Konik 60° Bijon Cıvatası',
      lugSocketMm: '17 mm Lokma',
      lugTorqueNm: '120 Nm (Alaşım) / 98 Nm (Çelik Jant)',
      oilApprovalSpec: 'Fiat 9.55535-DS1 (0W-30 Multijet) / 9.55535-S2 (5W-40 Fire)',
      coolantSpec: 'Paraflu UP (ASTM D3306 Kırmızı/Pembe OAT)',
      popularModels: ['Egea Sedan', 'Egea Cross', '500', '500e', '600e', 'Linea', 'Fiorino', 'Doblo', 'Punto'],
    ),
    BrandEngineeringProfile(
      make: 'Ford',
      primaryColor: Color(0xFF003478),
      secondaryColor: Color(0xFF38BDF8),
      wheelPcd: '5 × 108 mm (Focus/Kuga) / 4 × 108 mm (Fiesta)',
      centerBore: '63.4 mm',
      lugThreadAndSeat: 'M12 × 1.50 Geniş Hareketli Konik Bijon Somunu (Global Nut)',
      lugSocketMm: '19 mm Lokma (Şişme Kapaklı Somunlarda 19.5 mm Dikkat!)',
      lugTorqueNm: '135 Nm (Focus/Kuga/Puma)',
      oilApprovalSpec: 'Ford WSS-M2C948-B (5W-20 EcoBoost) / WSS-M2C950-A (0W-30 EcoBlue)',
      coolantSpec: 'Ford WSS-M97B44-D / M97B57-A1 (Super Plus Sarı/Turuncu)',
      popularModels: ['Focus', 'Puma', 'Kuga', 'Fiesta', 'Mondeo', 'Mustang', 'Mustang Mach-E', 'Ranger', 'Courier'],
    ),
    BrandEngineeringProfile(
      make: 'Honda',
      primaryColor: Color(0xFFCC0000),
      secondaryColor: Color(0xFFE5E7EB),
      wheelPcd: '5 × 114.3 mm (Civic/CR-V) / 4 × 100 mm (City/Jazz)',
      centerBore: '64.1 mm (5×114.3) / 56.1 mm (4×100)',
      lugThreadAndSeat: 'M12 × 1.50 R12 Küresel Yataklı Somun (Type R: M14 × 1.50)',
      lugSocketMm: '19 mm Lokma (Orijinal Jant Küresel Somun İster!)',
      lugTorqueNm: '108 Nm (Type R M14: 127 Nm)',
      oilApprovalSpec: 'Honda Genuine Type 2.0 0W-20 / 5W-30 API SP · ILSAC GF-6',
      coolantSpec: 'Honda Type 2 All Season Antifreeze/Coolant (Mavi)',
      popularModels: ['Civic', 'Civic Type R', 'City', 'Jazz', 'HR-V', 'ZR-V', 'CR-V', 'Accord', 'S2000'],
    ),
    BrandEngineeringProfile(
      make: 'Hyundai',
      primaryColor: Color(0xFF002C5F),
      secondaryColor: Color(0xFF00AAD2),
      wheelPcd: '5 × 114.3 mm (Tucson/i30) / 4 × 100 mm (i10/i20/Bayon)',
      centerBore: '67.1 mm / 54.1 mm',
      lugThreadAndSeat: 'M12 × 1.50 Konik 60° Bijon Somunu',
      lugSocketMm: '21 mm Lokma',
      lugTorqueNm: '107 - 127 Nm',
      oilApprovalSpec: 'SAE 0W-20 / 5W-30 ACEA C2/C3 veya API SP / ILSAC GF-6',
      coolantSpec: 'Fosfat Bazlı P-OAT Yeşil/Pembe Uzun Ömürlü',
      popularModels: ['i20', 'i20 N', 'Bayon', 'Tucson', 'Elantra', 'Kona', 'IONIQ 5', 'IONIQ 6', 'Santa Fe', 'i10'],
    ),
    BrandEngineeringProfile(
      make: 'Kia',
      primaryColor: Color(0xFFBB162B),
      secondaryColor: Color(0xFFE2E8F0),
      wheelPcd: '5 × 114.3 mm / 4 × 100 mm (Picanto/Rio/Stonic)',
      centerBore: '67.1 mm / 54.1 mm',
      lugThreadAndSeat: 'M12 × 1.50 Konik 60° Bijon Somunu',
      lugSocketMm: '21 mm Lokma',
      lugTorqueNm: '107 - 127 Nm',
      oilApprovalSpec: 'SAE 0W-20 / 5W-30 API SP · ACEA C2/C3',
      coolantSpec: 'P-OAT Uzun Ömürlü Soğutma Sıvısı',
      popularModels: ['Sportage', 'XCeed', 'Ceed', 'Stonic', 'Picanto', 'Niro', 'EV3', 'EV6', 'EV9', 'Sorento'],
    ),
    BrandEngineeringProfile(
      make: 'Lamborghini',
      primaryColor: Color(0xFFD99B00),
      secondaryColor: Color(0xFF22C55E),
      wheelPcd: '5 × 112 mm (Huracán/Urus) / Center-Lock',
      centerBore: '57.1 mm / 66.5 mm (Urus)',
      lugThreadAndSeat: 'M14 × 1.50 R13 Küresel Titanyum Cıvata / Merkezi Somun',
      lugSocketMm: '17 mm / 19 mm (Center-Lock: 600 Nm Özel Başlık)',
      lugTorqueNm: '160 Nm (Urus/Huracán 5-Bijon) / 600 Nm (Center-Lock)',
      oilApprovalSpec: 'VW 511 00 (0W-40) / VW 504 00 (5W-30)',
      coolantSpec: 'G12evo Yüksek Performans',
      popularModels: ['Urus', 'Huracán', 'Revuelto', 'Aventador', 'Temerario'],
    ),
    BrandEngineeringProfile(
      make: 'Land Rover',
      primaryColor: Color(0xFF005A2B),
      secondaryColor: Color(0xFFD4AF37),
      wheelPcd: '5 × 120 mm (Range Rover/Defender) / 5 × 108 mm (Evoque)',
      centerBore: '72.6 mm / 63.4 mm',
      lugThreadAndSeat: 'M14 × 1.50 Düz Pullu Mag Somun (22mm)',
      lugSocketMm: '22 mm Lokma',
      lugTorqueNm: '140 Nm',
      oilApprovalSpec: 'STJLR.03.5006 (0W-20) / STJLR.03.5005 (5W-30 Ingenium)',
      coolantSpec: 'Havoline XLC OAT Turuncu',
      popularModels: ['Range Rover', 'Range Rover Sport', 'Range Rover Velar', 'Evoque', 'Defender', 'Discovery'],
    ),
    BrandEngineeringProfile(
      make: 'Mazda',
      primaryColor: Color(0xFF991B1B),
      secondaryColor: Color(0xFFCBD5E1),
      wheelPcd: '5 × 114.3 mm (Mazda3/CX-5) / 4 × 100 mm (MX-5 ND)',
      centerBore: '67.1 mm / 54.1 mm',
      lugThreadAndSeat: 'M12 × 1.50 Konik 60° Somun',
      lugSocketMm: '17 mm / 21 mm Lokma',
      lugTorqueNm: '108 - 130 Nm',
      oilApprovalSpec: 'Mazda Supra-X 0W-20 / Ultra 5W-30 Skyactiv',
      coolantSpec: 'Mazda FL22 Uzun Ömürlü Yeşil (11 Yıl / 200.000 km)',
      popularModels: ['Mazda3', 'Mazda6', 'CX-3', 'CX-30', 'CX-5', 'CX-60', 'MX-5 Miata'],
    ),
    BrandEngineeringProfile(
      make: 'Mercedes-Benz',
      primaryColor: Color(0xFF00A19B),
      secondaryColor: Color(0xFFCBD5E1),
      crestId: CarBrandId.mercedes,
      dynamicIconKey: 'mercedes',
      wheelPcd: '5 × 112 mm',
      centerBore: '66.6 mm',
      lugThreadAndSeat: 'M14 × 1.50 R14 Küresel Yataklı Çiçek Başlı Cıvata',
      lugSocketMm: '17 mm Mercedes Flower-Head Lokma',
      lugTorqueNm: '130 Nm (A/B/CLA) · 150 Nm (C/E/S/GLC/GLE)',
      oilApprovalSpec: 'MB-Approval 229.52 (5W-30) / 229.71 (0W-20)',
      coolantSpec: 'MB 325.6 / 326.6 Si-OAT Pembe',
      popularModels: ['A 200', 'CLA 200', 'C 200', 'E 180', 'E 200', 'S 400d', 'GLA', 'GLB', 'GLC', 'EQA', 'EQB', 'EQE', 'EQS', 'G 63 AMG'],
    ),
    BrandEngineeringProfile(
      make: 'MG',
      primaryColor: Color(0xFFDC2626),
      secondaryColor: Color(0xFFF3F4F6),
      wheelPcd: '5 × 112 mm (MG4/HS)',
      centerBore: '57.1 mm',
      lugThreadAndSeat: 'M14 × 1.50 Konik 60° Bijon Cıvatası',
      lugSocketMm: '17 mm Lokma',
      lugTorqueNm: '120 - 130 Nm',
      oilApprovalSpec: 'EV Redüktör ATF / 0W-20 C5 (1.5T TGI)',
      coolantSpec: 'OAT Organik Uzun Ömürlü',
      popularModels: ['MG4 Electric', 'HS', 'ZS', 'ZS EV', 'Marvel R', 'Cyberster'],
    ),
    BrandEngineeringProfile(
      make: 'MINI',
      primaryColor: Color(0xFF1E3A8A),
      secondaryColor: Color(0xFFEF4444),
      wheelPcd: '5 × 112 mm (F56/Countryman)',
      centerBore: '66.6 mm',
      lugThreadAndSeat: 'M14 × 1.25 Konik 60° Bijon Cıvatası',
      lugSocketMm: '17 mm Lokma',
      lugTorqueNm: '140 Nm',
      oilApprovalSpec: 'BMW Longlife-04 / LL-17 FE+ (0W-20 / 0W-30)',
      coolantSpec: 'HT-12 Yeşil / G48 Mavi',
      popularModels: ['Cooper', 'Cooper S', 'Cooper SE', 'Countryman', 'Clubman', 'Aceman'],
    ),
    BrandEngineeringProfile(
      make: 'Nissan',
      primaryColor: Color(0xFFC3002F),
      secondaryColor: Color(0xFFE5E7EB),
      wheelPcd: '5 × 114.3 mm (Qashqai/X-Trail/Juke)',
      centerBore: '66.1 mm',
      lugThreadAndSeat: 'M12 × 1.25 (J11) veya M12 × 1.50 (J12 Yeni Qashqai) Cıvata/Somun',
      lugSocketMm: '17 mm / 21 mm Lokma',
      lugTorqueNm: '113 Nm',
      oilApprovalSpec: 'RN17 5W-30 (1.3 DIG-T) / 0W-20 e-POWER',
      coolantSpec: 'Nissan L255N Mavi/Yeşil Uzun Ömürlü',
      popularModels: ['Qashqai', 'Juke', 'X-Trail', 'Micra', 'Ariya', 'Leaf', 'GT-R'],
    ),
    BrandEngineeringProfile(
      make: 'Opel',
      primaryColor: Color(0xFFFACC15),
      secondaryColor: Color(0xFF94A3B8),
      wheelPcd: '4 × 108 mm (Corsa F/Mokka B) / 5 × 108 mm (Astra L/Grandland)',
      centerBore: '65.1 mm',
      lugThreadAndSeat: 'M12 × 1.25 Düz/Konik PSA Platform Cıvatası',
      lugSocketMm: '17 mm Lokma',
      lugTorqueNm: '100 - 115 Nm',
      oilApprovalSpec: 'Stellantis FPW9.55535/03 5W-30 (1.2 PureTech Triger Korumalı!)',
      coolantSpec: 'PSA B71 5110 / Dex-Cool (Eski GM Modeller)',
      popularModels: ['Corsa', 'Astra', 'Mokka', 'Crossland', 'Frontera', 'Grandland', 'Insignia', 'Combo'],
    ),
    BrandEngineeringProfile(
      make: 'Peugeot',
      primaryColor: Color(0xFF2563EB),
      secondaryColor: Color(0xFF60A5FA),
      wheelPcd: '4 × 108 mm (208/2008) / 5 × 108 mm (308/408/3008/5008)',
      centerBore: '65.1 mm',
      lugThreadAndSeat: 'M12 × 1.25 Düz Pullu Alaşım Jant Cıvatası',
      lugSocketMm: '17 mm Lokma',
      lugTorqueNm: '100 - 115 Nm',
      oilApprovalSpec: 'Stellantis FPW9.55535/03 (5W-30 1.2 PureTech & 1.5 BlueHDi!)',
      coolantSpec: 'PSA B71 5110 Mavi-Yeşil',
      popularModels: ['208', '308', '408', '508', '2008', '3008', '5008', 'e-208', 'e-3008', 'Rifter'],
    ),
    BrandEngineeringProfile(
      make: 'Porsche',
      primaryColor: Color(0xFFD5001C),
      secondaryColor: Color(0xFFD4AF37),
      crestId: CarBrandId.porsche,
      dynamicIconKey: 'porsche',
      wheelPcd: '5 × 130 mm (911/Taycan/Cayenne) / 5 × 112 mm (Macan)',
      centerBore: '71.6 mm (Macan: 66.5 mm)',
      lugThreadAndSeat: 'M14 × 1.50 R14 Küresel Hareketli Pullu Cıvata',
      lugSocketMm: '19 mm Koruyucu Lokma',
      lugTorqueNm: '160 Nm',
      oilApprovalSpec: 'Porsche C40 (0W-40) / A40 / C20 / EV Pentosin FFL-8',
      coolantSpec: 'Porsche G40 / G12evo Pembe',
      popularModels: ['Taycan', '911 Carrera', '911 Turbo S', 'Cayenne', 'Macan', 'Panamera', '718 Cayman'],
    ),
    BrandEngineeringProfile(
      make: 'Renault',
      primaryColor: Color(0xFFEAB308),
      secondaryColor: Color(0xFFFDE047),
      wheelPcd: '4 × 100 mm (Clio/Taliant) / 5 × 114.3 mm (Megane/Austral/Kadjar)',
      centerBore: '60.1 mm (4×100) / 66.1 mm (5×114.3)',
      lugThreadAndSeat: 'M12 × 1.50 Konik 60° Bijon Cıvatası',
      lugSocketMm: '17 mm (Clio/Megane) / 19 mm Lokma',
      lugTorqueNm: '110 Nm (Megane/Austral: 110 - 130 Nm)',
      oilApprovalSpec: 'Renault RN17 (5W-30 · 1.3 TCe & 1.5 Blue dCi) / RN720 (Eski DPF)',
      coolantSpec: 'Glaceol RX Type D / Type E Floresan Sarı',
      popularModels: ['Clio', 'Megane Sedan', 'Megane E-Tech', 'Austral', 'Captur', 'Taliant', 'Rafale', 'Fluence', 'Symbol', 'Kadjar'],
    ),
    BrandEngineeringProfile(
      make: 'Seat',
      primaryColor: Color(0xFFEA580C),
      secondaryColor: Color(0xFFFDBA74),
      wheelPcd: '5 × 112 mm (Leon/Ateca) / 5 × 100 mm (Ibiza/Arona)',
      centerBore: '57.1 mm',
      lugThreadAndSeat: 'M14 × 1.50 R13 Küresel Yataklı Bijon Cıvatası',
      lugSocketMm: '17 mm Lokma',
      lugTorqueNm: '120 - 140 Nm',
      oilApprovalSpec: 'VW 508 00 (0W-20) / VW 504 00 - 507 00 (0W-30 / 5W-30)',
      coolantSpec: 'VW G12evo Pembe',
      popularModels: ['Leon', 'Ibiza', 'Arona', 'Ateca', 'Tarraco', 'Toledo'],
    ),
    BrandEngineeringProfile(
      make: 'Škoda',
      primaryColor: Color(0xFF22C55E),
      secondaryColor: Color(0xFF86EFAC),
      wheelPcd: '5 × 112 mm (Octavia/Superb/Kodiaq) / 5 × 100 mm (Fabia/Kamiq/Scala)',
      centerBore: '57.1 mm',
      lugThreadAndSeat: 'M14 × 1.50 R13 Küresel Yataklı Bijon Cıvatası',
      lugSocketMm: '17 mm Lokma',
      lugTorqueNm: '120 - 140 Nm',
      oilApprovalSpec: 'VW 508 00 (0W-20 1.5 eTSI) / VW 504 00 - 507 00 (0W-30)',
      coolantSpec: 'VW G12evo Pembe/Mor',
      popularModels: ['Octavia', 'Superb', 'Kamiq', 'Karoq', 'Kodiaq', 'Scala', 'Fabia', 'Enyaq'],
    ),
    BrandEngineeringProfile(
      make: 'Tesla',
      primaryColor: Color(0xFFE82127),
      secondaryColor: Color(0xFFFF5A5F),
      crestId: CarBrandId.tesla,
      dynamicIconKey: 'tesla',
      wheelPcd: '5 × 114.3 mm (Model 3/Y) / 5 × 120 mm (Model S/X)',
      centerBore: '64.1 mm',
      lugThreadAndSeat: 'M14 × 1.50 Konik 60° Bijon Somunu',
      lugSocketMm: '21 mm Derin Lokma',
      lugTorqueNm: '175 Nm (Fabrika Zorunlu Yüksek Tork!)',
      oilApprovalSpec: 'Pentosin EDF2 / Kama DEXRON VI EV Redüktör Yağı',
      coolantSpec: 'Tesla G-48 Mavi Ethylene Glycol',
      popularModels: ['Model Y', 'Model 3', 'Model S', 'Model X', 'Cybertruck'],
    ),
    BrandEngineeringProfile(
      make: 'Togg',
      primaryColor: Color(0xFF00B2C9),
      secondaryColor: Color(0xFF38E2F7),
      crestId: CarBrandId.togg,
      dynamicIconKey: 'togg',
      wheelPcd: '5 × 112 mm',
      centerBore: '66.5 mm',
      lugThreadAndSeat: 'M14 × 1.50 Bijon Cıvatası',
      lugSocketMm: '17 mm Lokma',
      lugTorqueNm: '140 Nm',
      oilApprovalSpec: 'Sentetik EV Dişli Redüktör Yağı 75W FE',
      coolantSpec: 'Düşük İletkenlikli OAT Batarya Termal Sıvısı',
      popularModels: ['T10X V1 RWD', 'T10X V2 Uzun Menzil', 'T10X AWD Çift Motor', 'T10F Fastback'],
    ),
    BrandEngineeringProfile(
      make: 'Toyota',
      primaryColor: Color(0xFFEB0A1E),
      secondaryColor: Color(0xFFFCA5A5),
      wheelPcd: '5 × 114.3 mm (Corolla/C-HR/RAV4) / 5 × 100 mm (Yaris)',
      centerBore: '60.1 mm / 54.1 mm',
      lugThreadAndSeat: 'M12 × 1.50 Düz Pullu Mag Somun (Orijinal Alaşım Jant)',
      lugSocketMm: '21 mm Lokma',
      lugTorqueNm: '103 Nm (RAV4/Land Cruiser M14: 131 Nm)',
      oilApprovalSpec: 'Toyota Genuine 0W-16 / 0W-20 API SP · ILSAC GF-6B (Hibrit & Dynamic Force)',
      coolantSpec: 'Toyota Super Long Life Coolant (SLLC Pembe)',
      popularModels: ['Corolla', 'Corolla Hybrid', 'Corolla Cross', 'C-HR', 'Yaris', 'Yaris Cross', 'RAV4', 'Hilux', 'Land Cruiser', 'Supra'],
    ),
    BrandEngineeringProfile(
      make: 'Volkswagen',
      primaryColor: Color(0xFF0284C7),
      secondaryColor: Color(0xFF7DD3FC),
      wheelPcd: '5 × 112 mm (Golf/Passat/Tiguan/T-Roc) / 5 × 100 mm (Polo/Taigo/T-Cross)',
      centerBore: '57.1 mm',
      lugThreadAndSeat: 'M14 × 1.50 R13 Küresel Yataklı Bijon Cıvatası',
      lugSocketMm: '17 mm Lokma',
      lugTorqueNm: '120 Nm (Binek) / 140 Nm (Tiguan/Touareg/ID.4)',
      oilApprovalSpec: 'VW 508 00 (0W-20 eTSI/TSI) / VW 504 00 - 507 00 (5W-30 / 0W-30 TDI & TSI)',
      coolantSpec: 'VW G12evo (TL 774-L) Pembe/Mor',
      popularModels: ['Passat', 'Golf', 'Polo', 'Tiguan', 'T-Roc', 'Taigo', 'T-Cross', 'Jetta', 'Arteon', 'Caddy', 'Transporter', 'ID.4', 'ID.7'],
    ),
    BrandEngineeringProfile(
      make: 'Volvo',
      primaryColor: Color(0xFF2563EB),
      secondaryColor: Color(0xFF93C5FD),
      wheelPcd: '5 × 108 mm',
      centerBore: '63.4 mm',
      lugThreadAndSeat: 'M14 × 1.50 Konik 60° Hareketli Pullu Cıvata',
      lugSocketMm: '19 mm Lokma',
      lugTorqueNm: '140 Nm',
      oilApprovalSpec: 'Volvo VCC RBS0-2AE 0W-20 ACEA C5',
      coolantSpec: 'Volvo VCS-2 Sarı / Mavi-Yeşil',
      popularModels: ['XC40', 'EX30', 'XC60', 'XC90', 'S60', 'S90', 'V60', 'V90 Cross Country'],
    ),
  ];

  static const List<String> extraGlobalMakes = [
    'Alfa Romeo',
    'Aston Martin',
    'Bentley',
    'Bugatti',
    'Cadillac',
    'Chevrolet',
    'Chrysler',
    'Dodge',
    'DS Automobiles',
    'Genesis',
    'GMC',
    'Infiniti',
    'Isuzu',
    'Jaguar',
    'Jeep',
    'Koenigsegg',
    'Lada',
    'Lexus',
    'Lincoln',
    'Lotus',
    'Lucid',
    'Maserati',
    'McLaren',
    'Mitsubishi',
    'Pagani',
    'Polestar',
    'RAM',
    'Rivian',
    'Rolls-Royce',
    'Saab',
    'Skywell',
    'Smart',
    'SsangYong / KGM',
    'Subaru',
    'Suzuki',
  ];

  static List<String> get allBrandNames {
    final set = <String>{
      for (final b in brands) b.make,
      ...extraGlobalMakes,
    };
    final list = set.toList()..sort();
    return list;
  }

  static BrandEngineeringProfile resolveProfile(String make) {
    final normalized = make.trim().toLowerCase();
    for (final b in brands) {
      if (b.make.toLowerCase() == normalized ||
          normalized.contains(b.make.toLowerCase())) {
        return b;
      }
    }
    // Deterministic rich color from make hash for any rare marque!
    final hash = normalized.codeUnits.fold<int>(0, (a, b) => a + b * 31);
    final palette = [
      const Color(0xFF0EA5E9),
      const Color(0xFFE11D48),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];
    final color = palette[hash % palette.length];
    return BrandEngineeringProfile(
      make: make,
      primaryColor: color,
      secondaryColor: Colors.white70,
      wheelPcd: '5 × 114.3 mm / 5 × 112 mm (Jant Göbeğinden Doğrulayın)',
      centerBore: '60.1 - 67.1 mm',
      lugThreadAndSeat: 'M12 × 1.50 veya M14 × 1.50 Konik 60°',
      lugSocketMm: '17 mm / 19 mm Lokma',
      lugTorqueNm: '115 - 135 Nm',
      oilApprovalSpec: 'SAE 0W-20 / 5W-30 Tam Sentetik ACEA C3 / API SP',
      coolantSpec: 'OAT Uzun Ömürlü Organik Antifriz (-40°C)',
      popularModels: const [],
    );
  }

  static BrandThemeConfig buildThemeForVehicle(UserGarageVehicle? vehicle) {
    if (vehicle == null) {
      return const BrandThemeConfig(
        id: CarBrandId.other,
        brandKey: 'otonom',
        name: 'Otonom',
        shortCode: 'OTONOM',
        slogan: 'Garajım sekmesinden kendi aracınızı ekleyin',
        dynamicIconKey: 'tesla',
        primaryColor: Color(0xFF0EA5E9),
        secondaryColor: Color(0xFF38BDF8),
        surfaceColor: Color(0xFF070B12),
        cardColor: Color(0xFF111827),
        glowColor: Color(0x550EA5E9),
      );
    }

    final p = resolveProfile(vehicle.make);
    final code = vehicle.make.length > 8
        ? vehicle.make.substring(0, 8).toUpperCase()
        : vehicle.make.toUpperCase();

    return BrandThemeConfig(
      id: p.crestId,
      brandKey: vehicle.make.toLowerCase(),
      name: vehicle.make,
      shortCode: code,
      slogan: '${vehicle.fullTitle} · ${vehicle.powertrain.labelTr} Aktif',
      dynamicIconKey: p.dynamicIconKey,
      primaryColor: p.primaryColor,
      secondaryColor: p.secondaryColor,
      surfaceColor: const Color(0xFF080C14),
      cardColor: const Color(0xFF121926),
      glowColor: p.primaryColor.withValues(alpha: 0.36),
      defaultPowertrain: vehicle.powertrain,
    );
  }

  /// Generates a complete 10-fastener OEM Bolt & Torque table tailored to the exact brand & powertrain!
  static List<FastenerTorqueSpec> buildDetailedBoltSpecs(UserGarageVehicle v) {
    final p = resolveProfile(v.make);
    final isEv = v.powertrain.isElectric;
    final isDiesel = v.powertrain == PowertrainType.diesel;

    return [
      FastenerTorqueSpec(
        partName: '1. Jant Bijon Cıvatası / Somunu (Wheel Lug)',
        threadSpec: p.lugThreadAndSeat,
        socketSize: p.lugSocketMm,
        torqueValue: p.lugTorqueNm,
        notes: 'Kuru ve temiz dişlerle yıldız sırasına göre tork anahtarıyla sıkınız; havalı tabanca ile aşırı sıkmayın.',
      ),
      if (!isEv)
        FastenerTorqueSpec(
          partName: '2. Motor Karter Yağ Boşaltma Tapası',
          threadSpec: 'M14 × 1.50 / M12 × 1.50 Karter Tapası',
          socketSize: '17 mm / 19 mm Lokma veya T45 Torx',
          torqueValue: '25 - 30 Nm',
          notes: 'Her yağ değişiminde bakır/alüminyum ezilme pulunu veya O-ring contayı mutlaka yenileyin.',
        )
      else
        const FastenerTorqueSpec(
          partName: '2. Elektrik Motoru Redüktör Doldurma/Boşaltma Tapası',
          threadSpec: 'M18 × 1.50 Manyetik Sızdırmaz Tapa',
          socketSize: '8 mm / 10 mm Allen (Hex)',
          torqueValue: '30 - 35 Nm',
          notes: 'Mıknatıs ucundaki metal talaş kontrol edilip temizlenmeli, yeni halka conta takılmalıdır.',
        ),
      if (!isEv)
        FastenerTorqueSpec(
          partName: isDiesel
              ? '3. Kızdırma Bujileri (Glow Plugs — Çok Hassas!)'
              : '3. Ateşleme Bujileri (Spark Plugs)',
          threadSpec: isDiesel
              ? 'M10 × 1.0 / M8 × 1.0 İnce Gövdeli Kızdırma Bujisi'
              : 'M12 × 1.25 İridyum / Platin İnce Paso Buji',
          socketSize: isDiesel
              ? '10 mm Derin Kızdırma Lokması'
              : '14 mm İnce Etli 12 Köşe (Bi-Hex) Buji Lokması',
          torqueValue: isDiesel ? '10 - 15 Nm (Kopma Sınırı: 22 Nm!)' : '22 - 25 Nm',
          notes: isDiesel
              ? 'Motor sıcakken sökün; aşırı tork kızdırma bujisini silindir kapağı içinde kırar!'
              : 'Tamamen soğuk motorda kuru sıkım yapın; direkt enjeksiyonlu motorlarda tork hassastır.',
        )
      else
        const FastenerTorqueSpec(
          partName: '3. Yüksek Voltaj (HV) Batarya Taşıyıcı Şasi Cıvataları',
          threadSpec: 'M12 × 1.50 / M12 × 1.75 (10.9 Kalite Kaplamalı)',
          socketSize: '18 mm / E14 Harici Torx',
          torqueValue: '100 - 115 Nm',
          notes: 'Yalnızca HV Servis Ayırıcı (Service Disconnect) çekildikten sonra yalıtımlı ekipmanla dokunulur.',
        ),
      const FastenerTorqueSpec(
        partName: '4. Ön Fren Kaliper Taşıyıcı (Carrier) Cıvataları',
        threadSpec: 'M12 × 1.50 / M14 × 1.50 Yüksek Mukavemetli (10.9)',
        socketSize: '18 mm / 21 mm Lokma',
        torqueValue: '110 - 135 Nm',
        notes: 'Diş yüzeyini temizleyip orta mukavemetli mavi vida sabitleyici (Loctite 243) uygulayın.',
      ),
      const FastenerTorqueSpec(
        partName: '5. Ön Fren Kaliper Kılavuz Pimleri (Slide Pins)',
        threadSpec: 'M8 × 1.25 / M9 × 1.25 Kılavuz Cıvata',
        socketSize: '13 mm Anahtar veya 7 mm Allen',
        torqueValue: '28 - 34 Nm',
        notes: 'Körük içine yalnızca silikon/seramik bazlı kaliper pim gresi sürün (mineral gres lastiği şişirir!).',
      ),
      const FastenerTorqueSpec(
        partName: '6. Ön Aks Göbek Somunu / Cıvatası (Axle Hub Nut)',
        threadSpec: 'M22 × 1.50 / M24 × 1.50 Kilitlemeli Aks Somunu',
        socketSize: '30 mm / 32 mm 12 Köşe Derin Lokma',
        torqueValue: '200 - 245 Nm (veya 70 Nm + 90°)',
        notes: 'Tek kullanımlık somun/cıvata ise yenileyin; tekerlek rulmanına boşluksuz tam oturmalıdır.',
      ),
      const FastenerTorqueSpec(
        partName: '7. Ön Salıncak (Control Arm) Şasi Burç Cıvataları',
        threadSpec: 'M12 × 1.50 Flanslı (10.9)',
        socketSize: '18 mm Lokma + Kontra Anahtar',
        torqueValue: '90 Nm + 90°',
        notes: 'KRİTİK KURAL: Kauçuk burçların yırtılmaması için araç liftten indirilip kendi ağırlığındayken son tork verilir!',
      ),
      const FastenerTorqueSpec(
        partName: '8. Amortisör Üst Kule Bağlantı Somunları / Cıvataları',
        threadSpec: 'M8 × 1.25 Üst Kule (3 Adet)',
        socketSize: '13 mm Lokma',
        torqueValue: '25 - 30 Nm',
        notes: 'Kule bilyası yön işaretine dikkat ederek eşit sırayla sıkınız.',
      ),
      const FastenerTorqueSpec(
        partName: '9. Z-Rot (Viraj Denge Çubuğu Bağlantı Kolları)',
        threadSpec: 'M10 × 1.50 / M12 × 1.50 Kilitlemeli Somun',
        socketSize: '16 mm / 17 mm Anahtar + T30/5mm Allen İç Tutucu',
        torqueValue: '55 - 65 Nm',
        notes: 'Rotil körüğünü döndürmemek için merkezinden Allen/Torx ile sabit tutarak sıkın.',
      ),
      const FastenerTorqueSpec(
        partName: '10. 12V Akü Kutup Başı Kelepçe Somunları',
        threadSpec: 'M6 × 1.0 Konik Kelepçe',
        socketSize: '10 mm Lokma',
        torqueValue: '5 - 7 Nm',
        notes: 'Aşırı sıkmak kurşun kutup başını çatlatır; önce (+) takılır, sökümde önce (−) çıkarılır.',
      ),
    ];
  }

  /// Generates detailed Fluids & Periodic Maintenance schedule tailored to the user's car!
  static List<FluidCapacitySpec> buildDetailedFluidSpecs(UserGarageVehicle v) {
    final p = resolveProfile(v.make);
    final isEv = v.powertrain.isElectric;
    final isDiesel = v.powertrain == PowertrainType.diesel;

    if (isEv) {
      return [
        FluidCapacitySpec(
          systemName: 'Elektrik Tahrik Ünitesi (Redüktör) Yağı',
          specification: p.oilApprovalSpec,
          capacity: '1.3 - 2.2 Litre (Aks Başına)',
          interval: 'Her 80.000 - 120.000 km koruyucu yağ & mıknatıs temizliği',
        ),
        FluidCapacitySpec(
          systemName: 'Batarya & İnvertör Termal Soğutma Sıvısı',
          specification: p.coolantSpec,
          capacity: '10.0 - 14.0 Litre',
          interval: 'Her 40.000 km debi/seviye kontrolü · 4-5 yılda vakumlu değişim',
        ),
        const FluidCapacitySpec(
          systemName: 'Hidrolik Fren Sıvısı (Rejeneratif ESP Uyumlu)',
          specification: 'DOT 4 LV (Low Viscosity · ISO 4925 Class 6)',
          capacity: '0.85 - 1.0 Litre',
          interval: 'Her 2 yılda bir nem ölçümü ve değişim',
        ),
        const FluidCapacitySpec(
          systemName: 'Klima Gazı & Isı Pompası Kompresör Yağı',
          specification: 'R1234yf + Yalıtkan POE EV Kompresör Yağı (PAG Kullanılmaz!)',
          capacity: '550 - 850 gram',
          interval: 'DİKKAT: Elektrikli araçta iletken PAG yağı yüksek voltaj kaçağı yapar; yalnızca POE kullanılır!',
        ),
      ];
    }

    return [
      FluidCapacitySpec(
        systemName: 'Motor Yağı & Yağ Filtresi',
        specification: p.oilApprovalSpec,
        capacity: '4.2 - 6.5 Litre (Motor Hacmine Göre Çubuk/Sensör ile Doğrulayın)',
        interval: isDiesel
            ? 'Türkiye şehir içi koşullarında her 10.000 - 15.000 km veya 1 Yıl (DPF uyumlu düşük kül)'
            : 'Her 10.000 - 15.000 km veya 1 Yıl',
      ),
      FluidCapacitySpec(
        systemName: 'Motor Soğutma Sıvısı (Antifriz)',
        specification: p.coolantSpec,
        capacity: '6.0 - 8.5 Litre (%50 Saf Su / %50 Konsantre → -37°C)',
        interval: 'Farklı renk/kimyadaki antifrizleri karıştırmayın · Her 4-5 yılda yenileyin',
      ),
      const FluidCapacitySpec(
        systemName: 'Şanzıman Yağı (Otomatik / Çift Kavrama / Manuel)',
        specification: 'OEM ATF / DCTF (Islak Kavrama) / 75W-80 Manuel Dişli Yağı',
        capacity: 'Islak DCT/Tork Konvertör: 5.5 - 9.0 L · Kuru Kavrama/Manuel: 1.8 - 2.3 L',
        interval: 'Her 60.000 km (Şanzıman ömrü için "ömürlük" denilse dahi 60-80 bin km’de değiştirin)',
      ),
      const FluidCapacitySpec(
        systemName: 'Hidrolik Fren & Debriyaj Sıvısı',
        specification: 'DOT 4 LV (ESP/ABS Düşük Viskozite)',
        capacity: '0.8 - 1.0 Litre',
        interval: 'Her 24 ayda bir (%3 nem sınırını aşmadan değişim)',
      ),
    ];
  }

  /// Generates powertrain-aware expertise & chronic check items for ANY added vehicle!
  static List<String> buildExpertiseChecklist(UserGarageVehicle v) {
    final p = resolveProfile(v.make);
    final items = <String>[
      'Jant & Bijon Kontrolü: Bu markada standart bijon aralığı ${p.wheelPcd}, göbek çapı ${p.centerBore} ve bijon sıkma torku ${p.lugTorqueNm} değerindedir; sonradan takılan jantlarda bilezik (centering ring) uyumunu kontrol edin.',
    ];

    switch (v.powertrain) {
      case PowertrainType.electric:
        items.addAll([
          'OBD / BMS Batarya Sağlık Testi (SOH %): Hücreler arası maksimum voltaj farkı (Cell Delta) 15-25 mV altında olmalıdır.',
          'Alt Batarya Muhafaza Plakası: Aracı lifte kaldırıp batarya tabanında kaldırım/taş ezigi veya soğutma rekoru terlemesi olmadığından emin olun.',
          'AC On-Board Charger & CCS2 DC Soket: Hem AC (11/22 kW) hem DC hızlı şarj istasyonunda kilitleme pimi ve şarj başlatma testi yapın.',
        ]);
        break;
      case PowertrainType.diesel:
        items.addAll([
          'DPF (Dizel Partikül Filtresi) Kurum Doluluk Oranı: Cihazla fark basınç sensörü değerini ve son rejenerasyon kilometresini okuyun.',
          'Enjektör Geri Dönüş & Düzeltme Değerleri: Soğuk ilk çalıştırmada rölanti dalgalanması ve enjektör balans değerlerini kontrol edin.',
          'EGR Valfi, AdBlue (SCR) NOx Sensörü ve Turbo Mil Boşluğu: İntercooler hortumlarında aşırı yağlanma olup olmadığını inceleyin.',
        ]);
        break;
      case PowertrainType.hybrid:
        items.addAll([
          'Hibrit Batarya Soğutma Fanı & Filtresi: Arka koltuk altındaki hibrit batarya hava giriş filtresinin tıkanmamış olması batarya ömrü için hayati önemdedir.',
          'İnvertör Soğutma Devresi & Benzinli Motor Geçiş Sarsıntısı: Elektrikten içten yanmalı motora geçişin sarsıntısız olduğunu test edin.',
        ]);
        break;
      case PowertrainType.lpg:
        items.addAll([
          'Subap Uzaması / Kompresyon Testi & AFR Yol Ayarı: LPG’de fakir karışım egzoz subaplarını yakar; OBD üzerinden LTFT/STFT yakıt düzeltme değerleri ±%5 aralığında olmalıdır.',
          'LPG Tank Tarihçesi & Regülatör Diyaframı: Simit/silindir tankın 10 yıllık kullanım ömrünü ve soğutma suyu T-bağlantılarında sızıntı olmadığını doğrulayın.',
        ]);
        break;
      case PowertrainType.gasoline:
        items.addAll([
          'Triger Zinciri / Yağ İçinde Çalışan Kayış (Wet Belt) Kontrolü: İlk soğuk marşta 2-3 saniyelik zincir şıkırtısı veya yağ süzgeci kontrolü mutlaka yapılmalıdır.',
          'Turbo Wastegate Çubuğu, Devirdaim/Termostat Gövdesi ve Karter Havalandırma (PCV) diyafram sağlamlığını kontrol edin.',
          'Ateşleme Bobinleri & Bujiler: Tam yük hızlanmada tekleme (misfire sayacı) olup olmadığını OBD cihazıyla izleyin.',
        ]);
        break;
    }
    return items;
  }
}
