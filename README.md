# LeaveSphere Mobile — Employee App

Aplikasi Flutter untuk karyawan: mengajukan cuti, melihat riwayat, kalender tim, dan profil. Terhubung ke backend Laravel (LeaveSphere web) lewat REST API + Sanctum token auth.

---

## 📱 Halaman yang Tersedia

| Halaman | Fitur |
|---|---|
| **Login** | Autentikasi via email & password, simpan token otomatis |
| **Home** | Sisa cuti, ringkasan status (pending/approved/rejected), cuti mendatang, 5 pengajuan terbaru |
| **Apply Leave** | Form pengajuan cuti — pilih jenis, tanggal mulai/selesai, alasan |
| **History** | Riwayat semua pengajuan dengan filter status, detail + bisa batalkan jika masih pending |
| **Calendar** | Kalender tim (departemen sendiri) — lihat siapa saja yang sedang cuti |
| **Profile** | Info karyawan, ubah password, logout |

---

## 🔧 Setup

### 1. Requirement
- Flutter SDK (cek `flutter doctor` sudah hijau semua)
- Android Studio dengan Android SDK
- Backend Laravel **LeaveSphere** sudah jalan (lihat project web-nya)

### 2. Install dependencies

Buka folder ini di Android Studio / VS Code, lalu jalankan:

```bash
flutter pub get
```

### 3. **PENTING: Konfigurasi alamat backend**

Buka file `lib/services/api_service.dart`, cari baris:

```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

Sesuaikan dengan kondisi kamu:

| Skenario | URL yang dipakai |
|---|---|
| **Android Emulator** + Laravel `php artisan serve` di laptop yang sama | `http://10.0.2.2:8000/api` (default, sudah benar) |
| **HP Android fisik** terhubung WiFi yang sama dengan laptop | `http://[IP-LAPTOP-KAMU]:8000/api` — cari IP laptop dengan `ipconfig` (Windows) lalu cari "IPv4 Address", contoh: `http://192.168.1.5:8000/api` |
| **iOS Simulator** | `http://localhost:8000/api` |

> ⚠️ `10.0.2.2` adalah alamat khusus yang dipetakan emulator Android ke `localhost` milik komputer host. Ini **tidak akan jalan** di HP fisik — wajib ganti ke IP address laptop kamu.

Kalau pakai HP fisik, pastikan juga laptop & HP terhubung ke WiFi yang **sama**, dan jalankan Laravel dengan:
```bash
php artisan serve --host=0.0.0.0 --port=8000
```
(`--host=0.0.0.0` supaya Laravel bisa diakses dari perangkat lain di jaringan yang sama, bukan cuma dari `localhost`)

### 4. Pastikan backend Laravel sudah siap

Di folder project **leavesphere** (web), jalankan:
```bash
composer install
php artisan migrate:fresh --seed
php artisan serve --host=0.0.0.0 --port=8000
```

> Migration baru `personal_access_tokens` (untuk Sanctum) sudah termasuk dalam paket ini — pastikan kamu pakai folder `database/migrations` yang terbaru.

### 5. Jalankan aplikasi Flutter

Buka emulator Android (atau colok HP fisik dengan USB debugging aktif), lalu:

```bash
flutter run
```

Atau lewat Android Studio: klik tombol **Run** (▶️) di toolbar.

---

## 🔑 Login untuk Testing

Pakai akun employee yang sudah ada dari seeder Laravel, contoh:

| Email | Password |
|---|---|
| `muhammad.arya.pradana@company.com` | `password` |
| `muhammad.zaki.zakariyya@company.com` | `password` |
| `alifito.rabbani.citra@company.com` | `password` |

(Semua password dummy = `password`)

---

## 📂 Struktur Folder

```
lib/
├── main.dart                  → Entry point
├── models/                    → Data models (User, LeaveRequest, CalendarEvent)
├── services/                  → API communication layer
│   ├── api_service.dart       → HTTP client + token storage
│   ├── auth_service.dart      → Login/logout
│   ├── leave_service.dart     → Apply/history/cancel leave
│   ├── home_service.dart      → Home dashboard summary
│   ├── calendar_service.dart  → Team calendar events
│   └── profile_service.dart   → Profile + change password
├── screens/                   → 6 halaman utama
├── widgets/                   → Reusable components (cards, badges)
└── utils/
    └── app_theme.dart         → Warna & style terpusat (sama dengan web admin)
```

---

## 🐛 Troubleshooting

**"Tidak dapat terhubung ke server"**
- Pastikan Laravel `php artisan serve` sedang berjalan
- Cek `baseUrl` di `api_service.dart` sudah benar sesuai skenario kamu
- Kalau pakai HP fisik, pastikan laptop & HP satu jaringan WiFi, dan tidak diblokir firewall

**Error CORS / 419 / token issues**
- Pastikan migration `personal_access_tokens` sudah dijalankan di Laravel
- Cek `bootstrap/app.php` Laravel sudah include `api: __DIR__.'/../routes/api.php'`

**Login berhasil tapi data kosong**
- Pastikan akun employee yang dipakai untuk login punya `leave_requests` di database (cek seeder)

---

## 👥 Tim Pengembang — Kelompok 7

Project ini melengkapi sistem **LeaveSphere** (web admin panel) yang menangani sisi approval/HR, sementara aplikasi mobile ini menangani sisi self-service karyawan.
