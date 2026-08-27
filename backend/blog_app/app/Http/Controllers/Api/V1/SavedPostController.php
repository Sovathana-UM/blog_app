<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\PostResource;
use App\Models\Post;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class SavedPostController extends Controller
{
    use ApiResponse;

    #[OA\Get(path: "/saved-posts", summary: "Get saved posts", tags: ["Interactions"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "page", in: "query", description: "Page number", required: false, schema: new OA\Schema(type: "integer"))]
    #[OA\Response(response: 200, description: "Saved posts retrieved successfully")]
    public function index(Request $request)
    {
        $user = $request->user();
        
        $posts = $user->savedPosts()
                      ->with(['user:id,first_name,last_name,profile_picture'])
                      ->withCount(['comments', 'likes'])
                      ->latest('saved_posts.created_at')
                      ->paginate(10);
                      
        return $this->success([
            'posts' => PostResource::collection($posts->items()),
            'meta'  => $this->paginationMeta($posts),
        ], 'Saved posts retrieved successfully.');
    }

    #[OA\Post(path: "/posts/{post}/save", summary: "Save a post", tags: ["Interactions"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "post", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Post saved successfully")]
    public function store(Request $request, Post $post)
    {
        $user = $request->user();
        
        if (!$user->savedPosts()->where('post_id', $post->id)->exists()) {
            $user->savedPosts()->attach($post->id);
        }

        return $this->success(null, 'Post saved successfully.');
    }

    #[OA\Delete(path: "/posts/{post}/save", summary: "Unsave a post", tags: ["Interactions"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "post", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Post unsaved successfully")]
    public function destroy(Request $request, Post $post)
    {
        $user = $request->user();
        
        $user->savedPosts()->detach($post->id);

        return $this->success(null, 'Post unsaved successfully.');
    }
}
