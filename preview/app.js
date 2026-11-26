(function () {
  const DATA = window.OTONOM_DATA;

  const state = {
    activeTab: 'nav', // nav | sos | wiki | rent | garage
    selectedVehicleId: DATA.vehicles[0].id, // Default: Tesla Model Y
    selectedRouteId: DATA.routes[0].id,
    routeProgress: 0.14,
    isDrivingSim: false,
    addedWaypoints: new Set(),
    flatbedOnly: false,
    wikiSearch: '',
    wikiSpecId: DATA.vehicles[0].id,
    wikiSubTab: 'bolts', // bolts | engine | chassis | fluids | tips
    vinInput: 'WBS33AZ090CP12345',
    vinDecoded: null,
    rentFilter: 'all',
    driverName: 'Cemil & Ağabeyi',
    plate: '34 OTN 001',
    bloodType: 'A Rh (+)',
    icePhone: '+90 532 100 00 00',
    socOrFuel: 84
  };

  let driveTimer = null;
  let callTimer = null;

  function getVehicle() {
    return DATA.vehicles.find((v) => v.id === state.selectedVehicleId) || DATA.vehicles[0];
  }

  function getBrand() {
    const v = getVehicle();
    return DATA.brands[v.brandId] || DATA.brands.tesla;
  }

  function getRoute() {
    return DATA.routes.find((r) => r.id === state.selectedRouteId) || DATA.routes[0];
  }

  function applyBrandTheme() {
    const brand = getBrand();
    const vehicle = getVehicle();
    const root = document.documentElement;
    root.style.setProperty('--brand-primary', brand.primary);
    root.style.setProperty('--brand-secondary', brand.secondary);
    root.style.setProperty('--brand-surface', brand.surface);
    root.style.setProperty('--brand-card', brand.card);
    root.style.setProperty('--brand-glow', brand.glow);

    document.getElementById('headerCrest').innerHTML = brand.svg;
    document.getElementById('headerBrandShort').textContent = brand.shortCode;
    document.getElementById('headerCarModel').textContent = `${vehicle.brandName} ${vehicle.modelName}`;

    const sideTitle = document.getElementById('sideBrandTitle');
    if (sideTitle) sideTitle.textContent = brand.name;
    const homeIcon = document.getElementById('homeIconPreview');
    if (homeIcon) homeIcon.innerHTML = brand.svg;
    const homeLabel = document.getElementById('homeIconLabel');
    if (homeLabel) homeLabel.textContent = `Otonom · ${brand.shortCode}`;

    // Dynamic SVG favicon in browser tab!
    const svgBlob = encodeURIComponent(
      `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect width="64" height="64" rx="16" fill="#0B0E16"/>${brand.svg.replace(/<svg[^>]*>|<\/svg>/g, '')}</svg>`
    );
    let link = document.querySelector("link[rel~='icon']");
    if (!link) {
      link = document.createElement('link');
      link.rel = 'icon';
      document.head.appendChild(link);
    }
    link.href = `data:image/svg+xml,${svgBlob}`;

    renderSideQuickBrands();
  }

  function renderSideQuickBrands() {
    const container = document.getElementById('sideQuickBrands');
    if (!container) return;
    const current = getVehicle();
    container.innerHTML = DATA.vehicles
      .map((v) => {
        const active = v.id === current.id ? 'active' : '';
        return `<button class="chip-btn ${active}" data-select-car="${v.id}">
          ${v.brandName} (${v.isElectric ? '⚡ EV' : '⛽ Benzin'})
        </button>`;
      })
      .join('');
  }

  function selectVehicle(vehicleId) {
    state.selectedVehicleId = vehicleId;
    state.wikiSpecId = vehicleId;
    state.addedWaypoints.clear();
    applyBrandTheme();
    renderActiveScreen();
  }

  function switchTab(tab) {
    state.activeTab = tab;
    document.querySelectorAll('.nav-item').forEach((btn) => {
      btn.classList.toggle('active', btn.dataset.tab === tab);
    });
    renderActiveScreen();
  }

  function getPointAlongRoute(t) {
    // Cubic Bezier matching SVG path M 40 72 C 135 86, 240 105, 345 168 (in 390x238 viewBox)
    const p0 = { x: 10, y: 30 };
    const p1 = { x: 35, y: 36 };
    const p2 = { x: 62, y: 45 };
    const p3 = { x: 88, y: 71 };
    const u = 1 - t;
    const x = u * u * u * p0.x + 3 * u * u * t * p1.x + 3 * u * t * t * p2.x + t * t * t * p3.x;
    const y = u * u * u * p0.y + 3 * u * u * t * p1.y + 3 * u * t * t * p2.y + t * t * t * p3.y;
    return { x, y };
  }

  function buildMapSvgBackground(mode, brandPrimary) {
    const carPos = getPointAlongRoute(state.routeProgress);
    let modeOverlay = '';
    if (mode === 'nav') {
      modeOverlay = `
        <path d="M 39 71 C 136 86, 242 107, 343 169" stroke="${brandPrimary}" stroke-opacity="0.28" stroke-width="13" stroke-linecap="round" fill="none"/>
        <path d="M 39 71 C 136 86, 242 107, 343 169" stroke="${brandPrimary}" stroke-width="4.2" stroke-linecap="round" fill="none"/>
        <circle cx="39" cy="71" r="5" fill="#FFF"/>
        <circle cx="343" cy="169" r="6" fill="${brandPrimary}" stroke="#FFF" stroke-width="2"/>
        <circle cx="${(carPos.x * 3.9).toFixed(1)}" cy="${(carPos.y * 2.38).toFixed(1)}" r="13" fill="${brandPrimary}" fill-opacity="0.35"/>
        <circle cx="${(carPos.x * 3.9).toFixed(1)}" cy="${(carPos.y * 2.38).toFixed(1)}" r="6.5" fill="#FFFFFF" stroke="${brandPrimary}" stroke-width="2.5"/>
      `;
    } else if (mode === 'tow') {
      modeOverlay = `
        <circle cx="195" cy="119" r="35" stroke="#F59E0B" stroke-opacity="0.28" fill="none" stroke-dasharray="4 4"/>
        <circle cx="195" cy="119" r="72" stroke="#F59E0B" stroke-opacity="0.22" fill="none"/>
        <circle cx="195" cy="119" r="105" stroke="#F59E0B" stroke-opacity="0.14" fill="none"/>
        <circle cx="195" cy="119" r="9" fill="${brandPrimary}" stroke="#FFF" stroke-width="2.5"/>
      `;
    } else if (mode === 'rent') {
      modeOverlay = `
        <circle cx="195" cy="119" r="55" stroke="${brandPrimary}" stroke-opacity="0.22" fill="none" stroke-dasharray="4 4"/>
        <circle cx="195" cy="119" r="7" fill="#38BDF8" stroke="#FFF" stroke-width="2"/>
      `;
    }

    return `<svg class="map-bg" viewBox="0 0 390 238" preserveAspectRatio="none">
      <defs>
        <pattern id="grid" width="34" height="34" patternUnits="userSpaceOnUse">
          <path d="M 34 0 L 0 0 0 34" fill="none" stroke="rgba(255,255,255,0.045)" stroke-width="1"/>
        </pattern>
      </defs>
      <rect width="390" height="238" fill="url(#grid)"/>
      <path d="M0 132 Q 95 112, 165 165 L 0 218 Z" fill="rgba(14, 42, 71, 0.62)"/>
      <path d="M0 48 Q 185 82, 390 38" stroke="rgba(255,255,255,0.08)" stroke-width="2" fill="none"/>
      <path d="M72 0 Q 198 128, 285 238" stroke="rgba(255,255,255,0.08)" stroke-width="2" fill="none"/>
      ${modeOverlay}
    </svg>`;
  }

  function renderNavTab() {
    const vehicle = getVehicle();
    const brand = getBrand();
    const route = getRoute();
    const isEv = vehicle.isElectric;
    const stations = route.stations.filter((s) => s.type === (isEv ? 'ev' : 'fuel'));
    const traveledKm = route.totalKm * state.routeProgress;
    const remainingKm = Math.max(0, route.totalKm - traveledKm);

    const vehicleChips = DATA.vehicles
      .map(
        (v) => `<button class="chip-btn ${v.id === vehicle.id ? 'active' : ''}" data-select-car="${v.id}">
          ${v.brandName} (${v.isElectric ? 'EV' : 'Benzin'})
        </button>`
      )
      .join('');

    const mapPins = stations
      .map((s) => {
        const added = state.addedWaypoints.has(s.id);
        const label = isEv
          ? `⚡ ${s.kw}kW · ${s.km.toFixed(0)}km`
          : `⛽ ₺${s.benzin.toFixed(1)} · ${s.km.toFixed(0)}km`;
        return `<button class="map-pin ${isEv ? 'ev' : 'fuel'} ${added ? 'added' : ''}"
          style="left:${s.x}%; top:${s.y}%;" data-station-modal="${s.id}">
          ${label}
        </button>`;
      })
      .join('');

    const stationCards = stations
      .map((s) => {
        const delta = s.km - traveledKm;
        const passed = delta < 0;
        const distBadge = passed
          ? `${Math.abs(delta).toFixed(1)} km geride`
          : `${delta.toFixed(1)} km ileride`;
        const added = state.addedWaypoints.has(s.id);

        return `<div class="cockpit-card" style="border-color:${added ? brand.primary : 'rgba(255,255,255,0.09)'}">
          <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:7px;">
            <span style="background:rgba(255,255,255,0.09); padding:3px 9px; border-radius:8px; font-size:11.5px; font-weight:800; color:${passed ? '#94A3B8' : '#FFF'}">
              ${distBadge} · +${s.detour} dk
            </span>
            ${
              isEv
                ? `<span style="color:#34D399; font-size:12px; font-weight:800;">${s.free}/${s.total} Soket Boş</span>`
                : `<span style="color:#FBBF24; font-size:12px; font-weight:800;">${s.brand}</span>`
            }
          </div>
          <div style="font-size:15px; font-weight:800; margin-bottom:4px;">${s.name}</div>
          <div style="font-size:12.5px; color:#CBD5E1; line-height:1.45;">
            ${
              isEv
                ? `⚡ <strong>${s.kw} kW DC</strong> (${s.connector}) · <strong>₺${s.priceKwh}/kWh</strong> · Tahmini Varış Şarjı: <strong>%${s.arrivalSoc}</strong>`
                : `⛽ Kurşunsuz 95: <strong>₺${s.benzin}/L</strong> · Motorin: <strong>₺${s.motorin}/L</strong>${s.lpg ? ` · LPG: ₺${s.lpg}/L` : ''}`
            }
          </div>
          <div style="display:flex; justify-content:space-between; align-items:center; margin-top:10px; gap:8px;">
            <span style="font-size:11px; color:var(--text-muted);">${s.tags.join(' · ')}</span>
            <button class="outline-btn ${added ? 'added' : ''}" data-toggle-waypoint="${s.id}">
              ${added ? '✓ Durak Eklendi' : '+ Durak Ekle'}
            </button>
          </div>
        </div>`;
      })
      .join('');

    return `
      <div class="cockpit-card hero-glow">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <span class="badge-mode">${isEv ? '⚡ ELEKTRİKLİ ROTA MODU' : '⛽ AKARYAKIT ROTA MODU'}</span>
          <span style="font-size:12.5px; font-weight:800;">${isEv ? 'Batarya' : 'Depo'}: %${state.socOrFuel}</span>
        </div>
        <div style="font-size:18px; font-weight:900; margin-top:9px;">${vehicle.brandName} ${vehicle.modelName}</div>
        <div style="font-size:12px; color:#CBD5E1; margin-top:2px;">${brand.slogan}</div>
        <div class="horizontal-chips">${vehicleChips}</div>
      </div>

      <div class="emergency-grid">
        <button class="quick-action-box quick-tow" id="quickTowBtn">
          <span style="font-size:24px;">🛻</span>
          <div>
            <div style="font-size:12.5px; font-weight:900;">En Yakın Çekici</div>
            <div style="font-size:11px; color:#FDE68A;">0.9 km · 4 dk uzaklıkta</div>
          </div>
        </button>
        <button class="quick-action-box quick-sos" id="quickSosBtn">
          <span style="font-size:24px;">🆘</span>
          <div>
            <div style="font-size:12.5px; font-weight:900;">ACİL KAZA · 112</div>
            <div style="font-size:11px; color:#FECACA;">Tek Tuş Sesli Arama</div>
          </div>
        </button>
      </div>

      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; gap:8px;">
        <span style="font-size:13px; font-weight:800;">🧭 Aktif Güzergâh:</span>
        <select class="dark-select" id="routeSelector" style="width:auto; padding:6px 10px; font-weight:700;">
          ${DATA.routes
            .map(
              (r) => `<option value="${r.id}" ${r.id === route.id ? 'selected' : ''}>
                ${r.origin} → ${r.destination} (${r.totalKm} km)
              </option>`
            )
            .join('')}
        </select>
      </div>

      <div class="map-stage">
        ${buildMapSvgBackground('nav', brand.primary)}
        <div style="position:absolute; left:7%; top:18%; background:rgba(0,0,0,0.75); padding:3px 8px; border-radius:7px; font-size:10px; font-weight:700;">${route.origin.split(' ')[0]}</div>
        <div style="position:absolute; right:6%; bottom:12%; background:rgba(0,0,0,0.8); border:1px solid ${brand.primary}; padding:3px 8px; border-radius:7px; font-size:10px; font-weight:700;">${route.destination.split(' ')[0]}</div>
        ${mapPins}
      </div>

      <div class="cockpit-card">
        <div style="display:flex; justify-content:space-between; align-items:center; gap:10px;">
          <div>
            <div style="font-size:14px; font-weight:800;">${route.origin} → ${route.destination}</div>
            <div style="font-size:11.5px; color:var(--text-muted); margin-top:2px;">
              Kalan Mesafe: <strong style="color:#FFF">${remainingKm.toFixed(1)} km</strong> · ${route.highway}
            </div>
          </div>
          <button class="primary-btn" id="toggleDriveBtn">
            ${state.isDrivingSim ? '⏸ Duraklat' : '▶ Yolculuğu Başlat'}
          </button>
        </div>
        <div style="display:flex; align-items:center; gap:10px; margin-top:10px;">
          <span style="font-size:11.5px; color:var(--text-muted);">Konum:</span>
          <input type="range" id="routeSlider" min="0" max="100" value="${Math.round(state.routeProgress * 100)}" style="flex:1; accent-color:${brand.primary};" />
          <span style="font-size:12px; font-weight:800; width:54px; text-align:right;">${traveledKm.toFixed(0)} km</span>
        </div>
      </div>

      <div style="margin:14px 0 8px;">
        <div style="font-size:15.5px; font-weight:900;">
          ${isEv ? `⚡ Yol Üstü Şarj İstasyonları (${vehicle.brandName} EV)` : `⛽ Yol Üstü Akaryakıt İstasyonları (${vehicle.brandName} Benzin)`}
        </div>
        <div style="font-size:12px; color:var(--text-muted); margin-top:2px;">
          ${
            isEv
              ? 'Aracınız elektrikli olduğu için yalnızca rotanızdaki yüksek hızlı DC şarj istasyonları ve kaç km uzakta oldukları gösteriliyor.'
              : 'Aracınız benzinli olduğu için rotanızdaki akaryakıt istasyonları, kaç km kaldığı ve güncel litre fiyatları gösteriliyor.'
          }
        </div>
      </div>

      ${stationCards}
    `;
  }

  function renderSosTab() {
    const brand = getBrand();
    const trucks = DATA.towTrucks.filter((t) => !state.flatbedOnly || t.lowClearance);

    const pins = trucks
      .map(
        (t) => `<button class="map-pin tow" style="left:${t.x}%; top:${t.y}%;" data-call-tow="${t.id}">
          🛻 ${t.eta} dk · ${t.km} km
        </button>`
      )
      .join('');

    return `
      <div class="cockpit-card" style="background:linear-gradient(135deg,#7F1D1D,#28090D); border-color:#EF4444;">
        <div style="display:flex; align-items:center; gap:10px;">
          <span style="font-size:28px;">🚨</span>
          <div>
            <div style="font-size:16px; font-weight:900;">KAZA & 112 ACİL ÇAĞRI BUTONU</div>
            <div style="font-size:12px; color:#FECACA; margin-top:2px;">
              Kaza anında tek tuşla 112’yi arar; GPS koordinatınızı, kan grubunuzu ve araç yüksek voltaj/yakıt bilginizi ekrana yansıtır.
            </div>
          </div>
        </div>
        <button class="primary-btn" id="main112CallBtn" style="width:100%; margin-top:13px; background:#EF4444; padding:14px; font-size:14px;">
          📞 HEMEN 112 ACİL’İ ARA & KONUM KARTINI AÇ
        </button>
      </div>

      <div style="display:flex; justify-content:space-between; align-items:center; margin:14px 0 9px;">
        <div style="font-size:16px; font-weight:900;">🛻 En Yakın Çekiciler</div>
        <button class="chip-btn ${state.flatbedOnly ? 'active' : ''}" id="toggleFlatbedBtn">
          Basık / Spor Kayar Kasa
        </button>
      </div>

      <div class="map-stage">
        ${buildMapSvgBackground('tow', brand.primary)}
        ${pins}
      </div>

      ${trucks
        .map(
          (t) => `<div class="cockpit-card">
            <div style="display:flex; justify-content:space-between; align-items:center;">
              <span style="background:rgba(245,158,11,0.2); color:#FDE68A; padding:3px 9px; border-radius:8px; font-size:11.5px; font-weight:800;">
                ${t.km} km uzakta · ${t.eta} dk içinde varış
              </span>
              <span style="font-size:12.5px; font-weight:800;">★ ${t.rating} (${t.jobs})</span>
            </div>
            <div style="font-size:15.5px; font-weight:900; margin-top:8px;">${t.company}</div>
            <div style="font-size:12.5px; color:#CBD5E1; margin-top:3px;">
              Operatör: <strong>${t.driver}</strong> · Plaka: <strong>${t.plate}</strong> · ${t.district}
            </div>
            <div style="font-size:12px; color:#93C5FD; margin-top:4px;">${t.truckType}</div>
            <div style="display:flex; justify-content:space-between; align-items:center; margin-top:12px;">
              <div>
                <div style="font-size:13.5px; font-weight:900;">Açılış: ₺${t.baseTry} + ₺${t.perKmTry}/km</div>
                <div style="font-size:11.5px; color:var(--text-muted);">${t.phone}</div>
              </div>
              <button class="primary-btn" data-call-tow="${t.id}">📞 Çekiciyi Ara</button>
            </div>
          </div>`
        )
        .join('')}
    `;
  }

  function renderWikiTab() {
    const q = state.wikiSearch.trim().toLowerCase();
    const filtered = DATA.vehicles.filter((v) => {
      if (!q) return true;
      return (
        v.brandName.toLowerCase().includes(q) ||
        v.modelName.toLowerCase().includes(q) ||
        v.chassis.toLowerCase().includes(q) ||
        v.engineCode.toLowerCase().includes(q) ||
        v.pcd.toLowerCase().includes(q) ||
        v.bolts.some(
          (b) =>
            b.part.toLowerCase().includes(q) ||
            b.thread.toLowerCase().includes(q) ||
            b.socket.toLowerCase().includes(q)
        )
      );
    });

    const spec =
      filtered.find((v) => v.id === state.wikiSpecId) ||
      filtered[0] ||
      DATA.vehicles[0];

    let detailBody = '';
    if (state.wikiSubTab === 'bolts') {
      detailBody = spec.bolts
        .map(
          (b) => `<div class="bolt-item">
            <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:8px;">
              <strong style="font-size:13.5px;">🔩 ${b.part}</strong>
              <span class="torque-pill">${b.torque}</span>
            </div>
            <div style="font-size:12px; color:#93C5FD; margin-top:5px;">
              Diş Ölçüsü: <strong>${b.thread}</strong> · Lokma/Anahtar: <strong>${b.socket}</strong>
            </div>
            <div style="font-size:11.5px; color:#CBD5E1; margin-top:4px;">Not: ${b.note}</div>
          </div>`
        )
        .join('');
    } else if (state.wikiSubTab === 'engine') {
      detailBody = `
        <div class="spec-kv"><span>Motor / Ünite Kodu</span><span>${spec.engineCode}</span></div>
        <div class="spec-kv"><span>Hacim / Batarya</span><span>${spec.displacementOrBattery}</span></div>
        <div class="spec-kv"><span>Çap×Strok / Mimari</span><span>${spec.boreOrVoltage}</span></div>
        <div class="spec-kv"><span>Sıkıştırma / Kimya</span><span>${spec.compressionOrChem}</span></div>
        <div class="spec-kv"><span>Ateşleme / İnvertör</span><span>${spec.firingOrInverter}</span></div>
        <div class="spec-kv"><span>Şanzıman</span><span>${spec.transmission}</span></div>
        <div class="spec-kv"><span>Çekiş Mimarisi</span><span>${spec.drivetrain}</span></div>
        <div style="margin-top:10px; font-size:12.5px; font-weight:800;">Vites Dişli Oranları:</div>
        ${spec.gearRatios.map((g) => `<div style="font-size:12px; color:#CBD5E1; margin-top:4px;">• ${g}</div>`).join('')}
      `;
    } else if (state.wikiSubTab === 'chassis') {
      detailBody = `
        <div class="spec-kv"><span>Ön Süspansiyon</span><span>${spec.frontSuspension}</span></div>
        <div class="spec-kv"><span>Arka Süspansiyon</span><span>${spec.rearSuspension}</span></div>
        <div class="spec-kv"><span>Ön Fren Disk/Kaliper</span><span>${spec.frontBrakes}</span></div>
        <div class="spec-kv"><span>Arka Fren Disk/Kaliper</span><span>${spec.rearBrakes}</span></div>
        <div class="spec-kv"><span>Bijon Aralığı (PCD)</span><span>${spec.pcd}</span></div>
        <div class="spec-kv"><span>Göbek Çapı (CB) & ET</span><span>${spec.centerBore}</span></div>
        <div class="spec-kv"><span>Lastik & Basınç</span><span>${spec.tires}</span></div>
      `;
    } else if (state.wikiSubTab === 'fluids') {
      detailBody = spec.fluids
        .map(
          (f) => `<div class="bolt-item">
            <div style="font-weight:800; font-size:13px;">🛢️ ${f.name} — ${f.cap}</div>
            <div style="font-size:12px; color:#6EE7B7; margin-top:3px;">Fabrika Onayı: ${f.spec}</div>
            <div style="font-size:11.5px; color:#CBD5E1; margin-top:2px;">Değişim Periyodu: ${f.interval}</div>
          </div>`
        )
        .join('');
    } else {
      detailBody = `
        <div class="spec-kv"><span>ECU / Beyin & Akü</span><span>${spec.ecu}</span></div>
        <div style="margin-top:10px; font-size:12.5px; font-weight:800; color:#FDE68A;">Kronik Noktalar & Ekspertiz Kontrol Listesi:</div>
        ${spec.tips.map((t) => `<div style="font-size:12px; color:#E2E8F0; margin-top:6px; line-height:1.45;">⚠️ ${t}</div>`).join('')}
      `;
    }

    return `
      <div class="cockpit-card">
        <div style="font-size:16px; font-weight:900;">🔩 Araç Ansiklopedisi (En Küçük Cıvatasına Kadar)</div>
        <div style="font-size:11.5px; color:var(--text-muted); margin-top:3px;">
          Car.info veri mimarisi + OEM atölye tork kılavuzları ve canlı 17 haneli Şasi (VIN) çözümleyici.
        </div>
        <input class="dark-input" id="wikiSearchInput" value="${state.wikiSearch}" placeholder="Model, motor kodu (S58, M254) veya cıvata (M14, 17mm) ara..." style="margin-top:10px;" />

        <div style="display:flex; gap:7px; margin-top:9px;">
          <input class="dark-input" id="vinInputBox" value="${state.vinInput}" placeholder="17 Haneli VIN (Örn: WBS33AZ090CP12345)" />
          <button class="primary-btn" id="decodeVinBtn" style="white-space:nowrap;">VIN Çöz</button>
        </div>

        ${
          state.vinDecoded
            ? `<div style="margin-top:10px; padding:10px 12px; border-radius:12px; background:rgba(255,255,255,0.06); border:1px solid var(--brand-primary); font-size:12px;">
                <div style="font-weight:800;">✓ Şasi: ${state.vinDecoded.make} — ${state.vinDecoded.model}</div>
                <div style="color:#CBD5E1; margin-top:2px;">Motor: ${state.vinDecoded.engine} · Fabrika: ${state.vinDecoded.plant}</div>
                <a href="${state.vinDecoded.carInfoUrl}" target="_blank" rel="noopener" style="color:var(--brand-secondary); font-weight:800; display:inline-block; margin-top:5px;">↗ Car.info Katalog Sayfasını Aç</a>
              </div>`
            : ''
        }
      </div>

      <div class="horizontal-chips" style="margin:0 0 12px;">
        ${filtered
          .map(
            (v) => `<button class="chip-btn ${v.id === spec.id ? 'active' : ''}" data-wiki-car="${v.id}">
              ${v.brandName} ${v.modelName}
            </button>`
          )
          .join('')}
      </div>

      <div class="cockpit-card">
        <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:8px;">
          <div>
            <div style="font-size:18px; font-weight:900;">${spec.brandName} ${spec.modelName}</div>
            <div style="font-size:12px; color:var(--text-muted);">${spec.chassis} · ${spec.years}</div>
          </div>
          <a href="${spec.carInfoUrl}" target="_blank" rel="noopener" class="outline-btn" style="text-decoration:none;">Car.info ↗</a>
        </div>

        <div class="metrics-grid">
          <div class="metric-tile"><span>Güç</span><strong>${spec.hp} HP</strong></div>
          <div class="metric-tile"><span>Tork</span><strong>${spec.nm} Nm</strong></div>
          <div class="metric-tile"><span>0-100 km/s</span><strong>${spec.zeroToHundred}</strong></div>
          <div class="metric-tile"><span>Maks. Hız</span><strong>${spec.topSpeed}</strong></div>
          <div class="metric-tile"><span>Ağırlık</span><strong>${spec.weightKg} kg</strong></div>
          <div class="metric-tile"><span>Menzil</span><strong>${spec.rangeKm} km</strong></div>
        </div>

        <button class="outline-btn" data-select-car="${spec.id}" style="width:100%; margin-bottom:12px;">
          🏎️ Bu Aracı Profilime Seç & Uygulama Temasını Dönüştür
        </button>

        <div class="horizontal-chips" style="margin-bottom:12px;">
          <button class="chip-btn ${state.wikiSubTab === 'bolts' ? 'active' : ''}" data-wiki-sub="bolts">🔩 Cıvata & Tork (Nm)</button>
          <button class="chip-btn ${state.wikiSubTab === 'engine' ? 'active' : ''}" data-wiki-sub="engine">⚙️ Motor & Şanzıman</button>
          <button class="chip-btn ${state.wikiSubTab === 'chassis' ? 'active' : ''}" data-wiki-sub="chassis">🛞 Şasi & Fren</button>
          <button class="chip-btn ${state.wikiSubTab === 'fluids' ? 'active' : ''}" data-wiki-sub="fluids">🛢️ Sıvılar</button>
          <button class="chip-btn ${state.wikiSubTab === 'tips' ? 'active' : ''}" data-wiki-sub="tips">⚠️ Kronik & ECU</button>
        </div>

        ${detailBody}
      </div>
    `;
  }

  function renderRentTab() {
    const brand = getBrand();
    const list = DATA.rentals.filter((r) => {
      if (state.rentFilter === 'ev') return r.isElectric;
      if (state.rentFilter === 'keyless') return r.keyless;
      return true;
    });

    const pins = list
      .map(
        (r) => `<button class="map-pin rental" style="left:${r.x}%; top:${r.y}%;" data-book-rental="${r.id}">
          ₺${r.dailyTry}/gün
        </button>`
      )
      .join('');

    return `
      <div style="font-size:17px; font-weight:900;">🔑 Yakındaki Araç Kiralayanlar</div>
      <div style="font-size:12px; color:var(--text-muted); margin-top:2px;">
        Haritadan size en yakın araç sahiplerini ve günlük/saatlik fiyatları görün, anında kiralayın.
      </div>

      <div class="horizontal-chips" style="margin-bottom:11px;">
        <button class="chip-btn ${state.rentFilter === 'all' ? 'active' : ''}" data-rent-filter="all">Tümü (${DATA.rentals.length})</button>
        <button class="chip-btn ${state.rentFilter === 'ev' ? 'active' : ''}" data-rent-filter="ev">⚡ Elektrikli</button>
        <button class="chip-btn ${state.rentFilter === 'keyless' ? 'active' : ''}" data-rent-filter="keyless">📱 Dijital Anahtarsız</button>
      </div>

      <div class="map-stage">
        ${buildMapSvgBackground('rent', brand.primary)}
        ${pins}
      </div>

      ${list
        .map(
          (r) => `<div class="cockpit-card">
            <div style="display:flex; justify-content:space-between; align-items:center;">
              <span style="font-size:11.5px; font-weight:800; color:var(--brand-secondary);">📍 ${r.distanceText}</span>
              ${r.keyless ? `<span style="font-size:11px; font-weight:800; color:#34D399;">📱 Dijital Anahtar</span>` : ''}
            </div>
            <div style="font-size:16px; font-weight:900; margin-top:6px;">${r.title}</div>
            <div style="font-size:12px; color:#CBD5E1; margin-top:3px;">
              Kiralayan: <strong>${r.host} ✓</strong> · ★ ${r.rating} (${r.trips} kiralama) · Doluluk: %${r.soc}
            </div>
            <div style="display:flex; flex-wrap:wrap; gap:6px; margin-top:8px;">
              ${r.tags.map((t) => `<span style="font-size:10.5px; background:rgba(0,0,0,0.35); padding:3px 8px; border-radius:6px;">${t}</span>`).join('')}
            </div>
            <div style="display:flex; justify-content:space-between; align-items:center; margin-top:12px;">
              <div>
                <div style="font-size:15px; font-weight:900;">₺${r.dailyTry}/gün · ₺${r.hourlyTry}/saat</div>
                <div style="font-size:11px; color:var(--text-muted);">Depozito: ₺${r.depositTry} · ${r.kmLimit} km/gün</div>
              </div>
              <button class="primary-btn" data-book-rental="${r.id}">Hemen Kirala</button>
            </div>
          </div>`
        )
        .join('')}
    `;
  }

  function renderGarageTab() {
    const active = getVehicle();
    const brand = getBrand();

    return `
      <div class="cockpit-card hero-glow">
        <div style="display:flex; align-items:center; gap:14px;">
          <div class="app-launcher-tile" style="width:62px; height:62px; flex-shrink:0;">
            ${brand.svg}
          </div>
          <div>
            <div style="font-size:11.5px; font-weight:800; color:var(--brand-secondary);">AKTİF GARAJ ARACIM</div>
            <div style="font-size:18px; font-weight:900;">${active.brandName} ${active.modelName}</div>
            <div style="font-size:12px; color:#CBD5E1; margin-top:2px;">Plaka: ${state.plate} · ${active.powertrainLabel}</div>
          </div>
        </div>
        <div style="margin-top:12px; padding:10px 12px; border-radius:12px; background:rgba(0,0,0,0.35); font-size:11.5px; color:#E2E8F0;">
          📱 <strong>Dinamik Logo & Tema Aktif:</strong> Uygulama ikonu <code>${brand.iconKey}</code> ve arayüz renkleri <strong>${brand.name}</strong> kimliğine dönüştürüldü.
        </div>
      </div>

      <div style="font-size:16px; font-weight:900; margin:12px 0 8px;">🏎️ Garajdan Aracınızı Seçin</div>
      ${DATA.vehicles
        .map((v) => {
          const b = DATA.brands[v.brandId];
          const isSel = v.id === active.id;
          return `<div class="cockpit-card" data-select-car="${v.id}" style="cursor:pointer; display:flex; align-items:center; gap:12px; border-color:${isSel ? b.primary : 'rgba(255,255,255,0.09)'}; background:${isSel ? 'rgba(255,255,255,0.07)' : 'var(--brand-card)'}">
            <div style="width:44px; height:44px; border-radius:12px; padding:6px; background:#0B0E16; border:1.5px solid ${b.primary}; flex-shrink:0;">
              ${b.svg}
            </div>
            <div style="flex:1;">
              <div style="font-size:14.5px; font-weight:800;">${v.brandName} ${v.modelName}</div>
              <div style="font-size:11.5px; color:var(--text-muted);">${v.powertrainLabel} · ${v.hp} HP · ${v.chassis}</div>
            </div>
            <span style="font-size:18px;">${isSel ? '✅' : '⚪'}</span>
          </div>`;
        })
        .join('')}

      <div class="cockpit-card" style="margin-top:14px;">
        <div style="font-size:15px; font-weight:900; margin-bottom:10px;">🩸 112 Acil Kaza & Sürücü Künyesi</div>
        <div style="display:grid; gap:9px;">
          <input class="dark-input" id="profName" value="${state.driverName}" placeholder="Sürücü Ad Soyad" />
          <input class="dark-input" id="profPlate" value="${state.plate}" placeholder="Araç Plakası" />
          <input class="dark-input" id="profBlood" value="${state.bloodType}" placeholder="Kan Grubu" />
          <input class="dark-input" id="profIce" value="${state.icePhone}" placeholder="Acil Durum Yakını Tel" />
          <button class="primary-btn" id="saveProfileBtn">✓ Künyeyi Kaydet</button>
        </div>
      </div>
    `;
  }

  function renderActiveScreen() {
    const viewport = document.getElementById('screenViewport');
    if (state.activeTab === 'nav') viewport.innerHTML = renderNavTab();
    else if (state.activeTab === 'sos') viewport.innerHTML = renderSosTab();
    else if (state.activeTab === 'wiki') viewport.innerHTML = renderWikiTab();
    else if (state.activeTab === 'rent') viewport.innerHTML = renderRentTab();
    else viewport.innerHTML = renderGarageTab();

    bindScreenEvents();
  }

  function open112Modal() {
    clearInterval(callTimer);
    let sec = 0;
    const v = getVehicle();
    const container = document.getElementById('modalContainer');

    function renderCall() {
      const mm = String(Math.floor(sec / 60)).padStart(2, '0');
      const ss = String(sec % 60).padStart(2, '0');
      container.innerHTML = `
        <div class="modal-backdrop" id="closeModalBackdrop">
          <div class="modal-sheet sos-sheet" onclick="event.stopPropagation()">
            <div style="text-align:center;">
              <span style="background:#EF4444; padding:5px 14px; border-radius:999px; font-size:12px; font-weight:900;">
                🚨 112 ACİL ÇAĞRI MERKEZİ AKTİF · ${mm}:${ss}
              </span>
              <div style="font-size:17px; font-weight:900; margin-top:12px;">
                Sesli Görüşme Açık — Operatöre Okuyabileceğiniz Konum Kartı
              </div>
            </div>

            <div style="margin-top:14px; padding:14px; border-radius:16px; background:rgba(255,255,255,0.06); border:1px solid rgba(239,68,68,0.5); font-size:13px; line-height:1.6;">
              <div>📍 <strong>Canlı GPS & Adres:</strong> ${state.liveAddressLabel || '40.9819° K, 29.0576° D (Kadıköy/İstanbul)'}</div>
              <div>🚗 <strong>Araç:</strong> ${v.brandName} ${v.modelName} · <strong>Plaka:</strong> ${state.plate}</div>
              <div>🩸 <strong>Sürücü:</strong> ${state.driverName} · <strong>Kan Grubu:</strong> ${state.bloodType}</div>
              <div style="color:#FDE68A; font-weight:800; margin-top:4px;">
                ${
                  v.isElectric
                    ? '⚡ İTFAİYE UYARISI: Yüksek Voltajlı Elektrikli Araç (HV Batarya Kesici Ön Kaput Altı)'
                    : `⛽ YAKIT TİPİ: ${v.powertrainLabel}`
                }
              </div>
            </div>

            <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px; margin-top:16px;">
              <a href="tel:112" class="primary-btn" style="background:#16A34A; text-decoration:none;">📱 Gerçek 112 Çevir</a>
              <button class="primary-btn" id="hangupBtn" style="background:#DC2626;">✖ Çağrıyı Kapat</button>
            </div>
          </div>
        </div>
      `;
      document.getElementById('hangupBtn').onclick = closeModal;
      document.getElementById('closeModalBackdrop').onclick = closeModal;
    }

    renderCall();
    callTimer = setInterval(() => {
      sec++;
      if (document.getElementById('hangupBtn')) renderCall();
      else clearInterval(callTimer);
    }, 1000);
  }

  function openTowModal(towId) {
    const t = DATA.towTrucks.find((x) => x.id === towId) || DATA.towTrucks[0];
    const v = getVehicle();
    const container = document.getElementById('modalContainer');
    container.innerHTML = `
      <div class="modal-backdrop" id="closeModalBackdrop">
        <div class="modal-sheet" onclick="event.stopPropagation()">
          <div style="display:flex; align-items:center; gap:12px;">
            <div style="width:48px; height:48px; border-radius:50%; background:#F59E0B; display:flex; align-items:center; justify-content:center; font-size:24px;">🛻</div>
            <div>
              <div style="font-size:16.5px; font-weight:900;">${t.company}</div>
              <div style="font-size:12.5px; color:#CBD5E1;">Operatör: ${t.driver} · Plaka: ${t.plate}</div>
            </div>
          </div>

          <div style="margin-top:14px; padding:13px; border-radius:15px; background:rgba(255,255,255,0.05); font-size:12.5px; line-height:1.6;">
            <div>📍 <strong>Mesafe & Süre:</strong> ${t.km} km · Tahmini ${t.eta} dakikada yanınızda</div>
            <div>🛻 <strong>Kurtarıcı Tipi:</strong> ${t.truckType}</div>
            <div>💰 <strong>Şeffaf Ücret:</strong> ₺${t.baseTry} açılış + ₺${t.perKmTry}/km</div>
            <div style="color:#93C5FD;">🔧 <strong>Otomatik İletilen Araç:</strong> ${v.brandName} ${v.modelName} (${v.weightKg} kg · ${v.drivetrain})</div>
          </div>

          <div style="display:grid; grid-template-columns:1fr 2fr; gap:10px; margin-top:16px;">
            <button class="outline-btn" id="hangupBtn">Kapat</button>
            <a href="tel:${t.phone.replace(/\s+/g, '')}" class="primary-btn" style="text-decoration:none;">📞 ${t.phone} Ara</a>
          </div>
        </div>
      </div>
    `;
    document.getElementById('hangupBtn').onclick = closeModal;
    document.getElementById('closeModalBackdrop').onclick = closeModal;
  }

  function openRentalModal(rentId) {
    const item = DATA.rentals.find((x) => x.id === rentId);
    if (!item) return;
    let days = 2;
    const container = document.getElementById('modalContainer');

    function draw() {
      const total = days * item.dailyTry;
      container.innerHTML = `
        <div class="modal-backdrop" id="closeModalBackdrop">
          <div class="modal-sheet" onclick="event.stopPropagation()">
            <div style="font-size:17.5px; font-weight:900;">${item.title}</div>
            <div style="font-size:12.5px; color:#CBD5E1; margin-top:3px;">
              Araç Sahibi: ${item.host} ✓ (${item.distanceText}) · Doluluk: %${item.soc}
            </div>

            <div style="display:flex; justify-content:space-between; align-items:center; margin:16px 0; padding:12px; border-radius:14px; background:rgba(255,255,255,0.05);">
              <span style="font-weight:800;">Kiralama Süresi:</span>
              <div style="display:flex; align-items:center; gap:12px;">
                <button class="outline-btn" id="decDayBtn">−</button>
                <strong style="font-size:16px;">${days} Gün</strong>
                <button class="outline-btn" id="incDayBtn">+</button>
              </div>
            </div>

            <div style="display:flex; justify-content:space-between; font-size:15px; font-weight:900;">
              <span>Toplam Kira (${days} × ₺${item.dailyTry})</span>
              <span>₺${total}</span>
            </div>
            <div style="font-size:11.5px; color:var(--text-muted); margin-top:4px;">
              + İade Edilebilir Provizyon: ₺${item.depositTry} · Günlük ${item.kmLimit} km ve Tam Kasko Dahil
            </div>

            <div style="display:grid; grid-template-columns:1fr 2fr; gap:10px; margin-top:16px;">
              <button class="outline-btn" id="hangupBtn">Vazgeç</button>
              <button class="primary-btn" id="confirmRentBtn">✓ Hemen Kirala (₺${total})</button>
            </div>
          </div>
        </div>
      `;
      document.getElementById('decDayBtn').onclick = () => {
        if (days > 1) {
          days--;
          draw();
        }
      };
      document.getElementById('incDayBtn').onclick = () => {
        days++;
        draw();
      };
      document.getElementById('hangupBtn').onclick = closeModal;
      document.getElementById('closeModalBackdrop').onclick = closeModal;
      document.getElementById('confirmRentBtn').onclick = () => {
        container.innerHTML = `
          <div class="modal-backdrop" id="closeModalBackdrop">
            <div class="modal-sheet" style="text-align:center;">
              <div style="font-size:40px;">🎉</div>
              <div style="font-size:18px; font-weight:900; margin-top:8px;">Rezervasyon Onaylandı!</div>
              <div style="font-size:13px; color:#CBD5E1; margin-top:6px;">
                <strong>${item.title}</strong> için ${days} günlük kiralama talebiniz <strong>${item.host}</strong> tarafından onaylandı. ${item.keyless ? 'Dijital anahtarınız telefonunuza tanımlandı!' : 'Teslim noktası haritanıza eklendi.'}
              </div>
              <button class="primary-btn" id="doneRentBtn" style="width:100%; margin-top:16px;">Tamam</button>
            </div>
          </div>
        `;
        document.getElementById('doneRentBtn').onclick = closeModal;
        document.getElementById('closeModalBackdrop').onclick = closeModal;
      };
    }

    draw();
  }

  function closeModal() {
    clearInterval(callTimer);
    document.getElementById('modalContainer').innerHTML = '';
  }

  function bindScreenEvents() {
    document.querySelectorAll('[data-select-car]').forEach((el) => {
      el.onclick = () => selectVehicle(el.dataset.selectCar);
    });

    const quickTow = document.getElementById('quickTowBtn');
    if (quickTow) {
      quickTow.onclick = () => {
        switchTab('sos');
        openTowModal(DATA.towTrucks[0].id);
      };
    }

    const quickSos = document.getElementById('quickSosBtn');
    if (quickSos) quickSos.onclick = open112Modal;

    const main112 = document.getElementById('main112CallBtn');
    if (main112) main112.onclick = open112Modal;

    const routeSel = document.getElementById('routeSelector');
    if (routeSel) {
      routeSel.onchange = (e) => {
        state.selectedRouteId = e.target.value;
        state.routeProgress = 0.08;
        state.addedWaypoints.clear();
        renderActiveScreen();
      };
    }

    const slider = document.getElementById('routeSlider');
    if (slider) {
      slider.oninput = (e) => {
        state.routeProgress = Number(e.target.value) / 100;
        renderActiveScreen();
      };
    }

    const driveBtn = document.getElementById('toggleDriveBtn');
    if (driveBtn) {
      driveBtn.onclick = () => {
        state.isDrivingSim = !state.isDrivingSim;
        clearInterval(driveTimer);
        if (state.isDrivingSim) {
          driveTimer = setInterval(() => {
            state.routeProgress += 0.015;
            if (state.routeProgress >= 1) {
              state.routeProgress = 0.05;
            }
            if (state.activeTab === 'nav') renderActiveScreen();
          }, 450);
        }
        renderActiveScreen();
      };
    }

    document.querySelectorAll('[data-toggle-waypoint]').forEach((btn) => {
      btn.onclick = () => {
        const id = btn.dataset.toggleWaypoint;
        if (state.addedWaypoints.has(id)) state.addedWaypoints.delete(id);
        else state.addedWaypoints.add(id);
        renderActiveScreen();
      };
    });

    document.querySelectorAll('[data-station-modal]').forEach((btn) => {
      btn.onclick = () => {
        const id = btn.dataset.stationModal;
        if (state.addedWaypoints.has(id)) state.addedWaypoints.delete(id);
        else state.addedWaypoints.add(id);
        renderActiveScreen();
      };
    });

    const flatbedBtn = document.getElementById('toggleFlatbedBtn');
    if (flatbedBtn) {
      flatbedBtn.onclick = () => {
        state.flatbedOnly = !state.flatbedOnly;
        renderActiveScreen();
      };
    }

    document.querySelectorAll('[data-call-tow]').forEach((btn) => {
      btn.onclick = () => openTowModal(btn.dataset.callTow);
    });

    const wikiSearch = document.getElementById('wikiSearchInput');
    if (wikiSearch) {
      wikiSearch.oninput = (e) => {
        const pos = e.target.selectionStart;
        state.wikiSearch = e.target.value;
        renderActiveScreen();
        const nextInput = document.getElementById('wikiSearchInput');
        if (nextInput) {
          nextInput.focus();
          nextInput.setSelectionRange(pos, pos);
        }
      };
    }

    const decodeBtn = document.getElementById('decodeVinBtn');
    if (decodeBtn) {
      decodeBtn.onclick = async () => {
        const val = document.getElementById('vinInputBox').value.trim();
        state.vinInput = val;
        try {
          const res = await fetch(`/api/vin/${encodeURIComponent(val)}`);
          const data = await res.json();
          if (res.ok) state.vinDecoded = data;
        } catch (_) {}
        renderActiveScreen();
      };
    }

    document.querySelectorAll('[data-wiki-car]').forEach((btn) => {
      btn.onclick = () => {
        state.wikiSpecId = btn.dataset.wikiCar;
        renderActiveScreen();
      };
    });

    document.querySelectorAll('[data-wiki-sub]').forEach((btn) => {
      btn.onclick = () => {
        state.wikiSubTab = btn.dataset.wikiSub;
        renderActiveScreen();
      };
    });

    document.querySelectorAll('[data-rent-filter]').forEach((btn) => {
      btn.onclick = () => {
        state.rentFilter = btn.dataset.rentFilter;
        renderActiveScreen();
      };
    });

    document.querySelectorAll('[data-book-rental]').forEach((btn) => {
      btn.onclick = () => openRentalModal(btn.dataset.bookRental);
    });

    const saveProf = document.getElementById('saveProfileBtn');
    if (saveProf) {
      saveProf.onclick = () => {
        state.driverName = document.getElementById('profName').value;
        state.plate = document.getElementById('profPlate').value;
        state.bloodType = document.getElementById('profBlood').value;
        state.icePhone = document.getElementById('profIce').value;
        renderActiveScreen();
      };
    }
  }

  // Global Nav & Top 112 bindings
  document.querySelectorAll('.nav-item').forEach((btn) => {
    btn.addEventListener('click', () => switchTab(btn.dataset.tab));
  });
  document.getElementById('topSosBtn').addEventListener('click', open112Modal);
  document.addEventListener('click', (e) => {
    const sideBtn = e.target.closest('#sideQuickBrands [data-select-car]');
    if (sideBtn) selectVehicle(sideBtn.dataset.selectCar);
  });

  async function initBrowserLiveApis() {
    const statusBox = document.getElementById('liveApiSideStatus');
    try {
      const geoRes = await fetch('https://get.geojs.io/v1/ip/geo.json');
      const geo = await geoRes.json();
      const lat = parseFloat(geo.latitude) || 40.9903;
      const lon = parseFloat(geo.longitude) || 29.0292;
      const [meteoRes, nomRes] = await Promise.all([
        fetch(`https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,wind_speed_10m`),
        fetch(`https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${lat}&lon=${lon}&accept-language=tr`)
      ]);
      const meteo = await meteoRes.json();
      const nom = await nomRes.json();
      const temp = meteo.current ? `${meteo.current.temperature_2m}°C` : '';
      state.liveAddressLabel = nom.display_name
        ? `${lat.toFixed(4)}° K, ${lon.toFixed(4)}° D — ${nom.display_name}`
        : `${lat.toFixed(4)}° K, ${lon.toFixed(4)}° D (${geo.city || 'İstanbul'})`;
      if (statusBox) {
        statusBox.innerHTML = `🟢 <strong>Canlı Bağlandı:</strong> ${geo.city || 'Türkiye'} (${temp}) · GeoJS + Nominatim + Open-Meteo + OSRM + NHTSA Aktif`;
      }
    } catch (_) {
      if (statusBox) {
        statusBox.innerHTML = `🟢 <strong>APK v1.1.0 Hazır:</strong> Android cihazda GPS + Nominatim + OSRM + Overpass + Open-Meteo + NHTSA + EPA canlı çalışır.`;
      }
    }
  }

  applyBrandTheme();
  renderActiveScreen();
  initBrowserLiveApis();
})();
