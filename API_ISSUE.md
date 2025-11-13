# ⚠️ API Issue - Company Data Tidak Tersedia

## 🔴 Masalah yang Ditemukan

Berdasarkan log aplikasi, ditemukan 2 masalah dengan API backend:

### 1. **Login Response Tidak Mengirim Data Company**

**Response Aktual:**
```json
{
  "success": true,
  "message": "User has login successfully",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "HRD"
}
```

**Response yang Diharapkan:**
```json
{
  "success": true,
  "message": "User has login successfully",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "HRD",
  "user": {
    "uuid": "f105d87b-8a94-4db4-8b42-46ea6e2aa7aa",
    "name": "maspion",
    "email": "maspion@gmail.com"
  },
  "company": {
    "uuid": "e2b5b6da-79d2-4155-9fc2-aefc68571680",
    "name": "maspion",
    "address": "Malang",
    "phone": "085961580015",
    "description": "software house"
  }
}
```

### 2. **Endpoint Company Data Tidak Tersedia**

Endpoint yang dicoba:
- ❌ `/my-company` - 404 Not Found
- ❌ `/company/me` - (akan dicoba)
- ❌ `/companies/me` - (akan dicoba)
- ❌ `/hrd/company` - (akan dicoba)

---

## 🛠️ Solusi yang Sudah Diterapkan

### Workaround di Aplikasi:

1. **Auto-fetch Company Data Setelah Login**
   - Jika login response tidak ada `company`
   - Aplikasi otomatis coba fetch dari API
   - Mencoba beberapa endpoint alternatif

2. **Fallback ke Nama Default**
   - Jika semua gagal, tampilkan nama default
   - User tetap bisa menggunakan aplikasi

3. **Debug Logging Lengkap**
   - Semua request dicatat di console
   - Mudah untuk troubleshooting

---

## ✅ Yang Perlu Diperbaiki di Backend

### Priority 1: Tambahkan Data Company di Login Response

**File Backend:** (endpoint `/auth`)

```javascript
// Contoh implementasi (Node.js/Express)
router.post('/auth', async (req, res) => {
  // ... validasi login ...
  
  const user = await User.findOne({ email });
  
  // Jika role HRD, ambil data company
  let company = null;
  if (user.role === 'HRD') {
    company = await Company.findOne({ user_id: user.uuid });
  }
  
  return res.status(201).json({
    success: true,
    message: 'User has login successfully',
    token: generateToken(user),
    role: user.role,
    user: {
      uuid: user.uuid,
      name: user.name,
      email: user.email
    },
    company: company ? {
      uuid: company.uuid,
      name: company.name,
      address: company.address,
      phone: company.phone,
      description: company.description
    } : null
  });
});
```

### Priority 2: Buat Endpoint untuk Get Company Data

**Endpoint:** `GET /my-company` atau `GET /companies/me`

```javascript
router.get('/my-company', authenticateToken, async (req, res) => {
  try {
    // req.user dari JWT token
    const company = await Company.findOne({ 
      user_id: req.user.uuid 
    });
    
    if (!company) {
      return res.status(404).json({
        success: false,
        message: 'Company not found'
      });
    }
    
    return res.status(200).json({
      success: true,
      message: 'Company has been retrieved',
      data: {
        id: company.id,
        uuid: company.uuid,
        name: company.name,
        address: company.address,
        phone: company.phone,
        description: company.description,
        user_id: company.user_id,
        owner_token: company.owner_token,
        createdAt: company.createdAt,
        updatedAt: company.updatedAt
      }
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message
    });
  }
});
```

---

## 🧪 Testing Setelah Backend Diperbaiki

### Test 1: Login Response
```bash
curl -X POST https://learn.smktelkom-mlg.sch.id/jobsheeker/auth \
  -H "Content-Type: application/json" \
  -H "APP-KEY: d11869cbb24234949e1d47e131adbd7c6fc6d6b2" \
  -d '{
    "email": "maspion@gmail.com",
    "password": "password123"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "token": "...",
  "role": "HRD",
  "company": {
    "name": "maspion",
    "address": "Malang"
  }
}
```

### Test 2: Get Company Endpoint
```bash
curl -X GET https://learn.smktelkom-mlg.sch.id/jobsheeker/my-company \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "APP-KEY: d11869cbb24234949e1d47e131adbd7c6fc6d6b2"
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "uuid": "...",
    "name": "maspion",
    "address": "Malang",
    "description": "software house"
  }
}
```

---

## 📱 Sementara Waktu (Temporary Solution)

Aplikasi sudah diupdate dengan workaround:

1. ✅ Mencoba fetch company data setelah login
2. ✅ Mencoba beberapa endpoint alternatif
3. ✅ Fallback ke nama default jika gagal
4. ✅ Logging lengkap untuk debugging

**Cara Test:**
1. Logout dari aplikasi
2. Login ulang
3. Lihat console log:
   ```
   🔄 Fetching company data from API...
   🔍 Trying endpoint: /my-company
      Status: 404
   🔍 Trying endpoint: /company/me
      Status: 404
   ...
   ```

---

## 📞 Next Steps

1. **Hubungi Backend Developer**
   - Share dokumentasi ini
   - Minta tambahkan `company` di login response
   - Atau buat endpoint `/my-company`

2. **Test Setelah Backend Update**
   - Logout dan login ulang
   - Cek console log
   - Pastikan muncul: `✅ Company data saved: maspion`

3. **Remove Workaround (Optional)**
   - Setelah backend fix
   - Bisa hapus kode workaround
   - Aplikasi akan lebih clean

---

## 🔗 Related Files

- `lib/loginPage.dart` - Login logic dengan workaround
- `lib/services/api/user_service.dart` - Service untuk fetch company
- `lib/hrd/hrdDashboard.dart` - Dashboard yang menampilkan company
- `TROUBLESHOOTING.md` - Panduan debug lengkap
