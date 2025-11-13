# Troubleshooting - Posisi Tidak Tersimpan

## ❓ Masalah

Setelah klik "Simpan" di form Add Position, data tidak tersimpan.

## 🔍 Cara Debug

### 1. **Cek Console Log**

Setelah klik "Simpan", lihat console untuk log berikut:

```
🔑 Token: eyJhbGciOiJIUzI1NiIs...

📤 Trying endpoint: /positions
📤 URL: https://learn.smktelkom-mlg.sch.id/jobsheeker/positions
📤 Body: {position_name: Project Manager, capacity: 1, ...}

📥 Response status: 404 (atau 200/201/400/500)
📥 Response body: {...}
```

### 2. **Interpretasi Response**

#### ✅ Success (200/201)
```
📥 Response status: 201
📥 Response body: {"success":true,"message":"Position created successfully"}
✅ Position created successfully via /positions
```
**Artinya:** Data berhasil disimpan di backend

#### ❌ Not Found (404)
```
📥 Response status: 404
📥 Response body: {"message":"Cannot POST /positions","error":"Not Found"}
⚠️ Endpoint /positions not found, trying next...
```
**Artinya:** Endpoint `/positions` belum dibuat di backend

#### ❌ Validation Error (400)
```
📥 Response status: 400
📥 Response body: {"success":false,"message":"position_name is required"}
❌ Error from /positions: position_name is required
```
**Artinya:** Data yang dikirim tidak valid

#### ❌ Unauthorized (401)
```
📥 Response status: 401
📥 Response body: {"message":"Unauthorized"}
```
**Artinya:** Token expired atau tidak valid

#### ❌ Server Error (500)
```
📥 Response status: 500
📥 Response body: {"message":"Internal server error"}
```
**Artinya:** Error di backend server

## 🛠️ Solusi Berdasarkan Error

### Jika Semua Endpoint 404

```
⚠️ Endpoint /positions not found, trying next...
⚠️ Endpoint /position not found, trying next...
⚠️ Endpoint /hrd/positions not found, trying next...
⚠️ Endpoint /hrd/position/create not found, trying next...
❌ All endpoints failed
```

**Masalah:** Backend belum membuat endpoint untuk create position

**Solusi:** Backend developer perlu membuat endpoint:

```javascript
// Backend (Node.js/Express example)
router.post('/positions', authenticateToken, async (req, res) => {
  try {
    const { 
      position_name, 
      capacity, 
      description, 
      submission_start_date, 
      submission_end_date 
    } = req.body;

    // Validate
    if (!position_name || !capacity || !description) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required'
      });
    }

    // Get company from token
    const company_id = req.user.company_id; // from JWT

    // Insert to database
    const position = await Position.create({
      position_name,
      capacity,
      description,
      submission_start_date,
      submission_end_date,
      company_id,
    });

    return res.status(201).json({
      success: true,
      message: 'Position created successfully',
      data: position
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message
    });
  }
});
```

### Jika Token Expired (401)

**Solusi:**
1. Logout dari aplikasi
2. Login ulang
3. Coba tambah posisi lagi

### Jika Validation Error (400)

**Solusi:**
- Pastikan semua field diisi
- Cek format tanggal: "YYYY-MM-DD HH:MM:SS"
- Cek kapasitas adalah angka

## 🧪 Test Manual dengan Postman/Insomnia

### Request
```
POST https://learn.smktelkom-mlg.sch.id/jobsheeker/positions

Headers:
  Content-Type: application/json
  Authorization: Bearer YOUR_TOKEN_HERE
  APP-KEY: d11869cbb24234949e1d47e131adbd7c6fc6d6b2

Body (JSON):
{
  "position_name": "Project Manager Test",
  "capacity": 1,
  "description": "lorem ipsum dolor sit amet",
  "submission_start_date": "2025-08-01 12:00:00",
  "submission_end_date": "2025-09-30 12:00:00"
}
```

### Expected Response (Success)
```json
{
  "success": true,
  "message": "Position created successfully",
  "data": {
    "id": 123,
    "uuid": "abc-def-ghi",
    "position_name": "Project Manager Test",
    "capacity": 1,
    "description": "lorem ipsum dolor sit amet",
    "submission_start_date": "2025-08-01T12:00:00.000Z",
    "submission_end_date": "2025-09-30T12:00:00.000Z",
    "company_id": "...",
    "createdAt": "2025-10-29T08:15:00.000Z"
  }
}
```

## 📱 Workaround Sementara

Jika backend belum siap, bisa simpan ke local storage dulu:

```dart
// Temporary: Save to local list
setState(() {
  myPositions.add({
    'position_name': positionNameController.text,
    'capacity': int.parse(capacityController.text),
    'description': descriptionController.text,
    'submission_start_date': startDateController.text,
    'submission_end_date': endDateController.text,
    'status': 'local', // marker for local data
  });
});
```

## 🔗 Endpoints yang Dicoba

Aplikasi akan mencoba 4 endpoint secara berurutan:

1. `POST /positions` ← Standard RESTful
2. `POST /position` ← Singular form
3. `POST /hrd/positions` ← With HRD prefix
4. `POST /hrd/position/create` ← Explicit create action

Jika semua gagal, akan muncul error: "No working endpoint found"

## 📞 Next Steps

1. **Cek Console Log** - Screenshot dan share
2. **Test dengan Postman** - Pastikan endpoint bekerja
3. **Hubungi Backend Developer** - Share dokumentasi ini
4. **Verifikasi Token** - Pastikan masih valid

## 🔍 Debug Checklist

- [ ] Console log menampilkan request body
- [ ] Token tersedia (tidak null)
- [ ] Response status code tercatat
- [ ] Response body tercatat
- [ ] Coba dengan Postman/Insomnia
- [ ] Verifikasi endpoint di backend
- [ ] Cek database apakah data masuk

## 💡 Tips

- Gunakan Postman untuk test endpoint secara langsung
- Copy token dari console log aplikasi
- Pastikan backend server running
- Cek database untuk memastikan data tersimpan
- Lihat log backend untuk error detail
