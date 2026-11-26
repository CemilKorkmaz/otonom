# OTONOM — Dinamik Marka Temalı Akıllı Otomobil Süper Uygulaması (Flutter · iOS & Android)

**Otonom**, sürücünün kendi aracına göre **logosunu, uygulama ikonunu, kokpit renk temasını ve navigasyon istasyon tipini** dinamik olarak dönüştüren; acil durumlardan en küçük cıvata torkuna kadar her detayı barındıran kapsamlı **iOS & Android Flutter** uygulamasıdır.

---

## Temel Özellikler

1. **Dünya Üzerindeki Her Aracı Ekleyebileceğiniz Kişisel Garajım (`v1.2.0`)**
   - Hazır örnek araçlar yerine, kullanıcı kendi istediği **dünya üzerindeki herhangi bir marka, model, yıl ve motor/donanım paketindeki** aracı garajına ekler (`SharedPreferences` ile kalıcı kayıt).
   - 45+ global/Türkiye pazarındaki marka için özgün kokpit renk paleti, amblem/monogram ve uyumlu markalarda dinamik ana ekran ikonu otomatik devreye girer.

2. **Akıllı Navigasyon & Motor Tipine Duyarlı İstasyon Rotası**
   - Seçili araç **Elektrikli (EV)** ise (örn. *Tesla Model Y*, *Togg T10X*, *Porsche Taycan*): Yol üstündeki **DC Hızlı Şarj İstasyonlarını** (*Tesla Supercharger, Trugo, ZES, Eşarj*), kaç km ileride olduklarını, kW güçlerini, boş soket sayısını ve tahmini varış batarya yüzdesini gösterir.
   - Seçili araç **Benzinli / İçten Yanmalı (ICE)** ise (örn. *BMW M4 Competition*, *Mercedes C200*, *Audi RS6*): Yol üstündeki **Akaryakıt İstasyonlarını** (*Shell, Opet, Petrol Ofisi, BP*), kaç km uzakta olduklarını ve güncel litre fiyatlarını gösterir.

3. **Tek Tuş En Yakın Çekici & Canlı Arama Ekranı**
   - Konumunuza en yakın çekicileri radar haritası üzerinde mesafe (km) ve tahmini varış süresi (dk) ile listeler.
   - Kayar kasa / basık spor araç ve elektrikli araç uygunluk filtreleri, şeffaf açılış + km ücreti, operatör plaka bilgisi ve doğrudan arama ekranı sunar.

4. **Acil Kaza · 112 SOS Butonu**
   - Tek dokunuşla `112 Acil Çağrı Merkezi` sesli aramasını başlatır (`tel:112`).
   - Operatöre anında okunabilecek **Açık GPS Koordinatı**, **Araç Plakası**, **Sürücü Kan Grubu** ve elektrikli araçlar için **Yüksek Voltaj (HV) İtfaiye Müdahale Uyarısı** kartını ekrana getirir.

5. **Ultra-Detaylı Araç Ansiklopedisi ("En Küçük Cıvatasına Kadar")**
   - **Car.info** veri referansları + **Canlı 17 Haneli Şasi (VIN) Çözümleyici** + **OEM Atölye Teknik Katalog** mimarisi:
     - **Cıvata & Sıkma Torku Tablosu (Nm):** Bijon cıvatası diş adımı (`M14×1.25`, `M14×1.50`), lokma ölçüsü (`17mm`, `21mm`, `E14 Torx`, `M12 XZN`), karter tapası, buji, kaliper ve silindir kapak saplaması sıkma torkları.
     - **Motor & Aktarma:** Motor kodları (`S58B30T0`, `M254`, `4D1`, `EA825`), çap×strok, sıkıştırma oranı ve 1'den 9. vitese kadar tüm dişli oranları.
     - **Şasi, Fren & Bijon PCD:** Disk çap/kalınlıkları, kaliper piston sayıları, bijon aralığı (`5×112`, `5×114.3`, `5×130`), göbek çapı (CB) ve soğuk lastik basınçları.
     - **Sıvılar & Kronik Ekspertiz Rehberi:** Fabrika yağ onay kodları, litre kapasiteleri ve ikinci el ekspertiz kontrol noktaları.

6. **Haritalı Yakındaki Araç Kiralama (P2P)**
   - Çevredeki doğrulanmış araç sahiplerini harita üzerinde günlük/saatlik fiyat pinleriyle gösterir; dijital anahtarsız teslim filtresi ve gün bazlı kira hesaplayıcısı içerir.

---

## Proje Dizin Yapısı

```text
otonom/
├── pubspec.yaml                  # Flutter bağımlılıkları
├── lib/
│   ├── main.dart                 # Dinamik marka temalı Flutter giriş noktası
│   ├── state/app_state.dart      # Garaj, tema, rota ve 112 künye state yönetimi
│   ├── models/                   # Araç, cıvata torku, çekici, kiralama, istasyon modelleri
│   ├── data/                     # Detaylı OEM teknik katalog & Türkiye otoyol rotaları
│   ├── services/                 # Car.info/VIN servisi, 112/Çekici arama, Dinamik İkon köprüsü
│   ├── widgets/                  # Özel vektörel marka amblemleri & interaktif kokpit haritası
│   └── screens/                  # Rota, Acil, Ansiklopedi, Kiralama, Garajım ekranları
├── android/                      # Android izinleri & <activity-alias> dinamik ikon yapılandırması
├── ios/                          # iOS Info.plist CFBundleAlternateIcons & AppDelegate Swift köprüsü
├── test/widget_test.dart         # Birim ve widget testleri
└── preview/                      # Tarayıcı üzerinden anında test edilebilir 1:1 Canlı Mobil Simülatör
```

---

## iOS ve Android İçin Çalıştırma (Flutter)

Bilgisayarınızda Flutter SDK kurulu olduğunda:

```bash
# Eksik standart platform sarmalayıcılarını oluşturmak için (mevcut lib/ kodlarını korur):
flutter create --org com.otonom --project-name otonom .

# Paketleri yükleyin:
flutter pub get

# iOS Simülatör veya Android Emülatör/Cihaz üzerinde başlatın:
flutter run

# Android APK çıktısı almak için:
flutter build apk --release
```
