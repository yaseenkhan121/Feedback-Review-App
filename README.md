# 🚀 Feedback Hub

<p align="center">
  <h3 align="center">Student & Company Feedback Platform</h3>
  <p align="center">
    A production-ready Flutter application built with Firebase for collecting, managing, and analyzing feedback in real time.
  </p>
</p>

<p align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase&logoColor=black)
![Material3](https://img.shields.io/badge/Material%203-UI-6750A4)
![Provider](https://img.shields.io/badge/Provider-State%20Management-blue)
![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS-success)
![License](https://img.shields.io/badge/License-MIT-green)

</p>

---

# 📖 About

**Feedback Hub** is a modern Flutter application that allows **Students** and **Companies** to submit, manage, and analyze feedback securely using Firebase.

The application follows **Clean Architecture**, uses **Provider** for state management, and integrates **Firebase Authentication**, **Cloud Firestore**, and **Firebase Storage** to provide a secure and scalable experience.

---

# ✨ Features

## 🔐 Authentication

- Email & Password Login
- Google Sign-In
- User Registration
- Forgot Password
- Persistent Login
- Authentication State Listener
- Secure Logout

---

## 👤 Profile

- View Profile
- Edit Profile
- Upload Profile Picture
- Crop Profile Image
- Firebase Storage Integration
- Real-Time Profile Updates

---

## 💬 Feedback Management

- Submit Feedback
- View Feedback
- Edit Own Feedback
- Delete Own Feedback
- Search Feedback
- Filter Feedback
- Sort Feedback
- Real-Time Firestore Updates

---

## 📊 Analytics Dashboard

- Total Feedback
- Average Rating
- Feedback by Category
- Rating Distribution
- Monthly Trends
- Student Feedback Statistics
- Company Feedback Statistics
- Interactive Charts using fl_chart

---

## 🎨 UI / UX

- Material 3
- Responsive Design
- Light & Dark Theme
- Modern Dashboard
- Smooth Animations
- Reusable Widgets
- Clean Architecture

---

# 📱 Screens

- Splash Screen
- Login
- Register
- Forgot Password
- Home Dashboard
- Submit Feedback
- Feedback List
- Feedback Details
- Analytics Dashboard
- Profile
- Settings

---

# 📸 Screenshots

> **Note:** Replace the paths below if you move your images.

## Splash Screen

<p align="center">
<img src="lib/assets/screen%20shorts/image_splash.png" width="250" alt="Splash Screen"/>
</p>

---

## Register Screen

<p align="center">
<img src="lib/assets/screen%20shorts/image_signup.png" width="250" alt="Register Screen"/>
</p>

---

## Home Dashboard

<p align="center">
<img src="lib/assets/screen%20shorts/image_home.png" width="250" alt="Home Dashboard"/>
</p>

---

## Settings Screen

<p align="center">
<img src="lib/assets/screen%20shorts/image_setting.png" width="250" alt="Settings Screen"/>
</p>

---

# 🏗 Project Structure

```text
lib/
│
├── core/
│   ├── constants/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── feedback/
│   └── profile/
│
├── models/
│
├── firebase_options.dart
│
└── main.dart
```

---

# 🛠 Tech Stack

| Technology | Purpose |
|------------|----------|
| Flutter | Cross-platform Development |
| Firebase Authentication | User Authentication |
| Cloud Firestore | Database |
| Firebase Storage | Profile Images |
| Provider | State Management |
| GoRouter | Navigation |
| Material 3 | UI Framework |
| fl_chart | Analytics Charts |

---

# 🔥 Firestore Collections

## users

```text
uid
name
email
role
photoUrl
createdAt
updatedAt
```

## feedbacks

```text
feedbackId
title
description
rating
category
submittedBy
submittedByName
role
status
createdAt
updatedAt
```

---

# ⚙️ Installation

### Clone Repository

```bash
git clone https://github.com/yaseenkhan121/Feedback-Review-App.git
```

### Navigate to Project

```bash
cd Feedback-Review-App
```

### Install Dependencies

```bash
flutter pub get
```

### Configure Firebase

```bash
flutterfire configure
```

### Run Application

```bash
flutter run
```

---

# 🔥 Firebase Setup

Enable the following services:

- Firebase Authentication
- Email & Password Sign-In
- Google Sign-In
- Cloud Firestore
- Firebase Storage

Download:

- `google-services.json`
- `GoogleService-Info.plist`

Place them in the appropriate platform directories before running the app.

---

# 📊 Real-Time Features

- Live Firestore Synchronization
- Automatic Analytics Updates
- Real-Time Dashboard
- Instant Feedback Updates
- Live Search
- Persistent Authentication
- Profile Synchronization

---

# 🔒 Security

- Firebase Authentication
- Firestore Security Rules
- Firebase Storage Rules
- Secure User Sessions
- Users Can Manage Only Their Own Feedback

---

# 📦 Main Dependencies

```yaml
firebase_core
firebase_auth
cloud_firestore
firebase_storage
provider
go_router
fl_chart
image_picker
image_cropper
cached_network_image
```

---

# 🚀 Future Enhancements

- Admin Dashboard
- Push Notifications
- PDF Reports
- Excel Export
- Offline Support
- AI Feedback Insights
- Multi-language Support

---

# 🤝 Contributing

Contributions are welcome!

1. Fork the repository.
2. Create a new feature branch.
3. Commit your changes.
4. Push your branch.
5. Open a Pull Request.

---

# 📄 License

This project is licensed under the **MIT License**.

---

# 👨‍💻 Developer

**Yaseen Khan**

Flutter Developer | Firebase | Mobile Application Development

---

<p align="center">

⭐ **If you found this project helpful, please consider giving it a Star!**

Made with ❤️ using Flutter & Firebase

</p>
