<p align="center">
  <h1 align="center">🚀 Blogify API</h1>
  <p align="center">A production-ready RESTful API for a social blogging platform built with Laravel 12 and Sanctum.</p>
  <p align="center">
    <img src="https://img.shields.io/badge/Laravel-12-FF2D20?style=for-the-badge&logo=laravel&logoColor=white" />
    <img src="https://img.shields.io/badge/PHP-8.2+-777BB4?style=for-the-badge&logo=php&logoColor=white" />
    <img src="https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
    <img src="https://img.shields.io/badge/Sanctum-Auth-orange?style=for-the-badge" />
    <img src="https://img.shields.io/badge/Firebase-FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  </p>
</p>

---

## 📖 Project Overview

**Blogify API** is the backend for a full-featured social blogging mobile application. It exposes a versioned RESTful JSON API consumed by a [Flutter client](https://flutter.dev) using [GetX](https://pub.dev/packages/get) and [Dio](https://pub.dev/packages/dio).

The API supports complete user authentication, rich post management (create, edit, delete, share), social interactions (likes, comments, saves), real-time push notifications via Firebase Cloud Messaging (FCM), and online presence tracking.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **Authentication** | Register, Login, Logout with Sanctum Bearer Tokens |
| 👤 **Profile Management** | Update profile info, upload avatar, change password |
| 📝 **Posts (CRUD)** | Create, read, update, delete posts with image uploads |
| 🔁 **Share Posts** | Share any post to your own feed with an optional comment |
| 💬 **Comments** | Comment on posts, edit and delete your own comments |
| ❤️ **Likes** | Like and unlike posts |
| 🔖 **Saved Posts** | Bookmark posts and view your personal saved list |
| 🔍 **Search** | Full-text search across post titles and content |
| 🔔 **Notifications** | In-app notification feed with unread count |
| 📲 **FCM Push Notifications** | Real-time push notifications via Firebase Cloud Messaging |
| 🟢 **Online Presence** | Track if users are currently online via cache |
| 🛡️ **Policies & Authorization** | Gate/Policy-based access control on all protected actions |
| 🚦 **Rate Limiting** | Brute-force protection on authentication endpoints |

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Laravel 12 |
| **PHP** | PHP 8.2+ |
| **Authentication** | Laravel Sanctum |
| **Database** | MySQL 8.0 |
| **Push Notifications** | Firebase Cloud Messaging (via `kreait/laravel-firebase`) |
| **API Docs** | OpenAPI 3.0 (via `darkaonline/l5-swagger`) |
| **Storage** | Local disk (S3-ready) |
| **Queue** | Database Queue (Redis-ready) |
| **Cache** | Database (Redis-ready) |
| **Mobile Client** | Flutter + GetX + Dio |

---

## ⚙️ Installation

### Prerequisites

- PHP 8.2+
- Composer 2+
- MySQL 8.0+
- A Firebase project with a service account JSON

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/blogify-api.git
cd blogify-api
```

### 2. Install PHP Dependencies

```bash
composer install
```

### 3. Configure Environment

```bash
cp .env.example .env
php artisan key:generate
```

Open `.env` and configure your **database credentials** and **application URL**:

```env
APP_URL=http://your-server-ip:8000
DB_DATABASE=blog_app_db
DB_USERNAME=root
DB_PASSWORD=your_password
```

### 4. Firebase Setup

1. Go to your [Firebase Console](https://console.firebase.google.com)
2. Navigate to **Project Settings → Service Accounts**
3. Click **Generate new private key** → download the JSON file
4. Save it to `storage/app/firebase_credentials.json`
5. Ensure `FIREBASE_CREDENTIALS=storage/app/firebase_credentials.json` is set in `.env`

> ⚠️ **Never commit this file to Git.** It is already excluded in `.gitignore`.

### 5. Run Migrations

```bash
php artisan migrate
```

### 6. Link Storage

```bash
php artisan storage:link
```

This creates the `public/storage` symlink so uploaded images (avatars, post images) are publicly accessible.

### 7. Start the Development Server

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

---

## 🔑 Environment Variables

Refer to [`.env.example`](./.env.example) for a full reference of all available configuration options.

Key variables:

| Variable | Description |
|---|---|
| `APP_URL` | The base URL of the server. Must be network-accessible to the Flutter client. |
| `DB_*` | Your MySQL connection details. |
| `FIREBASE_CREDENTIALS` | Path to your Firebase service account JSON file. |
| `QUEUE_CONNECTION` | `database` for development, `redis` recommended for production. |
| `CACHE_STORE` | `database` for development, `redis` recommended for production. |

---

## 📡 API Documentation

### Base URL

```
http://your-server:8000/api
```

### Authentication

All protected routes require a Bearer token in the `Authorization` header:

```
Authorization: Bearer <your_sanctum_token>
```

Obtain a token by calling `POST /api/auth/login` or `POST /api/auth/register`.

---

### Endpoints

#### 🔐 Auth

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/api/auth/register` | No | Register a new user |
| `POST` | `/api/auth/login` | No | Login and get a token |
| `POST` | `/api/auth/logout` | ✅ | Invalidate current token |

#### 👤 Profile

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/current-user` | ✅ | Get current user profile |
| `PUT/POST` | `/api/current-user` | ✅ | Update profile info |
| `POST` | `/api/current-user/avatar` | ✅ | Upload profile picture |
| `PUT` | `/api/current-user/password` | ✅ | Change password |
| `POST` | `/api/current-user/fcm-token` | ✅ | Register FCM device token |
| `DELETE` | `/api/current-user/fcm-token` | ✅ | Remove FCM device token |

#### 📝 Posts

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/posts` | ✅ | Get paginated feed |
| `POST` | `/api/posts` | ✅ | Create a new post |
| `GET` | `/api/posts/{id}` | ✅ | Get a single post |
| `PUT/PATCH` | `/api/posts/{id}` | ✅ | Update a post (owner only) |
| `DELETE` | `/api/posts/{id}` | ✅ | Delete a post (owner only) |
| `GET` | `/api/posts/my-posts` | ✅ | Get current user's posts |
| `GET` | `/api/posts/search?q=...` | ✅ | Search posts by keyword |
| `POST` | `/api/posts/{id}/share` | ✅ | Share a post to your feed |

#### 💬 Comments

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/posts/{id}/comments` | ✅ | Get comments for a post |
| `POST` | `/api/posts/{id}/comments` | ✅ | Add a comment |
| `PUT` | `/api/comments/{id}` | ✅ | Edit a comment (owner only) |
| `DELETE` | `/api/comments/{id}` | ✅ | Delete a comment (owner or post owner) |

#### ❤️ Likes

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/posts/{id}/likes` | ✅ | Get users who liked a post |
| `POST` | `/api/posts/{id}/like` | ✅ | Like a post |
| `DELETE` | `/api/posts/{id}/like` | ✅ | Unlike a post |

#### 🔖 Saved Posts

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/saved-posts` | ✅ | Get saved posts list |
| `POST` | `/api/posts/{id}/save` | ✅ | Save a post |
| `DELETE` | `/api/posts/{id}/save` | ✅ | Unsave a post |

#### 🔔 Notifications

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/notifications` | ✅ | Get notification feed |
| `GET` | `/api/notifications/unread-count` | ✅ | Get unread count |
| `PATCH` | `/api/notifications/{id}/read` | ✅ | Mark a notification as read |
| `PATCH` | `/api/notifications/read-all` | ✅ | Mark all as read |

#### 🛠️ System

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/health` | No | Health check |
| `GET` | `/api/docs` | No | Swagger API documentation UI |

---

## 📁 Folder Structure

```
app/
├── Http/
│   ├── Controllers/Api/V1/    # Thin API controllers (route → service)
│   ├── Requests/              # Form Requests for validation
│   ├── Resources/             # API response transformers
│   └── Middleware/            # UpdateUserActivity (online tracking)
├── Models/                    # Eloquent models with UUIDs + soft deletes
├── Policies/                  # Authorization policies (Post, Comment, Notification)
├── Services/                  # Business logic layer
│   ├── AuthService.php
│   ├── PostService.php        # Post CRUD + share
│   ├── ProfileService.php     # Profile update + password change
│   ├── LikeService.php        # Like/unlike + notifications
│   ├── CommentService.php     # Comments + notifications
│   └── FcmNotificationService.php  # Firebase push
├── Traits/
│   └── ApiResponse.php        # Consistent JSON response helpers
└── Providers/
    └── AppServiceProvider.php  # Rate limiter registration
database/
├── migrations/                # All database migrations
routes/
└── api.php                    # All API routes (versioned under /api)
```

---

## 🧑‍💻 Development Setup

```bash
# Install dependencies
composer install

# Copy and configure environment
cp .env.example .env
php artisan key:generate

# Set up the database
php artisan migrate

# Link public storage
php artisan storage:link

# Start local server
php artisan serve --host=0.0.0.0 --port=8000

# (Optional) Run queue worker
php artisan queue:work
```

---

## 🚀 Deployment Notes

Before deploying to production:

1. **Set production environment values in `.env`:**
   ```env
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=https://your-production-domain.com
   LOG_LEVEL=error
   ```

2. **Optimize the application:**
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   php artisan optimize
   ```

3. **Run migrations:**
   ```bash
   php artisan migrate --force
   ```

4. **Set up a process manager** (Supervisor) for the queue worker:
   ```bash
   php artisan queue:work --tries=3 --timeout=90
   ```

5. **Consider upgrading to Redis** for cache and queue in production for better performance.

6. **Place Firebase credentials** at `storage/app/firebase_credentials.json` on the server (via CI/CD secrets — never commit it).

---

## 👤 Author

**Sovathana UM**

