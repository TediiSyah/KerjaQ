# Troubleshooting - Nama Company Tidak Berubah

## ❓ Masalah: Dashboard masih menampilkan "PT Antariksa" padahal login sebagai company lain

### 🔍 Kemungkinan Penyebab:

#### 1. **Response API Login Tidak Mengirim Data Company**
API backend tidak mengirimkan field `company` dalam response login.

**Solusi:**
- Pastikan API login mengembalikan data company
- Format response yang diharapkan:
```json
{
  "success": true,
  "token": "...",
  "role": "HRD",
  "user": {
    "uuid": "...",
    "name": "...",
    "email": "..."
  },
  "company": {
    "uuid": "...",
    "name": "PT Digdaya Olah Teknologi",
    "address": "Malang, Indonesia",
    "description": "ini adalah software house"
  }
}
```

#### 2. **Belum Login Ulang Setelah Update Kode**
Data company hanya disimpan saat login. Jika sudah login sebelum kode diupdate, data company belum tersimpan.

**Solusi:**
- Logout dari aplikasi
- Login kembali
- Data company akan tersimpan

#### 3. **SharedPreferences Masih Menyimpan Data Lama**
Data lama masih tersimpan di device.

**Solusi:**
- Buka halaman debug: `Navigator.pushNamed(context, '/debug')`
- Klik tombol "Clear Session"
- Login ulang

---

## 🛠️ Cara Debug

### 1. **Cek Console Log Saat Login**

Setelah login, lihat console untuk log berikut:

```
✅ Company data saved: PT Digdaya Olah Teknologi
✅ Login success - role: HRD
```

Jika muncul:
```
⚠️ No company data in response
📋 Response data keys: [success, token, role, user]
```

Artinya: **API tidak mengirim data company** → Perbaiki backend

### 2. **Cek Console Log di Dashboard**

Saat dashboard load, lihat console:

```
📊 Dashboard - Company from session:
   Name: PT Digdaya Olah Teknologi
   ID: 1cf42003-f0f2-45f5-840c-b2d3a32280ac
   Address: Malang, Indonesia
```

Jika semua `null`:
```
📊 Dashboard - Company from session:
   Name: null
   ID: null
   Address: null
```

Artinya: **Data tidak tersimpan** → Logout dan login ulang

### 3. **Gunakan Halaman Debug**

Tambahkan tombol di dashboard atau navigasi langsung:

```dart
// Di dashboard, tambahkan floating action button
floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.pushNamed(context, '/debug');
  },
  child: const Icon(Icons.bug_report),
),
```

Atau navigasi langsung:
```dart
Navigator.pushNamed(context, '/debug');
```

Halaman debug akan menampilkan semua data session yang tersimpan.

---

## ✅ Langkah-Langkah Perbaikan

### Jika API Tidak Mengirim Data Company:

1. **Hubungi Backend Developer**
   - Minta tambahkan field `company` di response login
   - Format harus sesuai dengan contoh di atas

2. **Sementara Waktu (Workaround)**
   - Fetch company data setelah login berhasil
   - Modifikasi `_handleLoginSuccess`:

```dart
void _handleLoginSuccess(dynamic responseBody) async {
  final data = responseBody is String ? jsonDecode(responseBody) : responseBody;

  if (data['success'] == true && data['token'] != null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);
    await prefs.setString('role', data['role'] ?? '');
    
    // Fetch company data if not in response
    if (data['company'] == null && data['role'] == 'HRD') {
      try {
        final userService = UserService();
        final company = await userService.getMyCompany();
        
        if (company != null) {
          await prefs.setString('company_id', company.uuid);
          await prefs.setString('company_name', company.name);
          await prefs.setString('company_address', company.address);
        }
      } catch (e) {
        print('Error fetching company: $e');
      }
    }
    
    // Navigate...
  }
}
```

### Jika Data Lama Masih Tersimpan:

1. **Clear Session**
   ```dart
   await SessionManager.clearSession();
   ```

2. **Atau Uninstall App** (untuk testing)
   - Uninstall aplikasi dari device
   - Install ulang
   - Login kembali

3. **Atau Gunakan Debug Page**
   - Buka `/debug`
   - Klik "Clear Session"
   - Login ulang

---

## 🧪 Testing

### Test Case 1: Login PT Digdaya
```
1. Logout (jika sudah login)
2. Login dengan: dot@gmail.com
3. Cek console: "✅ Company data saved: PT Digdaya Olah Teknologi"
4. Dashboard harus tampil: "PT Digdaya Olah Teknologi"
```

### Test Case 2: Login PT Sekawan Media
```
1. Logout
2. Login dengan: sekawan@gmail.com
3. Cek console: "✅ Company data saved: PT Sekawan Media"
4. Dashboard harus tampil: "PT Sekawan Media"
```

### Test Case 3: Switch Company
```
1. Login sebagai PT Digdaya
2. Logout
3. Login sebagai PT Sekawan Media
4. Dashboard harus berubah ke PT Sekawan Media
```

---

## 📝 Checklist Debug

- [ ] Cek console log saat login
- [ ] Cek apakah ada "✅ Company data saved"
- [ ] Cek console log saat dashboard load
- [ ] Buka halaman `/debug` untuk lihat session data
- [ ] Pastikan `company_name` tidak null
- [ ] Jika null, logout dan login ulang
- [ ] Jika masih null, cek response API login
- [ ] Pastikan API mengirim field `company`

---

## 🆘 Jika Masih Bermasalah

1. **Capture Screenshot:**
   - Console log saat login
   - Halaman debug (`/debug`)
   - Dashboard yang menampilkan nama salah

2. **Cek API Response:**
   - Gunakan Postman/Insomnia
   - Test endpoint login
   - Pastikan response mengandung `company`

3. **Temporary Fix:**
   - Hardcode nama company berdasarkan email:
   ```dart
   if (data['user']['email'] == 'dot@gmail.com') {
     companyName = 'PT Digdaya Olah Teknologi';
   }
   ```
