Got it 👍 — here’s your **simplified `README.md`** tailored specifically for the **Android version** of your Civic Issue Reporter App.

---

```markdown
# 🏙️ Civic Issue Reporter App (Android)

A Flutter Android app that allows users to report and view civic issues like garbage, potholes, and streetlight failures.  
Data is stored and managed using **Supabase**.

---

## 🚀 Features

- Report civic issues with an image and description  
- View list of all reported issues  
- Check detailed information of each issue  
- Data stored securely on Supabase  

---

## 🧩 Tech Stack

- **Frontend:** Flutter  
- **Backend & Database:** Supabase (PostgreSQL + Storage)  

---

## 📁 Folder Structure

```

lib/
├── main.dart
├── home_page.dart
├── report_page.dart
├── issues_list_page.dart
├── issue_detail_page.dart

````

---

## ⚙️ Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/civic-issue-reporter.git
cd civic-issue-reporter
````

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Supabase

1. Go to [Supabase.io](https://supabase.io) and create a new project.

2. Create a table named `reports` with these columns:

   | Column     | Type        |
   | ---------- | ----------- |
   | id         | bigint (PK) |
   | issue_type | text        |
   | image_url  | text        |
   | latitude   | double      |
   | longitude  | double      |
   | created_at | timestamp   |

3. Create a storage bucket named **`civic-issue`** for image uploads.

4. Copy your **Project URL** and **Anon Key**.

### 4. Add Supabase Keys

Create a file `lib/supabase_key.dart`:

```dart
const String supabaseUrl = 'https://your-project-url.supabase.co';
const String supabaseAnonKey = 'your-anon-key';
```

> ⚠️ Don’t upload this file to GitHub.

---

## 🧹 .gitignore

Add these lines to `.gitignore`:

```
lib/supabase_key.dart
.pub/
build/
.dart_tool/
.idea/
android/app/google-services.json
```

---

## ▶️ Run the App on Android

Connect your Android device or emulator, then run:

```bash
flutter run
```

Or to build an APK:

```bash
flutter build apk
```

---

## 🧑‍💻 Author

**Prathmesh Pawar**

---



