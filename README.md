# 🎭 Actor Audition Platform

A comprehensive Flutter-based platform that bridges the gap between aspiring actors and casting directors. The application enables actors to discover auditions, submit applications, and showcase their talent, while casting directors can create auditions, manage applicants, and find the right talent efficiently.

## 🚀 Features

### 👨‍🎤 For Actors

* Create and manage actor profiles
* Browse available auditions
* View audition details and requirements
* Apply for auditions
* Upload portfolios and supporting documents
* Track submitted applications

### 🎬 For Casting Directors

* Create and publish auditions
* Upload audition scripts and documents
* Review actor applications
* View actor profiles and portfolios
* Manage audition listings
* Shortlist suitable candidates

### 🔐 Authentication

* Email & Password Sign Up
* Email & Password Login
* Secure authentication using Firebase Authentication
* Session management

## 🛠️ Tech Stack

### Frontend

* Flutter
* Dart

### Backend & Cloud Services

* Firebase Authentication (Email Login & Signup)
* Firebase Firestore (Database)
* Supabase Storage (File & Script Storage)

## 🏗️ System Architecture

```text
Flutter Application
       │
       ├── Firebase Authentication
       │       └── User Login & Registration
       │
       ├── Firebase Firestore
       │       ├── User Profiles
       │       ├── Auditions
       │       ├── Applications
       │       └── Shortlisted Candidates
       │
       └── Supabase Storage
               ├── Audition Scripts
               ├── Portfolio Files
               └── Uploaded Documents
```

## ✨ Key Features

* Role-based user experience
* Real-time audition listings
* Cloud-based file management
* Secure user authentication
* Responsive UI design
* Cross-platform support
* Scalable backend architecture

## 📂 Project Structure

```text
lib/
│
├── models/
│   ├── user_model.dart
│   ├── audition_model.dart
│   └── application_model.dart
│
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── supabase_service.dart
│
├── screens/
│   ├── authentication/
│   ├── actor/
│   ├── casting_director/
│   └── common/
│
├── widgets/
│   └── reusable_widgets.dart
│
└── main.dart
```

## 🔥 Firebase Configuration

### Firebase Authentication

Used for:

* User Registration
* User Login
* User Session Management
* Email Authentication

### Firestore Database

Collections:

```text
users
auditions
applications
shortlisted_candidates
```

## ☁️ Supabase Storage

Supabase Storage is used for:

* Audition Scripts (PDF, DOCX)
* Actor Portfolios
* Resume Uploads
* Profile Documents
* Other Media Files

Example Storage Bucket:

```text
audition-files
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  supabase_flutter: ^latest
  file_picker: ^latest
```

## ▶️ Installation

Clone the repository:

```bash
git clone https://github.com/your-username/actor-audition-platform.git
```

Navigate to the project directory:

```bash
cd actor-audition-platform
```

Install dependencies:

```bash
flutter pub get
```

Configure Firebase:

```bash
flutterfire configure
```

Run the application:

```bash
flutter run
```

## 💡 Workflow

### Actor Workflow

1. Register/Login
2. Complete Profile
3. Browse Auditions
4. View Audition Details
5. Upload Portfolio
6. Submit Application

### Casting Director Workflow

1. Register/Login
2. Create Audition
3. Upload Scripts/Documents
4. Receive Applications
5. Review Applicants
6. Shortlist Candidates

## 🎯 Learning Outcomes

This project demonstrates:

* Flutter Application Development
* Firebase Authentication Integration
* Firestore Database Design
* Supabase Storage Integration
* File Upload & Retrieval
* Role-Based Access Control
* CRUD Operations
* Cloud Backend Management
* Responsive UI Development

## 🔮 Future Enhancements

* AI-Based Talent Matching
* Email Notifications
* Application Status Tracking
* Actor Recommendations
* Video Audition Uploads
* In-App Messaging
* Admin Dashboard
* Advanced Search & Filters

## 👨‍💻 Author

**Parth Rastogi**
 | Flutter Developer

### Skills Demonstrated

* Flutter & Dart
* Firebase Authentication
* Firebase Firestore
* Supabase Storage
* REST APIs
* State Management
* Cloud Database Design

## 📜 License

This project is licensed under the MIT License.

---

⭐ If you found this project interesting, consider giving it a star on GitHub
