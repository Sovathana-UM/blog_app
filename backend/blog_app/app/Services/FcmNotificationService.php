<?php

namespace App\Services;

use App\Models\User;

class FcmNotificationService
{
    /**
     * Note: This is a placeholder for the actual FCM integration.
     * In a production environment, you would use a package like kreait/firebase-php
     * and dispatch a Queue Job to send the notification to Google's servers.
     */
    public function sendPushNotification(User $user, string $title, string $body, array $data = []): void
    {
        if (!$user->fcm_token) {
            return; // User hasn't registered a device
        }

        // TODO: Dispatch a Laravel Job that uses kreait/firebase-php to send the notification.
        // Example: dispatch(new SendFcmJob($user->fcm_token, $title, $body, $data));
    }
}
