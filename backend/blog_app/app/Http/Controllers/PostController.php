<?php

namespace App\Http\Controllers;

use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;
use OpenApi\Attributes as OA;

class PostController extends Controller
{
    #[OA\Get(path: "/posts", summary: "Get all posts", tags: ["Posts"], security: [["bearerAuth" => []]])]
    #[OA\Response(
        response: 200, 
        description: "List of posts",
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: "success", type: "boolean", example: true),
                new OA\Property(property: "message", type: "string", example: "Posts retrieved successfully"),
                new OA\Property(property: "statusCode", type: "integer", example: 200),
                new OA\Property(property: "data", type: "array", items: new OA\Items(type: "object"))
            ]
        )
    )]
    public function index(Request $request)
    {
        $query = Post::with(['user', 'comments.user'])->withCount(['comments', 'likes'])->latest();
        
        if ($request->has('user_id')) {
            $query->where('user_id', $request->input('user_id'));
        }

        $posts = $query->get();
        return $this->formatResponse(true, 'Posts retrieved successfully', 200, $posts);
    }

    #[OA\Post(path: "/posts", summary: "Create a new post", tags: ["Posts"], security: [["bearerAuth" => []]])]
    #[OA\RequestBody(
        required: true,
        content: new OA\MediaType(
            mediaType: "multipart/form-data",
            schema: new OA\Schema(
                required: ["image"],
                properties: [
                    new OA\Property(property: "title", type: "string", example: "My new post!"),
                    new OA\Property(property: "image", type: "string", format: "binary")
                ]
            )
        )
    )]
    #[OA\Response(response: 201, description: "Post created successfully")]
    #[OA\Response(response: 422, description: "Validation error")]
    public function store(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'title' => 'nullable|string|max:255',
                'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:5120',
            ]);

            $imagePath = $request->file('image')->store('posts', 'public');

            $post = Post::create([
                'user_id' => $request->user()->id,
                'title' => $validatedData['title'] ?? null,
                'image' => $imagePath,
            ]);

            return $this->formatResponse(true, 'Post created successfully', 201, $post);
        } catch (ValidationException $e) {
            return $this->formatResponse(false, 'Validation error', 422, $e->errors());
        } catch (\Exception $e) {
            return $this->formatResponse(false, 'Failed to create post', 500, ['error' => $e->getMessage()]);
        }
    }

    #[OA\Delete(path: "/posts/{id}", summary: "Delete a post", tags: ["Posts"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Post deleted successfully")]
    #[OA\Response(response: 403, description: "Unauthorized to delete this post")]
    #[OA\Response(response: 404, description: "Post not found")]
    public function destroy(Request $request, $id)
    {
        $post = Post::find($id);

        if (!$post) {
            return $this->formatResponse(false, 'Post not found', 404);
        }

        if ($post->user_id !== $request->user()->id) {
            return $this->formatResponse(false, 'Unauthorized to delete this post', 403);
        }

        if ($post->image) {
            Storage::disk('public')->delete($post->image);
        }

        $post->delete();

        return $this->formatResponse(true, 'Post deleted successfully', 200);
    }
}
