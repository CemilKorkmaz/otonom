const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const ROOT = __dirname;

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
};

function decodeVinDeterministic(rawVin) {
  const vin = String(rawVin || '').trim().toUpperCase();
  const wmi = vin.slice(0, 3);
  let make = 'Avrupa OEM Üretici';
  let model = 'Fabrika Şasi Kaydı';
  let powertrain = 'Benzin / Elektrik';
  let plant = 'Almanya';
  let engine = 'OEM Ünite';

  if (wmi.startsWith('5YJ') || wmi.startsWith('XP7') || wmi.startsWith('LRW')) {
    make = 'Tesla';
    model = 'Model Y Performance / Long Range';
    powertrain = 'Tam Elektrikli (BEV · Dual Motor)';
    plant = wmi === 'XP7' ? 'Giga Berlin, Almanya' : 'Fremont / Şanghay';
    engine = '3D3 + 4D1 Hairpin PMSRM (534 HP)';
  } else if (wmi === 'WBS' || wmi.startsWith('WBA')) {
    make = wmi === 'WBS' ? 'BMW M GmbH' : 'BMW';
    model = wmi === 'WBS' ? 'M4 Competition M xDrive (G82)' : '3 / 4 Serisi M Sport';
    powertrain = 'Benzin TwinPower Turbo';
    plant = 'Dingolfing / Münih, Almanya';
    engine = wmi === 'WBS' ? 'S58B30T0 3.0L Twin-Turbo (530 HP)' : 'B48B20 2.0L Turbo';
  } else if (wmi.startsWith('NL1') || wmi.startsWith('TRT')) {
    make = 'Togg';
    model = 'T10X V2 Uzun Menzil';
    powertrain = 'Tam Elektrikli (BEV · 88.5 kWh)';
    plant = 'Gemlik Kampüsü, Bursa / Türkiye';
    engine = 'Bosch SMG180 160 kW (218 HP)';
  } else if (wmi.startsWith('W1K') || wmi.startsWith('WDD')) {
    make = 'Mercedes-Benz';
    model = 'C 200 4MATIC AMG Line (W206)';
    powertrain = 'Benzin + 48V EQ Boost';
    plant = 'Bremen, Almanya';
    engine = 'M254 E15 + ISG (204+20 HP)';
  } else if (wmi.startsWith('WP0')) {
    make = 'Porsche';
    model = 'Taycan Turbo S (J1)';
    powertrain = '800V Tam Elektrikli E-Performance';
    plant = 'Zuffenhausen, Almanya';
    engine = 'Dual PSM + 2 İleri Şanzıman (952 HP)';
  } else if (wmi === 'WUA' || wmi.startsWith('WAU')) {
    make = wmi === 'WUA' ? 'Audi Sport GmbH' : 'Audi';
    model = wmi === 'WUA' ? 'RS 6 Avant Performance (C8)' : 'A6 quattro';
    powertrain = '4.0L V8 TFSI + 48V MHEV';
    plant = 'Neckarsulm, Almanya';
    engine = 'EA825 DYGA V8 Twin-Turbo (630 HP)';
  }

  return {
    vin,
    make,
    model,
    year: '2024',
    powertrain,
    plant,
    engine,
    carInfoUrl: `https://www.car.info/en-se/search?q=${encodeURIComponent(`${make} ${model}`)}`,
  };
}

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const parsedUrl = new URL(req.url, 'http://localhost');
  const pathname = parsedUrl.pathname;

  if (pathname === '/api/health') {
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify({ status: 'ok', app: 'Otonom Interactive Simulator' }));
    return;
  }

  if (pathname.startsWith('/api/vin/')) {
    const vin = decodeURIComponent(pathname.replace('/api/vin/', ''));
    if (vin.trim().length < 11) {
      res.writeHead(400, { 'Content-Type': 'application/json; charset=utf-8' });
      res.end(JSON.stringify({ error: 'En az 11-17 karakterli geçerli bir VIN girin.' }));
      return;
    }
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify(decodeVinDeterministic(vin)));
    return;
  }

  let filePath = pathname === '/' ? '/index.html' : pathname;
  const resolved = path.normalize(path.join(ROOT, filePath));
  if (!resolved.startsWith(ROOT)) {
    res.writeHead(403);
    res.end('Forbidden');
    return;
  }

  fs.readFile(resolved, (err, data) => {
    if (err) {
      fs.readFile(path.join(ROOT, 'index.html'), (err2, fallback) => {
        if (err2) {
          res.writeHead(404);
          res.end('Not found');
          return;
        }
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(fallback);
      });
      return;
    }
    const ext = path.extname(resolved).toLowerCase();
    res.writeHead(200, {
      'Content-Type': MIME_TYPES[ext] || 'application/octet-stream',
      'Cache-Control': 'no-cache',
    });
    res.end(data);
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Otonom Live Mobile Preview listening on http://0.0.0.0:${PORT}`);
});
