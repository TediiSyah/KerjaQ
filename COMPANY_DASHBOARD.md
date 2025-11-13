# Dashboard Berbasis Perusahaan

## 🎯 Fitur Utama

Setiap perusahaan yang login akan melihat dashboard dengan data **spesifik perusahaan mereka sendiri**.

## 📊 Apa yang Ditampilkan di Dashboard HRD

### 1. **Company Info Widget**
- Menampilkan nama perusahaan yang sedang login
- Menampilkan alamat perusahaan
- Logo/initial perusahaan

### 2. **Statistik Perusahaan**
- **Jumlah Posisi**: Total posisi yang dibuka oleh perusahaan
- **Jumlah Pelamar**: Total pelamar yang melamar ke perusahaan

### 3. **Daftar Posisi Perusahaan**
- Hanya menampilkan posisi yang dibuat oleh perusahaan yang login
- Bukan posisi dari perusahaan lain

### 4. **Pull to Refresh**
- Tarik ke bawah untuk refresh data terbaru

## 🔄 Alur Kerja

```
1. User HRD Login
   ↓
2. Sistem menyimpan:
   - Token autentikasi
   - Company ID
   - Company Name
   - Company Address
   ↓
3. Dashboard Load
   ↓
4. Fetch data dengan filter company:
   - GET /my-positions (dengan token)
   - GET /my-applicants (dengan token)
   ↓
5. Tampilkan data spesifik perusahaan
```

## 🛠️ Implementasi Teknis

### API Endpoints yang Digunakan

```dart
// Fetch posisi milik perusahaan yang login
GET /my-positions
Headers:
  - Authorization: Bearer {token}
  - APP-KEY: d11869cbb24234949e1d47e131adbd7c6fc6d6b2

// Atau dengan company_id
GET /positions?company_id={company_id}

// Fetch pelamar untuk perusahaan yang login
GET /my-applicants
Headers:
  - Authorization: Bearer {token}
  - APP-KEY: d11869cbb24234949e1d47e131adbd7c6fc6d6b2
```

### Kode di HRD Dashboard

```dart
class _HrddashboardState extends State<Hrddashboard> {
  String? companyName;
  String? companyId;
  List<dynamic> myPositions = [];
  List<dynamic> myApplicants = [];
  
  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }
  
  Future<void> _loadCompanyData() async {
    // Load company info dari session
    companyName = await SessionManager.getCompanyName();
    companyId = await SessionManager.getCompanyId();
    
    // Load data spesifik perusahaan
    final positions = await _positionService.fetchMyCompanyPositions();
    final applicants = await _positionService.fetchMyCompanyApplicants();
    
    setState(() {
      myPositions = positions;
      myApplicants = applicants;
    });
  }
}
```

## 📱 Tampilan Dashboard

```
┌─────────────────────────────────────┐
│  [Company Logo]                     │
│  PT Digdaya Olah Teknologi          │
│  📍 Malang, Indonesia               │
└─────────────────────────────────────┘

┌──────────────┐  ┌──────────────┐
│ 💼 Posisi    │  │ 👥 Pelamar   │
│    5         │  │    23        │
└──────────────┘  └──────────────┘

┌─────────────────────────────────────┐
│ Posisi Perusahaan Saya        5 ✓  │
├─────────────────────────────────────┤
│ Frontend Developer                  │
│ Full Stack · Malang                 │
│ [Aktif]                             │
├─────────────────────────────────────┤
│ Backend Developer                   │
│ Full Time · Malang                  │
│ [Aktif]                             │
└─────────────────────────────────────┘
```

## 🔐 Keamanan

1. **Token-based Authentication**
   - Setiap request menggunakan Bearer token
   - Token disimpan di SharedPreferences

2. **Company Isolation**
   - Backend harus memvalidasi token
   - Hanya return data milik company yang sesuai dengan token

3. **Data Privacy**
   - Perusahaan A tidak bisa melihat data perusahaan B
   - Filter dilakukan di backend berdasarkan token

## 📝 Response API yang Diharapkan

### GET /my-positions

```json
{
  "success": true,
  "message": "Positions retrieved successfully",
  "data": [
    {
      "id": 1,
      "uuid": "abc-123",
      "position_name": "Frontend Developer",
      "description": "Develop web applications",
      "location": "Malang",
      "employment_type": "Full Time",
      "salary_range": "5-8 juta",
      "company_id": "1cf42003-f0f2-45f5-840c-b2d3a32280ac",
      "status": "active"
    }
  ]
}
```

### GET /my-applicants

```json
{
  "success": true,
  "message": "Applicants retrieved successfully",
  "data": [
    {
      "id": 1,
      "uuid": "def-456",
      "applicant_name": "John Doe",
      "position_applied": "Frontend Developer",
      "status": "pending",
      "applied_at": "2025-10-28T10:00:00Z"
    }
  ]
}
```

## 🚀 Testing

### Skenario 1: Login sebagai PT Digdaya
1. Login dengan email: dot@gmail.com
2. Dashboard menampilkan:
   - Nama: PT Digdaya Olah Teknologi
   - Posisi: Hanya posisi dari PT Digdaya
   - Pelamar: Hanya pelamar ke PT Digdaya

### Skenario 2: Login sebagai PT Sekawan Media
1. Login dengan email: sekawan@gmail.com
2. Dashboard menampilkan:
   - Nama: PT Sekawan Media
   - Posisi: Hanya posisi dari PT Sekawan Media
   - Pelamar: Hanya pelamar ke PT Sekawan Media

### Skenario 3: Refresh Data
1. Pull to refresh di dashboard
2. Data ter-update dengan data terbaru dari server

## ⚠️ Catatan Penting

1. **Backend harus mendukung filtering berdasarkan company**
   - Endpoint `/my-positions` harus filter berdasarkan token
   - Endpoint `/my-applicants` harus filter berdasarkan token

2. **Fallback ke data demo**
   - Jika API belum siap, dashboard tetap menampilkan data demo
   - Tidak akan error meskipun API gagal

3. **Session Management**
   - Data company disimpan saat login
   - Tetap tersimpan meskipun app ditutup
   - Dihapus saat logout

## 🔧 Troubleshooting

### Dashboard menampilkan data kosong
- Cek apakah token valid
- Cek apakah company_id tersimpan
- Cek response API di console

### Dashboard menampilkan data perusahaan lain
- Backend tidak melakukan filtering dengan benar
- Pastikan backend validate token dan filter by company

### Loading terus-menerus
- Cek koneksi internet
- Cek endpoint API tersedia
- Lihat error di console
