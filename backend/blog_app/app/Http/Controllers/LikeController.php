<?php

namespace App\Http\Controllers;

use App\Models\Like;
use App\Models\Post;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class LikeController extends Controller
{
    #[OA\Post(path: "/posts/{id}/like", summary: "Toggle like on a post", tags: ["Likes"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Like toggled successfully")]
    #[OA\Response(response: 404, description: "Post not found")]
    public function toggleLike(Request $request, $id)
    {
        $post = Post::find($id);

        if (!$post) {
            return $this->formatResponse(false, 'Post not found', 404);
        }

        $userId = $request->user()->id;
        $like = Like::where('post_id', $post->id)->where('user_id', $userId)->first();

        if ($like) {
            // Unlike
            $like->delete();
            return $this->formatResponse(true, 'Post unliked', 200);
        } else {
            // Like
            Like::create([
                'post_id' => $post->id,
                'user_id' => $userId,
            ]);

            // Notify post owner
            if ($post->user_id !== $userId) {
                $post->user->notify(new \App\Notifications\PushNotification(
                    'New Like',
                    $request->user()->name . ' liked your post.'
                ));
            }

            return $this->formatResponse(true, 'Post liked', 201);
        }
    }
}
