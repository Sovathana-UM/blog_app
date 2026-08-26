<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Like;
use App\Models\Post;
use App\Http\Resources\UserResource;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class LikeController extends Controller
{
    use ApiResponse;

    #[OA\Get(path: "/posts/{post}/likes", summary: "Get users who liked a post", tags: ["Interactions"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "post", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Parameter(name: "page", in: "query", description: "Page number", required: false, schema: new OA\Schema(type: "integer"))]
    #[OA\Response(response: 200, description: "Users who liked retrieved successfully")]
    public function index(Post $post)
    {
        $likes = $post->likes()->with('user:id,first_name,last_name,profile_picture')
                      ->latest()
                      ->paginate(20);

        $users = $likes->getCollection()->map(fn($like) => $like->user);

        return $this->success([
            'users' => UserResource::collection($users),
            'meta' => [
                'current_page' => $likes->currentPage(),
                'last_page' => $likes->lastPage(),
                'total' => $likes->total(),
            ]
        ], 'Likes retrieved successfully.');
    }

    #[OA\Post(path: "/posts/{post}/like", summary: "Like a post", tags: ["Interactions"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "post", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Post liked successfully")]
    public function store(Request $request, Post $post)
    {
        $userId = $request->user()->id;

        $existingLike = Like::where('post_id', $post->id)
                            ->where('user_id', $userId)
                            ->first();

        if (!$existingLike) {
            Like::create([
                'post_id' => $post->id,
                'user_id' => $userId,
            ]);

            if ($post->user_id !== $userId) {
                $post->user->notifications()->create([
                    'sender_id' => $userId,
                    'post_id' => $post->id,
                    'type' => 'like',
                    'message' => $request->user()->first_name . ' ' . $request->user()->last_name . ' liked your post.',
                ]);

                app(\App\Services\FcmNotificationService::class)->sendPushNotification(
                    $post->user,
                    'New Like',
                    $request->user()->first_name . ' liked your post.',
                    ['post_id' => $post->id, 'type' => 'like']
                );
            }
        }

        return $this->success(null, 'Post liked successfully.');
    }

    #[OA\Delete(path: "/posts/{post}/like", summary: "Unlike a post", tags: ["Interactions"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "post", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Post unliked successfully")]
    public function destroy(Request $request, Post $post)
    {
        $userId = $request->user()->id;

        Like::where('post_id', $post->id)
            ->where('user_id', $userId)
            ->delete();

        return $this->success(null, 'Post unliked successfully.');
    }
}
