<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\PostResource;
use App\Http\Resources\UserResource;
use App\Models\Like;
use App\Models\Post;
use App\Services\LikeService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class LikeController extends Controller
{
    use ApiResponse;

    public function __construct(private LikeService $likeService) {}

    #[OA\Get(path: "/posts/{post}/likes", summary: "Get likes for a post", tags: ["Interactions"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "post", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Parameter(name: "page", in: "query", description: "Page number", required: false, schema: new OA\Schema(type: "integer"))]
    #[OA\Response(response: 200, description: "Likes retrieved successfully")]
    public function index(Post $post)
    {
        $likes = $post->likes()->with('user:id,first_name,last_name,profile_picture')->paginate(10);

        return $this->success([
            'likes' => UserResource::collection($likes->items()),
            'meta'  => $this->paginationMeta($likes),
        ], 'Likes retrieved successfully.');
    }

    #[OA\Post(path: "/posts/{post}/like", summary: "Like a post", tags: ["Interactions"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "post", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Post liked successfully")]
    public function store(Request $request, Post $post)
    {
        $this->likeService->like($post, $request->user());

        return $this->success(null, 'Post liked successfully.');
    }

    #[OA\Delete(path: "/posts/{post}/like", summary: "Unlike a post", tags: ["Interactions"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "post", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Post unliked successfully")]
    public function destroy(Request $request, Post $post)
    {
        $this->likeService->unlike($post, $request->user());

        return $this->success(null, 'Post unliked successfully.');
    }
}
