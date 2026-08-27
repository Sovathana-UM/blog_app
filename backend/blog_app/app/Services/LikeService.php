<?php

namespace App\Services;

use App\Models\Like;
use App\Models\Post;
use App\Models\User;

class LikeService
{
    public function __construct(private FcmNotificationService $fcm) {}

    /**
     * Like a post. Does nothing if already liked.
     * Returns true if a new like was created, false if already liked.
     */
    public function like(Post $post, User $user): bool
    {
        $alreadyLiked = Like::where('post_id', $post->id)
            ->where('user_id', $user->id)
            ->exists();

        if ($alreadyLiked) {
            return false;
        }

        Like::create([
            'post_id' => $post->id,
            'user_id' => $user->id,
        ]);

        if ($post->user_id !== $user->id) {
            $post->user->notifications()->create([
                'sender_id' => $user->id,
                'post_id'   => $post->id,
                'type'      => 'like',
                'message'   => "{$user->first_name} {$user->last_name} liked your post.",
            ]);

            $this->fcm->sendPushNotification(
                $post->user,
                'New Like',
                "{$user->first_name} liked your post.",
                ['post_id' => $post->id, 'type' => 'like']
            );
        }

        return true;
    }

    /**
     * Unlike a post.
     */
    public function unlike(Post $post, User $user): void
    {
        Like::where('post_id', $post->id)
            ->where('user_id', $user->id)
            ->delete();
    }
}
