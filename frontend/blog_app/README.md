# Blog App - Flutter Frontend

> A modern, full-featured mobile blogging application built with Flutter, powered by a Laravel REST API backend.

![Flutter](https://img.shields.io/badge/Flutter-3.12.2-02569B?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.12.2-0175C2?style=flat&logo=dart)
![GetX](https://img.shields.io/badge/State-GetX-8A4BFF?style=flat)
![Firebase](https://img.shields.io/badge/Firebase-FCM-FFCA28?style=flat&logo=firebase)
![License](https://img.shields.io/badge/License-Private-red?style=flat)

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Design System](#design-system)
- [Authentication Flow](#authentication-flow)
- [API Routes](#api-routes)
- [Build](#build)

---

## Features

| Feature | Description |
|---|---|
| **Authentication** | Register, Login, logout with persistent JWT token sessions |
| **Home Feed** | Paginated post feed with shimmer loading and pull-to-refresh |
| **Post Details** | Full post view with image gallery, likes, saves, and comments |
| **Create Posts** | Rich post creation with multi-image upload support |
| **Edit / Delete Posts** | Edit post content or permanently delete your own posts |
| **Search** | Full-text search across all published posts |
| **Push Notifications** | Real-time FCM push notifications with in-app notification center |
| **Profile** | View and edit your profile (avatar, bio, location) |
| **My Posts** | Browse and manage all your published posts |
| **Saved Posts** | Access your bookmarked/saved posts collection |
| **Settings** | Change password and manage account options |

---

## Tech Stack

| Package | Version | Purpose |
|---|---|---|
| [flutter](https://flutter.dev) | SDK | Cross-platform mobile framework |
| [get](https://pub.dev/packages/get) | ^4.7.3 | State management, routing & dependency injection |
| [dio](https://pub.dev/packages/dio) | ^5.11.0 | HTTP client with interceptors |
| [firebase_core](https://pub.dev/packages/firebase_core) | ^4.14.0 | Firebase SDK initialization |
| [firebase_messaging](https://pub.dev/packages/firebase_messaging) | ^16.6.0 | Firebase Cloud Messaging (push notifications) |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | ^22.3.0 | Native local notification banners |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | ^2.5.5 | JWT token & session persistence |
| [image_picker](https://pub.dev/packages/image_picker) | ^1.2.3 | Pick images from gallery or camera |
| [cached_network_image](https://pub.dev/packages/cached_network_image) | ^3.4.1 | Efficient remote image loading & caching |
| [shimmer](https://pub.dev/packages/shimmer) | ^4.0.0 | Skeleton loading placeholders |
| [share_plus](https://pub.dev/packages/share_plus) | ^13.3.0 | Native OS share sheet |

---

## Project Structure

The project follows a **Feature-First Architecture** for maximum scalability.

```
lib/
|-- core/                       # App-wide, cross-feature shared code
|   |-- network/                # DioClient (singleton + Bearer token interceptor)
|   |-- routes/                 # GetX route definitions & page bindings
|   |-- services/               # LocalNotificationService (FCM)
|   |-- theme/                  # AppColor & AppTheme (centralized design tokens)
|   |-- utils/                  # DateFormatter & helpers
|   `-- widgets/                # Global reusable UI components
|
|-- features/                   # Domain-driven feature modules
|   |-- auth/                   # Login, Register, Change Password
|   |-- home/                   # Home feed & post card widgets
|   |-- notifications/          # Notification list & badge management
|   |-- post/                   # Create, View, Edit, Delete post & Comments
|   |-- profile/                # Profile, Edit profile, My Posts, Saved Posts
|   |-- root/                   # Bottom navigation shell (tab bar)
|   |-- search/                 # Search screen
|   `-- settings/               # Settings screen
|
`-- main.dart                   # App entry point & Firebase initialization
```

Each feature follows a consistent internal structure:

```
feature/
|-- bindings/       # GetX lazy dependency injection
|-- controller/     # Business logic & reactive state (GetxController)
|-- models/         # Dart data models with JSON serialization
|-- repository/     # Data access layer - API calls via DioClient
|-- views/          # Full screens / pages
`-- widgets/        # UI components used only within this feature
```

---

## Getting Started

### Prerequisites

- **Flutter SDK** `^3.12.2`
- **Dart SDK** `^3.12.2`
- Android Studio (for Android) or Xcode (for iOS)
- A running instance of the [Blog App Laravel Backend](../backend/README.md)

### 1. Install Dependencies

```bash
cd frontend/blog_app
flutter pub get
```

### 2. Configure the API Base URL

Open `lib/core/network/dio_client.dart` and update `baseUrl`:

```dart
// Physical device: use your machine's local network IP address
String baseUrl = 'http://<YOUR_LOCAL_IP>:8000/api';

// Android Emulator:
// String baseUrl = 'http://10.0.2.2:8000/api';

// iOS Simulator:
// String baseUrl = 'http://localhost:8000/api';
```

### 3. Configure Firebase

1. Create a project at [Firebase Console](https://console.firebase.google.com)
2. Add an **Android** and/or **iOS** app to the project
3. Download `google-services.json` and place it in `android/app/`
4. Replace `lib/firebase_options.dart` with your project's generated file:
   ```bash
   flutterfire configure
   ```

### 4. Run the App

```bash
flutter run
```

---

## Design System

All colors are centralized in `lib/core/theme/app_color.dart`.

> **Rule:** Never use hardcoded `Color(0xFF...)` hex values directly in UI code. Always use `AppColor.*` tokens.

### Color Tokens

| Token | Hex | Usage |
|---|---|---|
| `AppColor.primary` | `#2E6FF2` | Primary buttons, active states, links |
| `AppColor.background` | `#F9FAFB` | Screen & scaffold backgrounds |
| `AppColor.textPrimary` | `#1F2937` | Headings and primary text |
| `AppColor.textSecondary` | `#6B7280` | Subtitles, captions, body text |
| `AppColor.textHint` | `#9CA3AF` | Input placeholders |
| `AppColor.borderLight` | `#F3F4F6` | Card borders, dividers |
| `AppColor.borderMedium` | `#E5E7EB` | Input field borders |
| `AppColor.error` | `#DC2626` | Error states, destructive actions |
| `AppColor.errorBg` | `#FEE2E2` | Error icon backgrounds |
| `AppColor.success` | `#16A34A` | Success messages |
| `AppColor.warning` | `#D97706` | Warning states |
| `AppColor.gradientStart` | `#5384F5` | Profile header gradient start |
| `AppColor.gradientEnd` | `#3F69F3` | Profile header gradient end |

---

## API Routes

> Base URL: `http://<YOUR_IP>:8000/api` (configured in `DioClient`)

### Authentication

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/auth/login` | Login with email & password |
| `POST` | `/auth/register` | Create a new account |
| `POST` | `/auth/logout` | Logout and invalidate token |

### Current User (Profile)

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/current-user` | Get authenticated user's profile |
| `PUT` | `/current-user` | Update profile fields (JSON) |
| `POST` | `/current-user` | Update profile including avatar (multipart) |
| `PUT` | `/current-user/password` | Change account password |
| `POST` | `/current-user/avatar` | Upload a new avatar image |
| `POST` | `/current-user/fcm-token` | Register device push token |
| `DELETE` | `/current-user/fcm-token` | Remove push token on logout |

### Posts

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/posts?page={n}` | Paginated public post feed |
| `GET` | `/posts/{id}` | Get a single post by ID |
| `POST` | `/posts` | Create a new post (multipart/form-data) |
| `PUT` | `/posts/{id}` | Update post content |
| `DELETE` | `/posts/{id}` | Delete a post |
| `GET` | `/posts/my-posts?page={n}` | Get the authenticated user's posts |
| `GET` | `/posts/search?query={q}` | Full-text search posts |

### Likes & Saves

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/posts/{id}/like` | Like a post |
| `DELETE` | `/posts/{id}/like` | Unlike a post |
| `POST` | `/posts/{id}/save` | Save / bookmark a post |
| `DELETE` | `/posts/{id}/save` | Remove a saved post |
| `GET` | `/saved-posts` | Get all saved posts |

### Shares

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/posts/{id}/share` | Share a post (optionally with a message) |

### Comments

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/posts/{id}/comments` | Get all comments on a post |
| `POST` | `/posts/{id}/comments` | Add a comment to a post |

### Notifications

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/notifications?page={n}` | Get paginated notifications |
| `PATCH` | `/notifications/{id}/read` | Mark a notification as read |
| `PATCH` | `/notifications/read-all` | Mark all notifications as read |

---

## Build

```bash
# Debug build
flutter run

# Release APK (Android)
flutter build apk --release

```

## 👤 Author

**Sovathana UM**

