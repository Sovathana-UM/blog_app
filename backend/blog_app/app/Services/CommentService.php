<?php

namespace App\Services;

use App\Models\Comment;
use App\Models\Post;
use App\Models\User;

class CommentService
{
    public function __construct(private FcmNotificationService $fcm) {}

    /**
     * Create a comment on a post and dispatch notification.
     */
    public function createComment(Post $post, User $user, string $content): Comment
    {
        $comment = $post->comments()->create([
            'user_id' => $user->id,
            'content' => $content,
        ]);

        if ($post->user_id !== $user->id) {
            $post->user->notifications()->create([
                'sender_id' => $user->id,
                'post_id'   => $post->id,
                'type'      => 'comment',
                'message'   => "{$user->first_name} {$user->last_name} commented on your post.",
            ]);

            $this->fcm->sendPushNotification(
                $post->user,
                'New Comment',
                "{$user->first_name} commented on your post.",
                ['post_id' => $post->id, 'type' => 'comment']
            );
        }

        $comment->load('user:id,first_name,last_name,profile_picture');

        return $comment;
    }
}
