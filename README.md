# 📱 Feedback Hub — Student & Company Feedback Platform

A production-ready, Clean Architecture **Flutter** application integrated with **Firebase** for collecting, managing, and analyzing feedback from **Students** and **Companies**.

---

## 🌟 Key Features

- **Material 3 Design System**: Modern SaaS aesthetic, HSL blue gradients (`#2563EB` to `#4F46E5`), Google Fonts Inter typography, soft card layouts, and dynamic micro-animations.
- **Global Light & Dark Theme**: Persistent global theme toggle controlled from settings and profile screen, powered by `ThemeProvider` & `SharedPreferences`.
- **Firebase Authentication & Persistent Session**:
  - Email & Password login, sign up with role selection (**Student** or **Company**), password reset.
  - Native Google Sign-In with interactive Role Selection modal for first-time users.
  - Natively managed session persistence via `FirebaseAuth.instance.authStateChanges()`. Users remain logged in across app closure, recent app clear, and phone reboots.
- **Cloud Firestore Database**:
  - Real-time Firestore streams for feedback items.
  - Role-aware CRUD (Users can edit/delete **only** their own feedback).
  - Search by Title, Category, or Submitter Name.
  - Multi-criteria filtering (Category, Role, Status) and sorting (Newest, Oldest, Highest/Lowest Rating).
- **Data Visualization & Analytics Dashboard**:
  - Real-time statistical metrics calculated live from Firestore.
  - Interactive charts built using `fl_chart`: Category Bar Chart, Category Pie Chart, Monthly Line Chart, Rating Distribution Chart, and Weekly Activity Chart.
- **Local Device Profile Photo Storage**:
  - Local directory image saving with integrated 1:1 ratio square cropper (zoom, rotate, move).
  - Real-time avatar updates synced live across all app screens.

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/       # AppColors, AppTypography, AppConstants
│   ├── services/        # Firebase & Local Storage services
│   ├── theme/           # AppTheme (Light & Dark), ThemeProvider
│   ├── utils/           # Validators, DateFormatter
│   └── widgets/         # CustomButton, CustomTextField, RatingWidget, AppAvatar, etc.
├── features/
│   ├── auth/            # AuthRepository, AuthProvider, Splash, Login, SignUp, ForgotPassword
│   ├── dashboard/       # DashboardProvider, HomeDashboard, AnalyticsDashboard (fl_chart)
│   ├── feedback/        # FeedbackRepository, FeedbackProvider, Submit, List, Details, Edit
│   ├── search/          # SearchScreen
│   ├── profile/         # ProfileScreen, EditProfileScreen, ProfileProvider
│   ├── settings/        # SettingsScreen
│   ├── notifications/   # NotificationsScreen
│   └── common/          # MainNavigationScreen, LoadingScreen, ErrorScreen
├── models/              # UserModel, FeedbackModel, NotificationModel
├── firebase_options.dart # DefaultFirebaseOptions configuration
└── main.dart            # MultiProvider & GoRouter entrypoint
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0+)
- Dart SDK (3.0.0+)
- Android Studio / VS Code

### Installation & Run

1. **Clone Repository**:
   ```bash
   git clone https://github.com/yaseenkhan121/Feedback-Review-App.git
   cd Feedback-Review-App
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Application**:
   ```bash
   flutter run
   ```

---

## 📄 License
This project is licensed under the MIT License.
