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
    
    // Categories
    Route::get('/categories', [CategoryController::class, 'index']);
    
    // Posts
    Route::get('/posts', [PostController::class, 'index']);
    Route::get('/posts/{id}', [PostController::class, 'show']);
    Route::post('/posts', [PostController::class, 'store']);
    Route::put('/posts/{id}', [PostController::class, 'update']);
    Route::delete('/posts/{id}', [PostController::class, 'destroy']);
    
    // Comments
    Route::get('/posts/{id}/comments', [CommentController::class, 'index']);
    Route::post('/comments', [CommentController::class, 'store']);
    Route::delete('/comments/{id}', [CommentController::class, 'destroy']);
    
    // Likes (Extra from MVP but good to keep)
    Route::post('/posts/{id}/like', [LikeController::class, 'toggleLike']);

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
});
