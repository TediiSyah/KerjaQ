# Fitur Tambah Posisi (Add Position)

## 🎯 Deskripsi

Fitur untuk menambahkan posisi/lowongan kerja baru melalui tombol "Add Section" di HRD Dashboard.

## 📋 Data yang Dikirim ke API

```json
{
  "position_name": "Project Manager bbbb",
  "capacity": 1,
  "description": "lorem ipsum dolor sit amet",
  "submission_start_date": "2025-08-01 12:00:00",
  "submission_end_date": "2025-09-30 12:00:00"
}
```

## 🔧 Implementasi

### 1. **API Service** (`position_service.dart`)

Method `createPosition()` untuk mengirim data ke backend:

```dart
Future<Map<String, dynamic>> createPosition({
  required String positionName,
  required int capacity,
  required String description,
  required String submissionStartDate,
  required String submissionEndDate,
}) async {
  // POST ke /positions dengan Authorization Bearer token
}
```

**Endpoint:** `POST /positions`

**Headers:**
- `Content-Type: application/json`
- `Authorization: Bearer {token}`
- `APP-KEY: d11869cbb24234949e1d47e131adbd7c6fc6d6b2`

### 2. **Form Dialog** (`hrdDashboard.dart`)

Form dengan 5 field:

1. **Nama Posisi** (TextField)
   - Required
   - Contoh: "Project Manager"

2. **Kapasitas** (TextField - Number)
   - Required
   - Contoh: 1

3. **Deskripsi** (TextField - Multiline)
   - Required
   - Contoh: "lorem ipsum dolor sit amet"

4. **Tanggal Mulai Pendaftaran** (DatePicker)
   - Required
   - Format: "YYYY-MM-DD 12:00:00"
   - Contoh: "2025-08-01 12:00:00"

5. **Tanggal Akhir Pendaftaran** (DatePicker)
   - Required
   - Format: "YYYY-MM-DD 12:00:00"
   - Contoh: "2025-09-30 12:00:00"
   - Minimal: Tanggal mulai

## 📱 User Flow

```
1. User klik tombol "Add Section" di dashboard
   ↓
2. Dialog form muncul
   ↓
3. User isi semua field (required)
   ↓
4. User klik "Simpan"
   ↓
5. Validasi field (semua harus diisi)
   ↓
6. Loading indicator muncul
   ↓
7. API call ke POST /positions
   ↓
8. Response dari server:
   - Success → Snackbar hijau + reload data
   - Error → Snackbar merah dengan pesan error
```

## ✅ Validasi

- Semua field wajib diisi
- Kapasitas harus berupa angka
- Tanggal akhir harus >= tanggal mulai
- Format tanggal: "YYYY-MM-DD HH:MM:SS"

## 📤 Request Example

```bash
POST https://learn.smktelkom-mlg.sch.id/jobsheeker/positions
Headers:
  Content-Type: application/json
  Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  APP-KEY: d11869cbb24234949e1d47e131adbd7c6fc6d6b2

Body:
{
  "position_name": "Project Manager bbbb",
  "capacity": 1,
  "description": "lorem ipsum dolor sit amet",
  "submission_start_date": "2025-08-01 12:00:00",
  "submission_end_date": "2025-09-30 12:00:00"
}
```

## 📥 Response Expected

### Success (200/201)
```json
{
  "success": true,
  "message": "Position created successfully",
  "data": {
    "id": 123,
    "uuid": "abc-def-ghi",
    "position_name": "Project Manager bbbb",
    "capacity": 1,
    "description": "lorem ipsum dolor sit amet",
    "submission_start_date": "2025-08-01 12:00:00",
    "submission_end_date": "2025-09-30 12:00:00",
    "company_id": "...",
    "createdAt": "2025-10-29T08:00:00Z"
  }
}
```

### Error (400/500)
```json
{
  "success": false,
  "message": "Validation error: position_name is required"
}
```

## 🎨 UI Components

### Form Dialog
- **Title:** "Tambahkan Baru" (dengan icon add)
- **Background:** Gradient indigo
- **Fields:** 5 input fields dengan icons
- **Buttons:**
  - "Batal" (gray)
  - "Simpan" (indigo gradient)

### Success Snackbar
- **Color:** Indigo
- **Icon:** Check circle
- **Message:** "Posisi berhasil ditambahkan!"
- **Duration:** 3 seconds

### Error Snackbar
- **Color:** Red
- **Icon:** Error outline
- **Message:** Error message dari API
- **Duration:** 5 seconds

### Loading Snackbar
- **Color:** Default
- **Icon:** CircularProgressIndicator
- **Message:** "Menambahkan posisi..."
- **Duration:** 30 seconds (auto-hide saat selesai)

## 🔄 After Success

Setelah posisi berhasil ditambahkan:
1. Dialog ditutup
2. Success snackbar muncul
3. **Dashboard auto-reload** (`_loadCompanyData()`)
4. Posisi baru muncul di list

## 🐛 Error Handling

### Client-side Validation
- Field kosong → "Semua field wajib diisi!"
- Kapasitas bukan angka → Default ke 1

### API Errors
- 400 Bad Request → Tampilkan pesan error dari API
- 401 Unauthorized → "Token expired, silakan login ulang"
- 500 Server Error → "Terjadi kesalahan server"
- Network Error → "Tidak dapat terhubung ke server"

## 🧪 Testing

### Test Case 1: Success Flow
```
1. Klik "Add Section"
2. Isi semua field:
   - Nama: "Backend Developer"
   - Kapasitas: 2
   - Deskripsi: "Develop REST API"
   - Mulai: 2025-11-01
   - Akhir: 2025-12-31
3. Klik "Simpan"
4. Expected: Success snackbar + posisi muncul di list
```

### Test Case 2: Validation Error
```
1. Klik "Add Section"
2. Kosongkan field "Nama Posisi"
3. Klik "Simpan"
4. Expected: Red snackbar "Semua field wajib diisi!"
```

### Test Case 3: API Error
```
1. Matikan internet
2. Klik "Add Section"
3. Isi semua field
4. Klik "Simpan"
5. Expected: Red snackbar dengan error message
```

## 📝 Notes

- Token diambil dari SharedPreferences
- Company ID otomatis dari token (backend)
- Tanggal format: "YYYY-MM-DD HH:MM:SS" (fixed 12:00:00)
- Auto-reload setelah success untuk update list
- Loading state untuk UX yang baik

## 🔗 Related Files

- `lib/services/api/position_service.dart` - API service
- `lib/hrd/hrdDashboard.dart` - Form dialog & UI
- `lib/models/position_model.dart` - (Optional) Model class
