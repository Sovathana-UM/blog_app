<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\CommentController;
use App\Http\Controllers\LikeController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\SavedPostController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Fallback route for unauthenticated API requests to prevent RouteNotFoundException
Route::get('/login', function () {
    return response()->json(['message' => 'Unauthenticated.'], 401);
})->name('login');

Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    // Profile & User
    Route::get('/current-user', [UserController::class, 'getUser']);
    Route::get('/profile', [UserController::class, 'getUser']);
    Route::put('/profile', [UserController::class, 'updateProfile']);
    Route::post('/profile/avatar', [UserController::class, 'uploadAvatar']);
    Route::post('/user/update-email', [UserController::class, 'updateEmail']); // keeping this extra one
    Route::put('/change-password', [UserController::class, 'changePassword']);
    Route::post('/user/fcm-token', [UserController::class, 'updateFcmToken']);

    // Categories
    Route::get('/categories', [CategoryController::class, 'index']);

    // Posts
    Route::get('/posts', [PostController::class, 'index']);
    Route::get('/my-posts', [PostController::class, 'myPosts']);
    Route::get('/posts/{id}', [PostController::class, 'show']);
    Route::post('/posts', [PostController::class, 'store']);
    Route::put('/posts/{id}', [PostController::class, 'update']);
    Route::delete('/posts/{id}', [PostController::class, 'destroy']);

    // Saved Posts
    Route::get('/saved-posts', [SavedPostController::class, 'index']);
    Route::post('/posts/{id}/save', [SavedPostController::class, 'store']);
    Route::delete('/posts/{id}/save', [SavedPostController::class, 'destroy']);

    // Search
    Route::get('/search/posts', [PostController::class, 'search']);

    // Comments
    Route::get('/posts/{id}/comments', [CommentController::class, 'index']);
    Route::post('/comments', [CommentController::class, 'store']);
    Route::put('/comments/{id}', [CommentController::class, 'update']);
    Route::delete('/comments/{id}', [CommentController::class, 'destroy']);

    // Likes (Extra from MVP but good to keep)
    Route::post('/posts/{id}/like', [LikeController::class, 'toggleLike']);

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
});
