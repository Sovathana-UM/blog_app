# 📱 Flutter + GetX Blog App

A production-style Blog Mobile App built with **Flutter**, **Dart**, **GetX**, **Dio**, and a REST API.

## 🎯 Project Overview

This project implements a mobile blog application with:

- Authentication
- Token-based authorization
- Blog post management
- Image upload
- Comments
- User profile
- Local token storage
- GetX state management
- Form validation
- Loading, empty, success, and error states

The application integrates the provided REST API and follows a layered architecture where UI widgets do not call APIs directly. fileciteturn0file0L2-L16

## ✨ Features

### 🔐 Authentication

#### Register
**Endpoint:** `POST /api/register`

Registration includes:

- Name
- Email
- Password
- Password confirmation
- Form validation
- Loading state
- API error handling
- Navigation to Home after successful registration/login

#### Login
**Endpoint:** `POST /api/login`

The login screen includes:

- Email
- Password
- Login button

After successful login:

1. Save the authentication token locally.
2. Navigate to Home.
3. Add the token to authenticated API requests.

Authorization format:

```http
Authorization: Bearer {token}
```

#### Current User
**Endpoint:** `GET /api/current-user`

The Profile screen displays available information about the logged-in user, such as:

- Name
- Email
- Profile image
- Other available user information

#### Logout
**Endpoint:** `POST /api/logout`

Logout:

- Calls the logout API
- Removes the saved token
- Clears user information
- Navigates back to Login

fileciteturn0file0L17-L60

---

## 📝 Post Management

### Get Posts

**Endpoint:** `GET /api/posts`

The Home screen displays posts with:

- Post image
- Title
- Author/User
- Created date, when available

The application handles:

- Loading state
- Empty state
- Error state
- Pull-to-refresh

fileciteturn0file0L61-L83

### ➕ Create Post

**Endpoint:** `POST /api/posts`

The post creation request uses `multipart/form-data`.

Expected fields:

| Field | Type |
|---|---|
| `image` | File |
| `title` | Text |
| `user_id` | Text |

The Create Post screen provides:

- Gallery image selection
- Image preview
- Post title input
- Submit action
- Upload progress/loading
- Validation error handling
- Post-list refresh after successful creation

fileciteturn0file0L85-L115

### 🗑️ Delete Post

**Endpoint:** `DELETE /api/posts/{id}`

Deleting a post includes:

- Delete button on each post
- Confirmation dialog
- DELETE API request
- Removing the post from the UI after success
- Success/error feedback

fileciteturn0file0L116-L127

### 🖼️ Post Images

The application uses the provided GET IMAGE endpoint to display post images.

It handles:

- API image loading
- Image loading indicators
- Broken image URLs
- Placeholder images when unavailable

fileciteturn0file0L128-L134

---

## 💬 Comments

The application includes a comments section/screen using the provided GET comments endpoint.

Each comment can display:

- User
- Comment content
- Date/time, when available

If the API only provides GET comments, displaying comments is sufficient.

fileciteturn0file0L136-L153

---

## 🏠 Application Screens

### Authentication

- Login
- Register

### Main Application

- Home / Post List
- Create Post
- Post Details
- Comments
- Profile

### User Actions

- Logout
- Delete Post

### Navigation

```text
Login
  │
  ▼
Home
  ├── Post Details
  │     └── Comments
  │
  ├── Create Post
  │
  └── Profile
        └── Logout
```

fileciteturn0file0L154-L180

---

## 🧠 GetX Architecture

The application uses GetX properly for state management, dependency injection, and navigation.

### Controllers

Recommended controllers:

- `AuthController`
- `PostController`
- `CommentController`
- `ProfileController`

### Bindings

Recommended bindings:

- `AuthBinding`
- `PostBinding`
- `CommentBinding`
- `ProfileBinding`

### Routes

Recommended routes:

```text
/login
/register
/home
/posts/create
/posts/:id
/comments
/profile
```

Application logic should not be placed directly inside Widgets.

fileciteturn0file0L181-L206

---

## 📁 Project Structure

```text
lib/
│
├── app/
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── post_model.dart
│   │   │   └── comment_model.dart
│   │   │
│   │   └── providers/
│   │       ├── auth_provider.dart
│   │       ├── post_provider.dart
│   │       └── comment_provider.dart
│   │
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── controllers/
│   │   │   ├── views/
│   │   │   └── bindings/
│   │   │
│   │   ├── posts/
│   │   │   ├── controllers/
│   │   │   ├── views/
│   │   │   └── bindings/
│   │   │
│   │   ├── comments/
│   │   │   ├── controllers/
│   │   │   ├── views/
│   │   │   └── bindings/
│   │   │
│   │   └── profile/
│   │       ├── controllers/
│   │       ├── views/
│   │       └── bindings/
│   │
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   │
│   └── services/
│       └── storage_service.dart
│
└── main.dart
```

fileciteturn0file0L207-L251

---

## ⚙️ API Architecture

API calls should not be made directly from UI widgets.

Recommended data flow:

```text
View
  ↓
Controller
  ↓
Provider / API Service
  ↓
REST API
  ↓
Model
  ↓
Controller
  ↓
View
```

Example controller pattern:

```dart
class PostController extends GetxController {
  final PostProvider provider = Get.find();

  final posts = <PostModel>[].obs;
  final isLoading = false.obs;

  Future<void> getPosts() async {
    isLoading.value = true;

    try {
      final response = await provider.getPosts();

      // Parse response
      // Update posts
    } finally {
      isLoading.value = false;
    }
  }
}
```

fileciteturn0file0L252-L284

---

## 💾 Local Storage

The authentication token should be stored locally using either:

- GetStorage
- SharedPreferences

When the application starts:

```text
Has Token?
   │
   ├── YES → Home
   │
   └── NO  → Login
```

fileciteturn0file0L285-L295

---

## 🎨 UI Requirements

The application should have a production-style UI with:

- Responsive layout
- Consistent colors
- Proper typography
- Loading indicators
- Empty states
- Error states
- Snackbar/Dialog feedback
- Form validation
- Image placeholders
- Confirmation dialogs
- Pull-to-refresh

Avoid relying only on basic default Flutter widgets without styling.

fileciteturn0file0L296-L310

---

## ⭐ Bonus Features

Optional features can provide additional marks:

- ❤️ Like Post
- 🔍 Search Posts
- 📄 Pagination
- 🌓 Dark Mode
- 🔔 Local Notifications
- 📤 Share Post
- 📸 Camera image selection
- Post categories
- ✏️ Edit Post, if supported by the API

fileciteturn0file0L311-L322

---

## 📦 Submission Requirements

### 1. Git Repository

Upload the complete Flutter project to:

- GitHub
- GitLab
- Bitbucket

### 2. README.md

The README should contain:

- Project Name
- Student Name
- Flutter Version
- How to Run
- API Base URL
- Test Account
- Screenshots

### 3. Screenshots

Provide screenshots of:

- Login
- Register
- Home
- Post Details
- Create Post
- Profile
- Comments
- Delete confirmation

### 4. Demo Video

Record a **3–5 minute** demonstration covering:

1. Register
2. Login
3. View current user
4. View posts
5. Create post with image
6. View post
7. View comments
8. Delete post
9. Logout

fileciteturn0file0L323-L357

---

## 📊 Grading

| Category | Score |
|---|---:|
| Login/Register | 15 |
| Token Authentication | 10 |
| Post List | 15 |
| Create Post + Image Upload | 15 |
| Delete Post | 10 |
| Current User/Profile | 10 |
| Comments | 5 |
| GetX Controller & Binding | 10 |
| UI/UX | 5 |
| Code Structure | 5 |
| **Total** | **100** |

**Bonus:** Additional features can earn **+10 points**.

fileciteturn0file0L358-L375

---

## 🚨 Important Rules

1. Must use Flutter + GetX.
2. Must integrate the provided API.
3. Do not hardcode API response data.
4. Do not put API calls directly inside Widgets.
5. Use Models to parse API responses.
6. Use Controllers for application/business logic.
7. Use Bindings for dependency injection.
8. Handle loading, success, empty, and error states.
9. The app must work on Android or iOS.
10. Code should be clean and organized.

fileciteturn0file0L377-L387

---

## 🎯 Expected Result

By completing this project, students should be able to build a small production-style Flutter application covering:

```text
Authentication
      ↓
API Integration
      ↓
GetX State Management
      ↓
CRUD
      ↓
Image Upload
      ↓
Local Storage
      ↓
Navigation
      ↓
Error Handling
```

fileciteturn0file0L388-L392

---

## 👨‍💻 Project Information

> Fill in the following information before submission.

| Information | Details |
|---|---|
| **Project Name** | Flutter + GetX Blog App |
| **Student Name** | `Your Name` |
| **Flutter Version** | `Your Flutter Version` |
| **API Base URL** | `Your API Base URL` |
| **Test Account** | `Your Test Account` |

## ▶️ How to Run

```bash
# Clone the repository
git clone <your-repository-url>

# Enter the project directory
cd <project-directory>

# Install dependencies
flutter pub get

# Run the application
flutter run
```

> Replace the placeholders above with the actual repository URL, project directory, API Base URL, and test account before submission.

## 📸 Screenshots

Add your application screenshots here:

```text
docs/
├── login.png
├── register.png
├── home.png
├── post-details.png
├── create-post.png
├── profile.png
├── comments.png
└── delete-confirmation.png
```

Example:

```markdown
![Login](docs/login.png)
![Register](docs/register.png)
![Home](docs/home.png)
![Post Details](docs/post-details.png)
![Create Post](docs/create-post.png)
![Profile](docs/profile.png)
![Comments](docs/comments.png)
![Delete Confirmation](docs/delete-confirmation.png)
```
