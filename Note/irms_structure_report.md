# IRMS Mobile App (v1) - Folder Structure Report

Based on the directory analysis of `D:\VHT\MobileApp\IRMS_Mobile_App\irms_app_v1`, the project is a **Flutter mobile application** built using the **GetX state management** framework. 

The architecture follows a clean, highly modular **Feature-First (or Domain-Driven)** approach, which is considered a best practice for scaling medium-to-large Flutter applications.

---

## 🏗️ High-Level Project Structure
The root of the project contains standard Flutter platform folders along with custom documentation:
*   `android/` - Android native code and build configurations.
*   `ios/` - iOS native code and Xcode workspace.
*   `web/` - Web platform files.
*   `test/` - Unit and widget tests.
*   `documents/` - Contains project notes (e.g., `AppNote`).
*   `symbols/` - Likely debugging symbols or custom icon sets.
*   **`lib/`** - The main Dart codebase where all application logic lives.

---

## 🧠 The `lib/` Directory (Core Logic)
The `lib` folder is strictly divided into two main areas: **Core** and **Features**.

### 1. `lib/core/` (Shared/Global Resources)
This folder holds everything that is shared across multiple features or handles the global configuration of the app.
*   **`bindings/`** - Global dependency injection (GetX Bindings).
*   **`config/`** - Global app configuration, environment variables.
*   **`constants/`** - Shared constants (strings, dimensions, enums).
*   **`network/`** - API clients (e.g., Dio or Http setup), interceptors, and error handling.
*   **`routes/`** - Route names and page definitions (GetX routing).
*   **`services/`** - Long-running services (e.g., background tasks, local storage, analytics).
*   **`theme/`** - App colors, text styles, and global themes.
*   **`utils/`** - Helper functions, extensions, and formatters.
*   **`widgets/`** - Global, reusable UI components (e.g., custom buttons, text fields).

### 2. `lib/features/` (Domain-Driven Modules)
Each major screen or domain in the app is isolated into its own folder. This makes the app very easy to maintain and scale.

**Available Features:**
1.  **`alarms/`** - Alarm management/monitoring.
2.  **`authentication/`** - Login, Registration, Password resets.
3.  **`dev_log/`** - Developer tools and logging.
4.  **`home/`** - Main dashboard screen.
5.  **`main_navigation/`** - Handles the bottom navigation bar and root layout.
6.  **`map/`** - Geographical mapping and tracking.
7.  **`profile/`** - User profile, nested with `audit_history` and `notification` sub-features.
8.  **`sites/`** - Site management, nested with `devices` and `device_detail` sub-features.
9.  **`users/`** - User management and configuration.

#### Inside a Feature Module
Every feature module independently follows the MVC/GetX pattern, containing its own:
*   `bindings/` - Injects the feature's specific controller and repository.
*   `controller/` - GetX Controller managing state and business logic for this feature.
*   `models/` - Data models (Entities/DTOs) specific to this domain.
*   `repository/` - Data access layer (API calls/local DB) for this domain.
*   `views/` - The main UI screens for this feature.
*   `widgets/` - UI components only used inside this feature.
*   `constants/` & `config/` (Optional) - Constants isolated to this feature.

---

## 🎯 Architecture Summary & Assessment

1.  **Scalability**: Excellent. By splitting code by feature rather than type (e.g., all controllers in one folder), multiple developers can work on different features (like `alarms` vs `sites`) without causing merge conflicts.
2.  **State Management**: It heavily relies on GetX, using `bindings` to manage memory efficiently (lazy loading controllers when routes are pushed).
3.  **Clean Separation of Concerns**: The inclusion of a `repository` layer in every feature means UI (`views`), state (`controller`), and data fetching (`repository`) are completely decoupled.
4.  **Nesting**: Complex domains like `profile` and `sites` correctly utilize nested sub-features (e.g., `sites/devices/device_detail`), preventing giant monolithic features.

**Overall**: This is a highly professional and well-structured GetX application.
