# Fitur Company - Dokumentasi

## Ringkasan

Sistem sekarang dapat mendeteksi dan menyimpan informasi perusahaan berdasarkan user yang login (khusus untuk role HRD).

## Cara Kerja

### 1. Login & Penyimpanan Data

Ketika user HRD login, sistem akan menyimpan:
- Token autentikasi
- Role user (HRD/SOCIETY)
- Data user (id, name, email)
- **Data company (id, name, address)** ← BARU

Data disimpan di `SharedPreferences` dan dapat diakses kapan saja.

### 2. Mengakses Data Company

#### Cara 1: Menggunakan SessionManager (Recommended)

```dart
import 'package:ukk_tedii/utils/session_manager.dart';

// Cek apakah user adalah HRD
bool isHRD = await SessionManager.isHRD();

// Ambil nama company
String? companyName = await SessionManager.getCompanyName();

// Ambil alamat company
String? companyAddress = await SessionManager.getCompanyAddress();

// Ambil ID company
String? companyId = await SessionManager.getCompanyId();

// Ambil semua data company sekaligus
Map<String, String?> companyData = await SessionManager.getCompanyData();
print(companyData['company_name']);
print(companyData['company_address']);
```

#### Cara 2: Menggunakan UserService (Dari API)

```dart
import 'package:ukk_tedii/services/api/user_service.dart';

final userService = UserService();

// Ambil data company lengkap dari API
Company? company = await userService.getMyCompany();

if (company != null) {
  print('Company: ${company.name}');
  print('Address: ${company.address}');
  print('Phone: ${company.phone}');
  print('Description: ${company.description}');
}
```

### 3. Menampilkan Info Company di UI

#### Menggunakan Widget CompanyInfoWidget

```dart
import 'package:ukk_tedii/widgets/company_info_widget.dart';

// Di dalam build method
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // Widget ini otomatis menampilkan info company
        const CompanyInfoWidget(),
        
        // Widget lainnya...
      ],
    ),
  );
}
```

#### Navigasi ke Halaman Company Profile

```dart
// Navigasi ke halaman detail company
Navigator.pushNamed(context, '/myCompany');

// Atau dengan Navigator.push
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MyCompanyPage(),
  ),
);
```

## File-File yang Dibuat

### 1. Models
- `lib/models/company_model.dart` - Model data Company dan User

### 2. Services
- `lib/services/api/company_service.dart` - Service untuk fetch daftar companies
- `lib/services/api/user_service.dart` - Service untuk fetch company user yang login

### 3. Utils
- `lib/utils/session_manager.dart` - Helper untuk manage session & data login

### 4. Widgets
- `lib/widgets/company_info_widget.dart` - Widget untuk display company info

### 5. Pages
- `lib/masyarakat/companiesPage.dart` - Halaman daftar semua companies
- `lib/masyarakat/companyDetailPage.dart` - Halaman detail company
- `lib/hrd/myCompanyPage.dart` - Halaman profile company sendiri (untuk HRD)

## Routes yang Tersedia

```dart
'/companies'  → Daftar semua perusahaan
'/myCompany'  → Profile perusahaan saya (HRD only)
```

## Contoh Penggunaan di HRD Dashboard

```dart
import 'package:ukk_tedii/utils/session_manager.dart';
import 'package:ukk_tedii/widgets/company_info_widget.dart';

class HRDDashboard extends StatefulWidget {
  // ...
}

class _HRDDashboardState extends State<HRDDashboard> {
  String? companyName;

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
  }

  Future<void> _loadCompanyInfo() async {
    final name = await SessionManager.getCompanyName();
    setState(() {
      companyName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(companyName ?? 'Dashboard'),
      ),
      body: Column(
        children: [
          // Tampilkan info company
          const CompanyInfoWidget(),
          
          // Tombol ke halaman company profile
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/myCompany');
            },
            child: const Text('Lihat Profile Perusahaan'),
          ),
        ],
      ),
    );
  }
}
```

## Response API Login yang Diharapkan

Untuk fitur ini berfungsi optimal, response API login harus menyertakan data company:

```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "HRD",
  "user": {
    "uuid": "4f3f9fd2-0926-4efb-b218-d792ffdfb404",
    "name": "PT Digdaya Olah Teknologi",
    "email": "dot@gmail.com"
  },
  "company": {
    "uuid": "1cf42003-f0f2-45f5-840c-b2d3a32280ac",
    "name": "PT Digdaya Olah Teknologi",
    "address": "Malang, Indonesia",
    "phone": "089889879343",
    "description": "ini adalah software house"
  }
}
```

## Catatan Penting

1. **Data company hanya tersimpan untuk role HRD**
2. Jika API tidak mengembalikan data company saat login, sistem akan fallback ke data lokal (jika ada)
3. Gunakan `SessionManager.clearSession()` saat logout untuk membersihkan semua data
4. Data disimpan di `SharedPreferences` sehingga tetap ada meskipun app ditutup

## Logout

```dart
import 'package:ukk_tedii/utils/session_manager.dart';

// Hapus semua data session
await SessionManager.clearSession();

// Redirect ke login page
Navigator.pushReplacementNamed(context, '/login');
```
