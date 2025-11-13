# 💼 UKK Job Seeker App

A Flutter application built for **UKK SMK Project**, designed to help **society users (students/applicants)** find internships or job opportunities, manage their profiles, and upload portfolios easily.

---

## 📱 Features

### 👤 Profile Management
- Update name, email, and password  
- Change profile picture (stored locally)  
- Automatically saves user data to local storage using `SharedPreferences`

### 📂 Portfolio Management
- View all portfolios linked to your account  
- Upload new portfolio with:
  - Skill name  
  - Description  
  - Attached file (`.pdf`, `.doc`, `.docx`, `.zip`, `.rar`)  
- Automatically refreshes after successful upload  

### 🔐 Authentication & Authorization
- Token-based authentication via API  
- Integrated with backend endpoint:  
https://learn.smktelkom-mlg.sch.id/jobsheeker

yaml
Salin kode
- Uses Bearer token and APP-KEY for secure access

---

## ⚙️ Tech Stack

| Component | Description |
|------------|--------------|
| **Framework** | Flutter (Dart) |
| **State Management** | Stateful Widgets |
| **Local Storage** | SharedPreferences |
| **HTTP Client** | Dio |
| **File Handling** | File Picker |
| **Font** | Google Fonts (Poppins) |

---

## 🧠 Folder Structure

lib/
├─ main.dart
├─ services/
│ ├─ api_service.dart
│ ├─ profile_service.dart
│ └─ portfolio_service.dart
├─ pages/
│ └─ profile/
│ └─ profile_society_page.dart
assets/
└─ images/
└─ KerjaQLogo.png

yaml
Salin kode

---

## 🚀 How to Run

1. **Clone this repository**
   ```bash
   git clone https://github.com/<your-username>/ukk_tedii.git
   cd ukk_tedii
Install dependencies

bash
Salin kode
flutter pub get
Run the app

bash
Salin kode
flutter run
🧩 API Endpoints Reference
Action	Endpoint	Method
Get active positions	/available-positions/active	GET
Apply to position	/position-applied	POST
Get applied history	/position-applied/me	GET
Get portfolios by UUID	/portofolios/society/{uuid}	GET
Create portfolio	/portofolios	POST

🧾 Changelog
Version	Date	Description
v1.0.0	13 Nov 2025	Initial release with profile & portfolio features
v1.1.0	14 Nov 2025	Added portfolio upload & UUID-based retrieval
v1.2.0	15 Nov 2025	Added local profile picture update

👨‍💻 Developer
Name: Tedi Syah
School: SMK Telkom Malang
Project Type: UKK 2025 — Job Seeker App

📝 License
This project was created for educational purposes.
Feel free to fork, modify, and improve this repository — attribution is appreciated!

yaml
Salin kode

---

Kamu mau sekalian aku bantu tulis **deskripsi singkat (repository description)** dan **topics/tag GitHub** juga biar repo-nya keren waktu muncul di profil?  
Contoh:
> _“A Flutter-based job seeker app for SMK UKK project — with profile, portfolio, and internship management system.”_  
Tags: `flutter`, `ukk`, `smk`, `jobseeker`, `portfolio`, `education`




