<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\PostController;
use App\Http\Controllers\Api\V1\CommentController;
use App\Http\Controllers\Api\V1\LikeController;

use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\SavedPostController;

    // Health Check
    Route::get('health', function () {
        return response()->json(['status' => 'ok']);
    });

    // Auth
    Route::middleware('throttle:auth')->group(function () {
        Route::post('auth/register', [AuthController::class, 'register']);
        Route::post('auth/login', [AuthController::class, 'login']);
    });

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout']);
        
        // Profile
        Route::get('current-user', [ProfileController::class, 'show']);
        Route::match(['put', 'post'], 'current-user', [ProfileController::class, 'update']);
        Route::post('current-user/avatar', [ProfileController::class, 'uploadAvatar']);
        Route::put('current-user/password', [ProfileController::class, 'changePassword']);
        Route::post('current-user/fcm-token', [ProfileController::class, 'updateFcmToken']);
        Route::delete('current-user/fcm-token', [ProfileController::class, 'removeFcmToken']);
        


        // Posts
        Route::get('posts/my-posts', [PostController::class, 'myPosts']);
        Route::get('posts/search', [PostController::class, 'search']);
        Route::apiResource('posts', PostController::class);
        
        // Post Interactions (Like)
        Route::get('posts/{post}/likes', [LikeController::class, 'index']);
        Route::post('posts/{post}/like', [LikeController::class, 'store']);
        Route::delete('posts/{post}/like', [LikeController::class, 'destroy']);
        
        // Post Interactions (Share)
        Route::post('posts/{post}/share', [PostController::class, 'share']);
        
        // Post Interactions (Save)
        Route::post('posts/{post}/save', [SavedPostController::class, 'store']);
        Route::delete('posts/{post}/save', [SavedPostController::class, 'destroy']);
        
        // Saved Posts (Listing)
        Route::get('saved-posts', [SavedPostController::class, 'index']);

        // Comments (Nested Resource)
        Route::apiResource('posts.comments', CommentController::class)->only(['index', 'store']);
        Route::apiResource('comments', CommentController::class)->only(['update', 'destroy']);

        // Notifications
        Route::get('notifications', [NotificationController::class, 'index']);
        Route::get('notifications/unread-count', [NotificationController::class, 'unreadCount']);
        Route::patch('notifications/{notification}/read', [NotificationController::class, 'markAsRead']);
        Route::patch('notifications/read-all', [NotificationController::class, 'markAllAsRead']);
    });
