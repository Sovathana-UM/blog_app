<?php

namespace App\Http\Controllers;

use App\Models\Post;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class SavedPostController extends Controller
{
    #[OA\Get(path: "/saved-posts", summary: "Get all saved posts for the current user", tags: ["Saved Posts"], security: [["bearerAuth" => []]])]
    #[OA\Response(response: 200, description: "List of saved posts")]
    public function index(Request $request)
    {
        $savedPosts = $request->user()->savedPosts()->with(['user', 'category', 'comments.user'])->withCount(['comments', 'likes'])->latest()->get();
        return $this->formatResponse(true, 'Saved posts retrieved successfully', 200, $savedPosts);
    }

    #[OA\Post(path: "/posts/{id}/save", summary: "Save a post", tags: ["Saved Posts"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Post saved successfully")]
    #[OA\Response(response: 404, description: "Post not found")]
    public function store(Request $request, $id)
    {
        $post = Post::find($id);

        if (!$post) {
            return $this->formatResponse(false, 'Post not found', 404);
        }

        $request->user()->savedPosts()->syncWithoutDetaching([$id]);

        return $this->formatResponse(true, 'Post saved successfully', 200);
    }

    #[OA\Delete(path: "/posts/{id}/save", summary: "Unsave a post", tags: ["Saved Posts"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Post unsaved successfully")]
    #[OA\Response(response: 404, description: "Post not found")]
    public function destroy(Request $request, $id)
    {
        $post = Post::find($id);

        if (!$post) {
            return $this->formatResponse(false, 'Post not found', 404);
        }

        $request->user()->savedPosts()->detach($id);

        return $this->formatResponse(true, 'Post unsaved successfully', 200);
    }
}
