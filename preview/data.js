window.OTONOM_DATA = {
  brands: {
    tesla: {
      id: 'tesla',
      name: 'Tesla',
      shortCode: 'TESLA',
      slogan: 'Autopilot & Supercharger Ekosistemi Aktif',
      iconKey: 'IconTesla',
      primary: '#E82127',
      secondary: '#FF5A5F',
      surface: '#090B10',
      card: '#121620',
      glow: 'rgba(232, 33, 39, 0.38)',
      svg: `<svg viewBox="0 0 64 64" fill="none">
        <path d="M13 18C24 12 40 12 51 18" stroke="#E82127" stroke-width="4.2" stroke-linecap="round"/>
        <path d="M16 25C26 21 38 21 48 25" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round"/>
        <path d="M32 23V51" stroke="#FFFFFF" stroke-width="4.4" stroke-linecap="round"/>
      </svg>`
    },
    bmw: {
      id: 'bmw',
      name: 'BMW M',
      shortCode: 'BMW M',
      slogan: 'M Motorsport Kokpit & Sürüş Dinamikleri Aktif',
      iconKey: 'IconBmw',
      primary: '#1C69D4',
      secondary: '#E41E26',
      surface: '#070C16',
      card: '#10192B',
      glow: 'rgba(28, 105, 212, 0.42)',
      svg: `<svg viewBox="0 0 64 64" fill="none">
        <circle cx="32" cy="32" r="21" stroke="#FFFFFF" stroke-width="3.6"/>
        <path d="M32 14A18 18 0 0 1 50 32H32V14Z" fill="#1C69D4"/>
        <path d="M32 50A18 18 0 0 1 14 32H32V50Z" fill="#1C69D4"/>
        <path d="M14 32A18 18 0 0 1 32 14V32H14Z" fill="#F8FAFC"/>
        <path d="M50 32A18 18 0 0 1 32 50V32H50Z" fill="#F8FAFC"/>
        <path d="M44 52L50 42H54L48 52H44Z" fill="#E41E26"/>
      </svg>`
    },
    togg: {
      id: 'togg',
      name: 'Togg',
      shortCode: 'TOGG',
      slogan: 'Trumore & Trugo Akıllı Cihaz Modu Aktif',
      iconKey: 'IconTogg',
      primary: '#00B2C9',
      secondary: '#38E2F7',
      surface: '#061015',
      card: '#0E1D25',
      glow: 'rgba(0, 178, 201, 0.40)',
      svg: `<svg viewBox="0 0 64 64" fill="none">
        <path d="M30 32L14 19L21 32L14 45L30 32Z" fill="#00B2C9"/>
        <path d="M34 32L50 19L43 32L50 45L34 32Z" fill="#FFFFFF"/>
      </svg>`
    },
    mercedes: {
      id: 'mercedes',
      name: 'Mercedes-AMG',
      shortCode: 'AMG',
      slogan: 'MBUX Hyperscreen & Petronas Performans Teması',
      iconKey: 'IconMercedes',
      primary: '#00A19B',
      secondary: '#CBD5E1',
      surface: '#080D10',
      card: '#121C21',
      glow: 'rgba(0, 161, 155, 0.40)',
      svg: `<svg viewBox="0 0 64 64" fill="none">
        <circle cx="32" cy="32" r="21" stroke="#E2E8F0" stroke-width="3.2"/>
        <path d="M32 12L35 30L49 42L32 35L15 42L29 30L32 12Z" fill="#00A19B" stroke="#FFFFFF" stroke-width="1.4" stroke-linejoin="round"/>
      </svg>`
    },
    porsche: {
      id: 'porsche',
      name: 'Porsche',
      shortCode: 'PORSCHE',
      slogan: 'Sport Chrono & 800V E-Performance Modu',
      iconKey: 'IconPorsche',
      primary: '#D5001C',
      secondary: '#D4AF37',
      surface: '#0B090A',
      card: '#181316',
      glow: 'rgba(213, 0, 28, 0.40)',
      svg: `<svg viewBox="0 0 64 64" fill="none">
        <path d="M18 14H46L44 36C43 45 32 52 32 52C32 52 21 45 20 36L18 14Z" fill="rgba(213,0,28,0.32)" stroke="#D4AF37" stroke-width="3.2"/>
        <path d="M32 14V51M19 26H45M20 36H44" stroke="#FFFFFF" stroke-width="2.2"/>
      </svg>`
    },
    audi: {
      id: 'audi',
      name: 'Audi Sport',
      shortCode: 'AUDI RS',
      slogan: 'Virtual Cockpit RS & quattro Telemetri Modu',
      iconKey: 'IconAudi',
      primary: '#F50537',
      secondary: '#94A3B8',
      surface: '#0A0A0E',
      card: '#151720',
      glow: 'rgba(245, 5, 55, 0.40)',
      svg: `<svg viewBox="0 0 64 64" fill="none">
        <circle cx="16" cy="32" r="7.5" stroke="#FFFFFF" stroke-width="3"/>
        <circle cx="26.5" cy="32" r="7.5" stroke="#FFFFFF" stroke-width="3"/>
        <circle cx="37.5" cy="32" r="7.5" stroke="#FFFFFF" stroke-width="3"/>
        <circle cx="48" cy="32" r="7.5" stroke="#F50537" stroke-width="3"/>
      </svg>`
    }
  },

  vehicles: [
    {
      id: 'tesla-model-y-perf',
      brandId: 'tesla',
      brandName: 'Tesla',
      modelName: 'Model Y Performance AWD',
      chassis: 'Giga Berlin · Dual Motor AWD',
      years: '2022 - Günümüz',
      isElectric: true,
      powertrainLabel: 'Tam Elektrikli (BEV)',
      carInfoUrl: 'https://www.car.info/en-se/tesla/model-y/model-y-performance-awd-23415618',
      hp: 534,
      nm: 660,
      zeroToHundred: '3.7 sn',
      topSpeed: '250 km/s',
      weightKg: 1995,
      rangeKm: 514,
      consumption: '17.3 kWh / 100 km (WLTP)',
      engineCode: 'Ön: 3D3 Asenkron İndüksiyon + Arka: 4D1 Hairpin PMSRM',
      displacementOrBattery: '78.8 kWh Brüt / 75.0 kWh Net LG M50L Li-Ion Paket',
      boreOrVoltage: '355V Nominal · 250 kW V3/V4 CCS2 DC Hızlı Şarj',
      compressionOrChem: 'NMC 811 Hücre Kimyası · Octovalve 8 Yollu Isı Pompası',
      firingOrInverter: 'Çift SiC (Silisyum Karbür) MOSFET İnvertör · 16.000 d/dk',
      transmission: 'Tek Oranlı Redüksiyon Dişli Kutusu (Ön & Arka)',
      gearRatios: [
        'Ön Aks Redüksiyon Oranı: 9.04 : 1',
        'Arka Aks Redüksiyon Oranı: 9.04 : 1',
        'Açık Diferansiyel + Elektronik Tork Vektörleme'
      ],
      drivetrain: 'Dual Motor Sürekli Dört Çeker (AWD)',
      frontSuspension: 'Çift Salıncaklı (Double Wishbone) Helezon Yay + İkiz Tüp Amortisör',
      rearSuspension: '5 Kollu Bağımsız Multi-Link Arka Aks (Alüminyum Taşıyıcı)',
      frontBrakes: '355 × 25 mm Hava Kanallı Disk · Brembo 4 Pistonlu Sabit Kaliper',
      rearBrakes: '335 × 20 mm Hava Kanallı Disk · Mando Entegre EPB Tek Piston Kaliper',
      pcd: '5 × 114.3 mm',
      centerBore: '64.1 mm (Ön 21×9.5J ET40 / Arka 21×10.5J ET48 Überturbine)',
      tires: 'Ön: 255/35 R21 98W XL · Arka: 275/35 R21 103W XL (2.9 Bar / 42 PSI)',
      bolts: [
        {
          part: 'Bijon Somunları (Wheel Lug Nuts)',
          thread: 'M14 × 1.50 Konik 60° Somun',
          socket: '21 mm Derin Lokma',
          torque: '175 Nm',
          note: 'Kuru sıkım; yağ/bakır gres kesinlikle sürülmez.'
        },
        {
          part: 'Ön Brembo Kaliper Bağlantı Cıvatası',
          thread: 'M14 × 2.0 × 45 mm (10.9 Kalite)',
          socket: '18 mm / E18 Lokma',
          torque: '125 Nm',
          note: 'Orta mukavemetli mavi Loctite 243 uygulayın.'
        },
        {
          part: 'Ön Üst Salıncak (FUCA) Şasi Cıvatası',
          thread: 'M12 × 1.75 Flanslı Cıvata',
          socket: '18 mm Lokma + 18 mm Anahtar',
          torque: '98 Nm',
          note: 'Araç sürüş yüksekliğindeyken (yük altında) sıkılmalıdır.'
        },
        {
          part: 'Aks Somunu (Halfshaft Hub Nut)',
          thread: 'M24 × 1.5 Kilitlemeli Somun',
          socket: '32 mm 12 Köşe Lokma',
          torque: '245 Nm',
          note: 'Söküldüğünde yeni somun takılması önerilir.'
        },
        {
          part: 'Redüktör Yağ Boşaltma/Doldurma Tapası',
          thread: 'M18 × 1.5 Manyetik Tapa',
          socket: '8 mm Allen (Hex)',
          torque: '30 Nm',
          note: 'O-ring contayı her değişimde yenileyin.'
        },
        {
          part: 'HV Batarya Taşıyıcı Şasi Cıvataları',
          thread: 'M12 × 1.75 Özel Kaplamalı',
          socket: 'E14 Harici Torx',
          torque: '105 Nm',
          note: 'Yüksek Voltaj First Responder kesilmeden dokunulmaz!'
        }
      ],
      fluids: [
        { name: 'Ön & Arka Redüktör Şanzıman Yağı', spec: 'Pentosin EDF2 / DEXRON VI LV', cap: 'Ön: 1.5 L · Arka: 2.1 L (Filtreli)', interval: 'Her 120.000 km koruyucu bakım' },
        { name: 'Batarya & Octovalve Soğutma Sıvısı', spec: 'Tesla G-48 Ethylene Glycol', cap: '11.8 Litre', interval: '4 yılda bir seviye/debi kontrolü' },
        { name: 'Hidrolik Fren Sıvısı', spec: 'DOT 4 LV (ESP Uyumlu)', cap: '0.85 Litre', interval: 'Her 24 ayda bir nem testi' }
      ],
      ecu: 'Tesla HW4 (AI4) Otonom Bilgisayar + AMD Ryzen MCU3 · 15.5V Li-Ion Yardımcı Akü',
      tips: [
        'Klasik sigorta kutusu yoktur; eFuse MOSFET elektronik sigortalar kısa devre kalkınca kendiliğinden resetlenir.',
        'Kriko ile kaldırırken mutlaka kauçuk Jack Pad kullanın; aksi halde batarya kenar sacı zarar görebilir.',
        'Rejeneratif frenleme nedeniyle disk yüzeylerinin paslanmaması için ayda 1 kez güvenli yolda mekanik frenleme yapın.'
      ]
    },
    {
      id: 'bmw-m4-competition-g82',
      brandId: 'bmw',
      brandName: 'BMW',
      modelName: 'M4 Competition M xDrive (G82)',
      chassis: 'G82 LCI · BMW M GmbH',
      years: '2021 - Günümüz',
      isElectric: false,
      powertrainLabel: 'Benzinli Twin-Turbo (ICE)',
      carInfoUrl: 'https://www.car.info/en-se/bmw/4-series/m4-coupe-g82-20463210',
      hp: 530,
      nm: 650,
      zeroToHundred: '3.5 sn',
      topSpeed: '290 km/s',
      weightKg: 1775,
      rangeKm: 580,
      consumption: '10.1 L / 100 km (59L Depo · 98 Oktan Önerilir)',
      engineCode: 'S58B30T0 · 3.0L Sıralı 6 Silindir Mono-Scroll Twin-Turbo',
      displacementOrBattery: '2.993 cc · Dövme Krank & Tel Ark Püskürtmeli Silindir Gömleği',
      boreOrVoltage: '84.0 mm Çap × 90.0 mm Strok · Çift VANOS & Valvetronic',
      compressionOrChem: '9.3 : 1 Sıkıştırma · 350 Bar Yüksek Basınçlı Direkt Enjeksiyon',
      firingOrInverter: 'Ateşleme Sırası: 1 - 5 - 3 - 6 - 2 - 4 · 2.1 Bar Maks. Turbo',
      transmission: '8 İleri M Steptronic (ZF 8HP76) Drivelogic',
      gearRatios: [
        '1. Vites: 5.000 : 1  |  2. Vites: 3.200 : 1',
        '3. Vites: 2.143 : 1  |  4. Vites: 1.720 : 1',
        '5. Vites: 1.313 : 1  |  6. Vites: 1.000 : 1',
        '7. Vites: 0.823 : 1  |  8. Vites: 0.640 : 1  |  Son Dişli: 3.154 : 1'
      ],
      drivetrain: 'M xDrive (4WD / 4WD Sport / Saf Arkadan İtiş 2WD + Aktif M Diferansiyel)',
      frontSuspension: 'Alüminyum Çift Eklemli Yaylı Kule + Adaptif M Elektronik Amortisör',
      rearSuspension: '5 Kollu Hafif Çelik/Alüminyum Arka Aks (Şasiye Rijit Bağlı Alt Beşik)',
      frontBrakes: '380 × 36 mm M Compound Delikli Disk · 6 Pistonlu Sabit Kaliper',
      rearBrakes: '370 × 24 mm M Compound Delikli Disk · Tek Pistonlu Yüzer Kaliper',
      pcd: '5 × 112 mm',
      centerBore: '66.6 mm (Ön 19×9.5J ET20 / Arka 20×10.5J ET20 826M Dövme)',
      tires: 'Ön: 275/35 ZR19 (2.3 Bar) · Arka: 285/30 ZR20 (2.5 Bar) Pilot Sport 4S ★',
      bolts: [
        {
          part: 'Bijon Cıvataları (Wheel Lug Bolts)',
          thread: 'M14 × 1.25 × 27 mm Konik 60° Cıvata',
          socket: '17 mm İnce Etli Koruyucu Lokma',
          torque: '140 Nm',
          note: 'BMW G-Serisi M14×1.25 diş kullanır; eski E-Serisi M12 ile karıştırmayın!'
        },
        {
          part: 'Motor Karter Yağ Boşaltma Tapası',
          thread: 'M12 × 1.5 × 16 mm Metal Tapa',
          socket: '17 mm Lokma',
          torque: '25 Nm',
          note: 'Her yağ değişiminde yeni bakır/alüminyum ezilme pulu takın.'
        },
        {
          part: 'Yağ Filtre Kapağı (Üstten Hazne)',
          thread: 'S58 Polimer Filtre Haznesi',
          socket: '32 mm Altıköşe Lokma',
          torque: '25 Nm',
          note: 'Yeni O-ring contayı temiz motor yağı ile ıslatarak monte edin.'
        },
        {
          part: 'Ateşleme Bujileri (NGK SILZKGR8E8S)',
          thread: 'M12 × 1.25 İnce Paso İridyum',
          socket: '14 mm İnce Etli 12 Köşe (Bi-Hex) Buji Lokması',
          torque: '23 ± 3 Nm',
          note: 'Soğuk motorda kuru sıkım; anti-seize pasta sürülmez.'
        },
        {
          part: 'Silindir Kapak Saplamaları (S58 Ana)',
          thread: 'M11 × 1.5 TTY (Uzamalı Cıvata)',
          socket: 'E14 Torx Lokma',
          torque: '30 Nm + 90° + 90° + 45°',
          note: 'Tek kullanımlık TTY cıvata; söküldüğünde takım halinde yenilenir.'
        },
        {
          part: 'Ön Kule Gergisi (M Strut Brace) Cıvataları',
          thread: 'M10 × 1.5 Gerilme Cıvatası',
          socket: 'E14 Harici Torx',
          torque: '56 Nm + 90°',
          note: 'Alüminyum cıvatalar söküm sonrası yenilenmelidir.'
        }
      ],
      fluids: [
        { name: 'Motor Yağı (S58 TwinPower Turbo)', spec: 'BMW Longlife-04 / SAE 0W-30', cap: '7.0 Litre (Filtre Dahil)', interval: '2.000 km Rodaj Zorunlu! Sonra her 8.000-10.000 km' },
        { name: 'Aktif M Arka Diferansiyel Yağı', spec: 'BMW Hypoid Axle Oil G4 (75W-85)', cap: '1.1 Litre', interval: '2.000 km rodajda + her 50.000 km' },
        { name: 'ZF 8HP76 Şanzıman Yağı', spec: 'ZF LifeguardFluid 8', cap: '9.2 Litre (Tam) / 5.5 L Karter', interval: 'Her 60.000 - 80.000 km' }
      ],
      ecu: 'Bosch DME MG1CS024 + 12V 70Ah LiFePO4 M Motorsport Hafif Akü',
      tips: [
        '2.000 km Rodaj Bakımı (Run-in Service) iDrive geçmişinde zamanında yapılmış mı ekspertizde ilk bakılacak maddedir.',
        'S55 motorlardaki krank göbeği (crank hub) sorunu S58 motorda tek parça dövme yapı ile tamamen giderilmiştir.',
        'Ön tampon altındaki yatay yağ soğutucu (oil cooler) yoldan taş gelmesine karşı metal koruma ızgarası ile korunmalıdır.'
      ]
    },
    {
      id: 'togg-t10x-v2',
      brandId: 'togg',
      brandName: 'Togg',
      modelName: 'T10X V2 RWD Uzun Menzil',
      chassis: 'Gemlik C-SUV Platformu',
      years: '2023 - Günümüz',
      isElectric: true,
      powertrainLabel: 'Tam Elektrikli (BEV)',
      carInfoUrl: 'https://www.car.info/en-se/togg/t10x',
      hp: 218,
      nm: 350,
      zeroToHundred: '7.8 sn',
      topSpeed: '185 km/s',
      weightKg: 2126,
      rangeKm: 523,
      consumption: '16.9 kWh / 100 km (WLTP)',
      engineCode: 'Bosch SMG180 Sabit Mıknatıslı Senkron Motor (Arka Aks)',
      displacementOrBattery: '88.5 kWh Siro (Farasis NMC) Sıvı Soğutmalı Batarya',
      boreOrVoltage: '400V Mimari · 180 kW DC CCS2 / 22 kW AC Şarj',
      compressionOrChem: 'Lityum-İyon NMC Hücre · %20-%80 Hızlı Şarj: 28 Dakika',
      firingOrInverter: 'Entegre Güç Elektroniği + 3 Kademeli Rejeneratif Frenleme',
      transmission: '1 İleri Sabit Oranlı Redüktör',
      gearRatios: [
        'Sabit Redüksiyon Oranı: 9.65 : 1',
        'Elektronik Çekiş & Tork Kontrolü'
      ],
      drivetrain: 'Arkadan İtiş (RWD)',
      frontSuspension: 'Bağımsız MacPherson Ön Süspansiyon + Viraj Denge Çubuğu',
      rearSuspension: 'Tam Bağımsız Çok Kollu (Integral Multi-Link) Arka Aks',
      frontBrakes: '330 × 28 mm Hava Kanallı Disk · Yüzer Kaliper',
      rearBrakes: '318 × 18 mm Disk · Elektronik Park Freni (EPB)',
      pcd: '5 × 112 mm',
      centerBore: '66.5 mm (19×8.0J ET45 Elmas Kesim Jant)',
      tires: '235/50 R19 103V XL (Ön & Arka Soğuk: 2.5 Bar / 36 PSI)',
      bolts: [
        {
          part: 'Bijon Cıvataları (Wheel Bolts)',
          thread: 'M14 × 1.50 Küresel/Konik Cıvata',
          socket: '17 mm Lokma',
          torque: '140 Nm',
          note: 'Yıldız sırasıyla iki kademede (70 Nm -> 140 Nm) sıkınız.'
        },
        {
          part: 'Ön Kaliper Kılavuz Pimleri',
          thread: 'M10 × 1.25 Kılavuz Cıvata',
          socket: '13 mm Anahtar + 15 mm Kontra',
          torque: '32 Nm',
          note: 'Silikon bazlı yüksek ısı kaliper gresi kullanın.'
        },
        {
          part: 'Alt Beşik (Subframe) Şasi Bağlantıları',
          thread: 'M14 × 1.5 Flanslı (10.9)',
          socket: '18 mm Lokma',
          torque: '135 Nm + 45°',
          note: 'Şasi hizalama pimleri kontrol edilerek sıkılmalıdır.'
        },
        {
          part: '12V AGM Akü Kutup Başı Somunu',
          thread: 'M6 Kelepçe Somunu',
          socket: '10 mm Anahtar',
          torque: '6 Nm',
          note: 'Araç tam uyku moduna geçmeden eksi kutup sökülmemelidir.'
        }
      ],
      fluids: [
        { name: 'Elektrik Motoru Redüktör Yağı', spec: 'Sentetik EV Dişli Yağı 75W FE', cap: '1.3 Litre', interval: 'Her 100.000 km kontrol / değişim' },
        { name: 'Batarya Termal Yönetim Sıvısı', spec: 'Düşük İletkenlikli OAT EV Coolant', cap: '10.5 Litre', interval: 'Her 40.000 km yetkili servis kontrolü' }
      ],
      ecu: 'Trumore 29" Uçtan Uca Dijital Kokpit + Snapdragon SoC · Trumore OS 1.5+ ADAS',
      tips: [
        'Trugo istasyonlarında Tak & Şarj (Plug & Charge) özelliği kablo takıldığı an ödeme ekranı olmadan başlar.',
        'Güncel Trumore 1.5+ OTA yazılımının yüklü olduğunu bilgi-eğlence sisteminden doğrulayın.'
      ]
    },
    {
      id: 'mercedes-c200-w206',
      brandId: 'mercedes',
      brandName: 'Mercedes-Benz',
      modelName: 'C 200 4MATIC AMG Line (W206)',
      chassis: 'W206 · 48V EQ Boost Mild-Hybrid',
      years: '2021 - Günümüz',
      isElectric: false,
      powertrainLabel: 'Benzinli + 48V Hibrit (ICE)',
      carInfoUrl: 'https://www.car.info/en-se/mercedes-benz/c-class/c-class-sedan-w206-20751243',
      hp: 204,
      nm: 300,
      zeroToHundred: '7.1 sn',
      topSpeed: '241 km/s',
      weightKg: 1710,
      rangeKm: 890,
      consumption: '6.6 L / 100 km (66L Yakıt Deposu + 20 HP EQ Boost)',
      engineCode: 'M254 E15 DEH LA · NANOSLIDE Silindir + ISG 48V',
      displacementOrBattery: '1.496 cc Twin-Scroll Turbo + 20 HP / 200 Nm Entegre Marş Jeneratörü',
      boreOrVoltage: '78.0 mm × 78.3 mm · CAMTRONIC Değişken Supap',
      compressionOrChem: '10.5 : 1 Sıkıştırma · 48V Li-Ion Hibrit Destek Bataryası',
      firingOrInverter: 'Ateşleme Sırası: 1 - 3 - 4 - 2',
      transmission: '9G-TRONIC (725.1) 9 İleri Otomatik',
      gearRatios: [
        '1: 5.354 | 2: 3.243 | 3: 2.252 | 4: 1.636 | 5: 1.211',
        '6: 1.000 | 7: 0.865 | 8: 0.717 | 9: 0.601'
      ],
      drivetrain: '4MATIC Sürekli Dört Çeker (%45 Ön / %55 Arka)',
      frontSuspension: '4 Kollu Alüminyum Ön Aks + Spor Alçaltılmış AMG Şasi',
      rearSuspension: '5 Kollu Multi-Link Arka Aks (Opsiyonel 2.5° Arka Aks Yönlendirme)',
      frontBrakes: '342 × 32 mm Delikli Disk · Mercedes-Benz 4 Pistonlu Kaliper',
      rearBrakes: '320 × 22 mm Disk · Tek Pistonlu EPB Kaliper',
      pcd: '5 × 112 mm',
      centerBore: '66.6 mm (Ön 19×7.5J ET40 / Arka 19×9.0J ET58.1 AMG)',
      tires: 'Ön: 225/40 R19 · Arka: 255/35 R19 MO (Ön 2.5 / Arka 2.7 Bar)',
      bolts: [
        {
          part: 'Bijon Cıvataları (Çiçek Başlı Mercedes)',
          thread: 'M14 × 1.50 × 27 mm R14 Küresel Yatak',
          socket: '17 mm Çiçek Başlı (Flower Head) Özel Mercedes Lokması',
          torque: '150 Nm',
          note: 'Standart 6 köşe lokma çiçek kapağı ezebilir; özel lokma kullanın!'
        },
        {
          part: 'M254 İndeksli Ateşleme Bujileri',
          thread: 'M12 × 1.25 Yıldızlı Orijinal Buji',
          socket: '14 mm Bi-Hex Buji Lokması',
          torque: '23 Nm (Kesin Tolerans!)',
          note: 'KRİTİK: Enjektöre göre buji tırnak yönü indekslidir; yan sanayi buji piston eritir!'
        },
        {
          part: 'Plastik Karter Yağ Tapası',
          thread: 'Çeyrek Tur Poliamid Tapa (A0029902017)',
          socket: 'Özel Tapa Yuvası',
          torque: 'Durma Noktası (~6 Nm)',
          note: 'Her yağ değişiminde plastik tapa yenisiyle değiştirilir.'
        },
        {
          part: 'Ön 4-Piston Kaliper Taşıyıcı Cıvatası',
          thread: 'M14 × 1.5 Mikro Kapsüllü',
          socket: '18 mm / E18 Lokma',
          torque: '115 Nm + 45°',
          note: 'Kendinden kilitli cıvata yenilenmelidir.'
        }
      ],
      fluids: [
        { name: 'Motor Yağı (M254 OPF Uyumlu)', spec: 'MB-Approval 229.71 / SAE 0W-20', cap: '6.0 Litre', interval: 'Her 15.000 km veya 1 Yıl' },
        { name: '9G-TRONIC Şanzıman Yağı', spec: 'MB 236.17 FE-ATF', cap: '10.0 Litre', interval: 'Her 125.000 km veya 5 Yıl' }
      ],
      ecu: 'MBUX NTG7 11.9" OLED + 12V 80Ah AGM & 48V Li-Ion EQ Boost',
      tips: [
        'Silecekleri Servis Moduna (dik konum) almadan kaputu tam açmayın; silecek kolu kaput boyasına sürter.',
        'Yalnızca Mercedes kutulu orijinal buji ve 23 Nm kalibreli tork anahtarı kullanılmalıdır.'
      ]
    },
    {
      id: 'porsche-taycan-turbo-s',
      brandId: 'porsche',
      brandName: 'Porsche',
      modelName: 'Taycan Turbo S (J1 II)',
      chassis: 'J1 Performance Plus · 800V Mimari',
      years: '2020 - Günümüz',
      isElectric: true,
      powertrainLabel: 'Tam Elektrikli (800V BEV)',
      carInfoUrl: 'https://www.car.info/en-se/porsche/taycan/taycan-turbo-s-18965412',
      hp: 952,
      nm: 1110,
      zeroToHundred: '2.4 sn',
      topSpeed: '260 km/s',
      weightKg: 2295,
      rangeKm: 630,
      consumption: '17.9 kWh / 100 km (320 kW 800V Şarj)',
      engineCode: 'Çift Hairpin PSM Senkron Motor (Ön + Arka Aks)',
      displacementOrBattery: '105.0 kWh Brüt / 97.0 kWh Net Performance Battery Plus',
      boreOrVoltage: '800V Mimari · %10-%80 Şarj Yalnızca 18 Dakika!',
      compressionOrChem: 'Yüksek Nikelli Hücre + Porsche Active Ride Isı Pompası',
      firingOrInverter: 'Ön 300A + Arka 600A SiC Pulse İnvertör',
      transmission: 'Ön: 1 İleri Gezegen · Arka: Porsche 2 İleri Otomatik Şanzıman',
      gearRatios: [
        'Ön Aks Sabit Oran: 8.05 : 1',
        'Arka 1. Vites (Launch Control Kalkış): 15.56 : 1',
        'Arka 2. Vites (Otoyol Verimlilik): 8.05 : 1'
      ],
      drivetrain: 'PTM Dört Çeker + PTV Plus Kilitli Diferansiyel',
      frontSuspension: 'Alüminyum Çift Salıncak + 3 Odacıklı Havalı PASM / Active Ride',
      rearSuspension: 'Multi-Link + Arka Aks Yönlendirme (RAS)',
      frontBrakes: '420 × 40 mm PCCB Karbon-Seramik Disk · 10 Pistonlu Akebono Kaliper',
      rearBrakes: '410 × 32 mm PCCB Karbon-Seramik Disk · 4 Pistonlu Kaliper',
      pcd: '5 × 130 mm',
      centerBore: '71.6 mm (21" Mission E Design Jant)',
      tires: 'Ön: 265/35 ZR21 (2.7 Bar) · Arka: 305/30 ZR21 NF0 (2.9 Bar)',
      bolts: [
        {
          part: 'Titanyum/Çelik Hareketli Pullu Bijon Cıvataları',
          thread: 'M14 × 1.50 R14 Küresel Başlı',
          socket: '19 mm Koruyucu Lokma',
          torque: '160 Nm',
          note: 'PCCB seramik diski kırmamak için sökümde 2 adet kılavuz pim (Wheel Hanger) zorunludur!'
        },
        {
          part: 'Ön 10-Pistonlu PCCB Kaliper Cıvatası',
          thread: 'M16 × 1.5 Yüksek Mukavemetli',
          socket: '12 mm Allen / Özel Lokma',
          torque: '180 Nm',
          note: 'Karbon seramik diske kesinlikle darbe aldırmayın.'
        },
        {
          part: 'Arka 2 İleri Şanzıman Yağ Tapası',
          thread: 'M22 × 1.5 Sızdırmaz Halkalı Tapa',
          socket: '10 mm Allen',
          torque: '35 Nm',
          note: '35-40°C yağ sıcaklığında seviye kontrolü yapılır.'
        }
      ],
      fluids: [
        { name: 'Arka 2 İleri Şanzıman Yağı', spec: 'Porsche Pentosin FFL-8', cap: '3.2 Litre', interval: 'Her 60.000 km / 4 Yıl' },
        { name: 'Yüksek Performans Fren Hidroliği', spec: 'Porsche DOT 4 LV Class 6', cap: '1.0 Litre', interval: 'Her 2 Yılda Bir Zorunlu' }
      ],
      ecu: 'Porsche PCM 6.0 + 800V BMS + 12V 40Ah LiFePO4 Hafif Akü',
      tips: [
        'Aracı lifte kaldırmadan önce PCM ekranından "Kriko Modu (Jack Mode)" mutlaka açılmalıdır!',
        '300 kW Trugo/Eşarj istasyonları navigasyonda seçildiğinde batarya ön ısıtma otomatik devreye girer.'
      ]
    },
    {
      id: 'audi-rs6-avant-c8',
      brandId: 'audi',
      brandName: 'Audi',
      modelName: 'RS 6 Avant Performance (C8)',
      chassis: 'C8 (4K) · Audi Sport GmbH',
      years: '2023 - Günümüz',
      isElectric: false,
      powertrainLabel: '4.0 V8 Twin-Turbo Benzin (ICE)',
      carInfoUrl: 'https://www.car.info/en-se/audi/rs-6/rs-6-avant-c8-24129843',
      hp: 630,
      nm: 850,
      zeroToHundred: '3.4 sn',
      topSpeed: '305 km/s',
      weightKg: 2090,
      rangeKm: 600,
      consumption: '12.2 L / 100 km (73L Depo · COD Silindir Kapama)',
      engineCode: 'DYGA / EA825 · 4.0L V8 Twin-Turbo (Hot-V 90°) + 48V MHEV',
      displacementOrBattery: '3.996 cc · V-İçi Yerleşimli İkiz BorgWarner Turbo',
      boreOrVoltage: '86.0 mm × 86.0 mm Tam Kare V8 Mimari',
      compressionOrChem: '9.7 : 1 Sıkıştırma · Plazma Kaplamalı Silindirler',
      firingOrInverter: 'Ateşleme Sırası: 1 - 3 - 7 - 2 - 6 - 5 - 4 - 8',
      transmission: '8 İleri tiptronic (ZF 8HP90A Yüksek Tork)',
      gearRatios: [
        '1: 4.714 | 2: 3.143 | 3: 2.106 | 4: 1.667',
        '5: 1.285 | 6: 1.000 | 7: 0.839 | 8: 0.667'
      ],
      drivetrain: 'Mekanik Torsen Merkez Diferansiyelli Gerçek quattro (%40/%60) + RS Spor Dif.',
      frontSuspension: '5 Kollu Alüminyum + DRC Çapraz Hidrolik RS Süspansiyon',
      rearSuspension: '5 Kollu Alüminyum + Dinamik Dört Tekerlekten Yönlendirme',
      frontBrakes: '440 × 40 mm RS Karbon-Seramik Disk · 10 Pistonlu Kaliper!',
      rearBrakes: '370 × 30 mm RS Karbon-Seramik Disk · EPB Kaliper',
      pcd: '5 × 112 mm',
      centerBore: '66.5 mm (22×10.5J ET19 Hafifletilmiş Freze Jant)',
      tires: '285/30 ZR22 (101Y) XL SportContact 7 AO (Ön 2.9 / Arka 2.7 Bar)',
      bolts: [
        {
          part: 'RS İki Parçalı Hareketli Küresel Bijon Cıvatası',
          thread: 'M14 × 1.50 × 28 mm R13 Küresel Pul',
          socket: '17 mm Lokma',
          torque: '160 Nm (RS6 C8 Özel Yüksek Tork!)',
          note: 'Standart A6 120 Nm iken RS6 C8 22" jantta fabrika torku 160 Nm’dir!'
        },
        {
          part: 'EA825 V8 Karter Yağ Tapası',
          thread: 'M14 × 1.5 Metal Tapa',
          socket: 'T45 Torx / 6 mm Allen',
          torque: '30 Nm',
          note: 'Yeni sızdırmazlık pulu ile sıkınız.'
        },
        {
          part: 'Hot-V Ateşleme Bujileri (8 Adet)',
          thread: 'M12 × 1.25 RS Yüksek Isı Buji',
          socket: '14 mm Mafsallı Buji Lokması',
          torque: '25 Nm',
          note: 'RS bakım takviminde her 30.000 km değişimi zorunludur.'
        },
        {
          part: 'Alt Beşik Gergi Çaprazı Cıvataları',
          thread: 'M12 × 1.5 TTY Cıvata',
          socket: 'M12 XZN (12 Köşe Triple-Square)',
          torque: '90 Nm + 90°',
          note: 'VAG şaside 12 köşe XZN kullanılır; Torx ile sıyırmayın!'
        }
      ],
      fluids: [
        { name: 'Motor Yağı (EA825 4.0 TFSI)', spec: 'VW 511 00 Onaylı · SAE 0W-40', cap: '9.5 Litre', interval: 'Her 10.000 - 15.000 km' },
        { name: 'Quattro Spor Arka Diferansiyel (Çift Hazne)', spec: 'G 055 190 A2 + ATF G 055 515 A2', cap: '0.95 L Hipoid + 0.85 L ATF', interval: 'Her 60.000 km (iki tapayı karıştırmayın!)' }
      ],
      ecu: 'Bosch MG1CS008 + MIB3 Virtual Cockpit RS + 48V MHEV',
      tips: [
        '48V Alternatör/Marş Jeneratörü (BSG 27BQ aksiyonu) servis geçmişinden sorgulanmalıdır.',
        'DRC çapraz hidrolik süspansiyon amortisörlerinde terleme/kaçak ekspertizde kontrol edilmelidir.'
      ]
    }
  ],

  routes: [
    {
      id: 'ist-ank',
      origin: 'İstanbul (Kadıköy)',
      destination: 'Ankara (Çankaya)',
      totalKm: 442,
      durationMin: 255,
      highway: 'O-4 Anadolu Otoyolu · Körfez - Sapanca - Bolu Dağı',
      stations: [
        { id: 'ev-1', type: 'ev', name: 'Trugo Kurtköy / Sabiha Gökçen Hub', brand: 'Trugo', km: 28.4, detour: 2, x: 24, y: 35, kw: 300, connector: 'CCS2 300 kW Ultra DC', free: 5, total: 6, priceKwh: 8.99, arrivalSoc: 78, tags: ['7/24 Lounge', 'Kahve', 'Wi-Fi'] },
        { id: 'ev-2', type: 'ev', name: 'ZES Sapanca Otoyol Tesisi', brand: 'ZES', km: 124.0, detour: 1, x: 44, y: 42, kw: 180, connector: 'CCS2 180 kW DC', free: 3, total: 4, priceKwh: 9.29, arrivalSoc: 52, tags: ['Restoran', 'Market', 'WC'] },
        { id: 'ev-3', type: 'ev', name: 'Tesla Supercharger Bolu Highway', brand: 'Tesla Supercharger', km: 248.5, detour: 2, x: 65, y: 49, kw: 250, connector: 'V3 CCS2 250 kW (Tüm EV)', free: 10, total: 12, priceKwh: 7.80, arrivalSoc: 21, tags: ['Highway AVM', 'Starbucks', '12 Kabin'] },
        { id: 'ev-4', type: 'ev', name: 'Eşarj Akıncı Gişeler Öncesi', brand: 'Eşarj', km: 392.0, detour: 1, x: 83, y: 63, kw: 240, connector: 'CCS2 240 kW DC', free: 4, total: 4, priceKwh: 9.40, arrivalSoc: 34, tags: ['Kafe', 'Hızlı Çıkış'] },

        { id: 'fuel-1', type: 'fuel', name: 'Shell Mehmetçik Vakfı Kurtköy', brand: 'Shell', km: 26.8, detour: 1, x: 23, y: 36, benzin: 43.84, motorin: 44.12, lpg: 25.49, tags: ['V-Power Racing', 'Deli2Go', 'Oto Yıkama'] },
        { id: 'fuel-2', type: 'fuel', name: 'Opet Sapanca Otoyol Tesisi', brand: 'Opet', km: 123.5, detour: 1, x: 45, y: 43, benzin: 44.05, motorin: 44.30, lpg: 25.60, tags: ['Ultra Force', 'Temiz WC', 'Ultramar'] },
        { id: 'fuel-3', type: 'fuel', name: 'Petrol Ofisi Bolu Dağı Highway', brand: 'Petrol Ofisi', km: 249.0, detour: 2, x: 66, y: 50, benzin: 44.38, motorin: 44.65, lpg: 25.85, tags: ['Maximus', 'AVM Restoranlar', 'Hava/Su'] },
        { id: 'fuel-4', type: 'fuel', name: 'BP Ultimate Susuz / Ankara Girişi', brand: 'BP', km: 418.0, detour: 1, x: 85, y: 66, benzin: 44.52, motorin: 44.79, lpg: null, tags: ['BP Ultimate', 'Wild Bean Cafe', '7/24'] }
      ]
    },
    {
      id: 'ist-izm',
      origin: 'İstanbul (Beşiktaş)',
      destination: 'İzmir (Alsancak)',
      totalKm: 479,
      durationMin: 270,
      highway: 'O-5 Osmangazi Köprüsü - Bursa - Susurluk - İzmir Otoyolu',
      stations: [
        { id: 'ev-iz-1', type: 'ev', name: 'Trugo Oksijen O37 Orhangazi', brand: 'Trugo', km: 84.0, detour: 1, x: 31, y: 41, kw: 300, connector: 'CCS2 300 kW Ultra DC', free: 6, total: 8, priceKwh: 8.99, arrivalSoc: 66, tags: ['Oksijen AVM', 'Kahve Dünyası'] },
        { id: 'ev-iz-2', type: 'ev', name: 'Tesla Supercharger Susurluk O204', brand: 'Tesla Supercharger', km: 236.0, detour: 1, x: 56, y: 53, kw: 250, connector: 'V3 CCS2 250 kW', free: 7, total: 8, priceKwh: 7.80, arrivalSoc: 26, tags: ['Susurluk Tost/Ayran', '7/24'] },
        { id: 'ev-iz-3', type: 'ev', name: 'ZES Akhisar Oksijen O316', brand: 'ZES', km: 368.0, detour: 1, x: 76, y: 63, kw: 180, connector: 'CCS2 180 kW DC', free: 4, total: 4, priceKwh: 9.29, arrivalSoc: 39, tags: ['Restoran', 'Market'] },

        { id: 'fuel-iz-1', type: 'fuel', name: 'Shell Oksijen O37 Orhangazi', brand: 'Shell', km: 84.2, detour: 1, x: 32, y: 42, benzin: 44.10, motorin: 44.35, lpg: 25.55, tags: ['V-Power', 'Oksijen Tesisi'] },
        { id: 'fuel-iz-2', type: 'fuel', name: 'Opet Susurluk Oksijen O204', brand: 'Opet', km: 236.5, detour: 1, x: 57, y: 54, benzin: 44.40, motorin: 44.62, lpg: 25.79, tags: ['Ultra Force', 'Temiz WC'] },
        { id: 'fuel-iz-3', type: 'fuel', name: 'Petrol Ofisi Bornova Gişeler', brand: 'Petrol Ofisi', km: 462.0, detour: 1, x: 84, y: 69, benzin: 44.28, motorin: 44.50, lpg: 25.40, tags: ['Maximus', 'Market'] }
      ]
    }
  ],

  towTrucks: [
    {
      id: 'tow-1',
      company: 'Otonom VIP Kurtarma & Kayar Kasa',
      driver: 'Murat Demir',
      plate: '34 OTN 724',
      phone: '+90 532 440 07 24',
      truckType: 'Sıfır Eğim Kayar Kasa Platform (Basık Spor & EV Uygun)',
      km: 0.9,
      eta: 4,
      rating: 4.96,
      jobs: 482,
      baseTry: 950,
      perKmTry: 35,
      lowClearance: true,
      district: 'Kadıköy / Kozyatağı D-100 Yan Yol',
      x: 42,
      y: 36
    },
    {
      id: 'tow-2',
      company: 'Marmara 7/24 Acil Oto Çekici',
      driver: 'Serkan Yılmaz',
      plate: '34 MRK 118',
      phone: '+90 533 810 01 18',
      truckType: 'Hidrolik Platform + Ahtapot Teker Aparatlı (4×4 Kilitli)',
      km: 2.1,
      eta: 8,
      rating: 4.88,
      jobs: 915,
      baseTry: 850,
      perKmTry: 30,
      lowClearance: false,
      district: 'Ataşehir / Batı Kavşağı',
      x: 68,
      y: 32
    },
    {
      id: 'tow-3',
      company: 'Avrasya Kapalı Kasa & Ağır Kurtarıcı',
      driver: 'Hakan Kaya',
      plate: '34 AVR 900',
      phone: '+90 542 900 09 00',
      truckType: 'Kapalı Kasa VIP Taşıyıcı + Vinçli Kurtarıcı',
      km: 3.6,
      eta: 12,
      rating: 4.94,
      jobs: 310,
      baseTry: 1450,
      perKmTry: 45,
      lowClearance: true,
      district: 'Üsküdar / Avrasya Tüneli Çıkışı',
      x: 28,
      y: 66
    },
    {
      id: 'tow-4',
      company: 'Boğaziçi Mobil EV Şarj & Çekici Ekibi',
      driver: 'Emre Aydın',
      plate: '34 BGZ 452',
      phone: '+90 530 452 34 34',
      truckType: 'Kayar Kasa + Mobil 22kW Acil Yol Yardım Şarj Ünitesi',
      km: 4.8,
      eta: 15,
      rating: 4.91,
      jobs: 204,
      baseTry: 1100,
      perKmTry: 38,
      lowClearance: true,
      district: 'Beşiktaş / Barbaros Bulvarı',
      x: 74,
      y: 68
    }
  ],

  rentals: [
    {
      id: 'rent-1',
      host: 'Kerem Arslan',
      rating: 4.97,
      trips: 64,
      title: '2024 Tesla Model Y Long Range AWD',
      brandId: 'tesla',
      isElectric: true,
      hourlyTry: 390,
      dailyTry: 2850,
      depositTry: 4000,
      kmLimit: 300,
      distanceText: '350 m · Moda / Kadıköy',
      soc: 88,
      keyless: true,
      x: 38,
      y: 44,
      tags: ['Dijital Anahtar', 'Autopilot', 'HGS Entegre', 'Tam Kasko']
    },
    {
      id: 'rent-2',
      host: 'Zeynep Soylu',
      rating: 4.93,
      trips: 41,
      title: '2024 Togg T10X V2 Uzun Menzil',
      brandId: 'togg',
      isElectric: true,
      hourlyTry: 310,
      dailyTry: 2200,
      depositTry: 3000,
      kmLimit: 300,
      distanceText: '750 m · Fenerbahçe / Bağdat Cad.',
      soc: 92,
      keyless: true,
      x: 56,
      y: 58,
      tags: ['Meridian Ses', 'Cam Tavan', 'Trugo Kart Dahil']
    },
    {
      id: 'rent-3',
      host: 'Canberk Özkan',
      rating: 4.99,
      trips: 28,
      title: '2023 BMW 320i M Sport (G20 LCI)',
      brandId: 'bmw',
      isElectric: false,
      hourlyTry: 420,
      dailyTry: 3150,
      depositTry: 5000,
      kmLimit: 250,
      distanceText: '1.2 km · Suadiye Sahil',
      soc: 100,
      keyless: false,
      x: 71,
      y: 36,
      tags: ['Kavisli M Kokpit', 'Harman Kardon', 'CarPlay']
    },
    {
      id: 'rent-4',
      host: 'Selim Karaca',
      rating: 4.95,
      trips: 19,
      title: '2023 Mercedes-Benz C 200 4MATIC AMG',
      brandId: 'mercedes',
      isElectric: false,
      hourlyTry: 460,
      dailyTry: 3450,
      depositTry: 5500,
      kmLimit: 250,
      distanceText: '1.8 km · Ataşehir Bulvarı',
      soc: 85,
      keyless: true,
      x: 24,
      y: 32,
      tags: ['Burmester 3D', '64 Renk Ambiyans', '4MATIC']
    },
    {
      id: 'rent-5',
      host: 'Deniz Aksoy',
      rating: 5.00,
      trips: 14,
      title: '2024 Porsche Taycan 4S Cross Turismo',
      brandId: 'porsche',
      isElectric: true,
      hourlyTry: 980,
      dailyTry: 7900,
      depositTry: 15000,
      kmLimit: 200,
      distanceText: '2.4 km · Zorlu / Beşiktaş',
      soc: 94,
      keyless: false,
      x: 26,
      y: 68,
      tags: ['Sport Chrono', 'Havalı Süspansiyon', 'VIP Teslim']
    }
  ]
};
