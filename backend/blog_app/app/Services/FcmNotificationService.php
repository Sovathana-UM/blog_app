<?php

namespace App\Services;

use App\Models\User;

use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class FcmNotificationService
{
    public function __construct(protected Messaging $messaging)
    {
    }

    public function sendPushNotification(User $user, string $title, string $body, array $data = []): void
    {
        if (!$user->fcm_token) {
            return;
        }

        try {
            $message = CloudMessage::withTarget('token', $user->fcm_token)
                ->withNotification(Notification::create($title, $body))
                ->withData($data);

            $this->messaging->send($message);
        } catch (\Exception $e) {
            // Log the error but don't fail the request
            \Log::error('FCM Error: ' . $e->getMessage());
        }
    }
}
