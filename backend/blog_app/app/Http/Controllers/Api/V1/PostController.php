<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StorePostRequest;
use App\Http\Requests\UpdatePostRequest;
use App\Http\Resources\PostResource;
use App\Models\Post;
use App\Services\PostService;
use App\Traits\ApiResponse;
use Illuminate\Support\Facades\Gate;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class PostController extends Controller
{
    use ApiResponse;

    public function __construct(private PostService $postService)
    {
    }

    #[OA\Get(path: "/posts", summary: "Get paginated list of posts", tags: ["Posts"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "page", in: "query", description: "Page number", required: false, schema: new OA\Schema(type: "integer"))]
    #[OA\Response(response: 200, description: "Posts retrieved successfully")]
    public function index(Request $request)
    {
        $posts = Post::with(['user:id,first_name,last_name,profile_picture'])
            ->withCount(['comments', 'likes'])
            ->latest()
            ->paginate(15);
            
        return $this->success([
            'posts' => PostResource::collection($posts->items()),
            'meta' => [
                'current_page' => $posts->currentPage(),
                'last_page' => $posts->lastPage(),
                'total' => $posts->total(),
            ]
        ], 'Posts retrieved successfully.');
    }

    #[OA\Post(path: "/posts", summary: "Create a new post", tags: ["Posts"], security: [["bearerAuth" => []]])]
    #[OA\RequestBody(required: true, content: new OA\MediaType(
        mediaType: "multipart/form-data",
        schema: new OA\Schema(
            required: ["title", "content"],
            properties: [
                new OA\Property(property: "title", type: "string"),
                new OA\Property(property: "content", type: "string"),
                new OA\Property(property: "images[]", type: "array", items: new OA\Items(type: "string", format: "binary"))
            ]
        )
    ))]
    #[OA\Response(response: 201, description: "Post created successfully")]
    public function store(StorePostRequest $request)
    {
        $post = $this->postService->createPost($request->validated(), $request->user()->id);
        
        $post->load(['user:id,first_name,last_name,profile_picture']);
        
        return $this->success(new PostResource($post), 'Post created successfully.', 201);
    }

    #[OA\Get(path: "/posts/{post}", summary: "Get a specific post", tags: ["Posts"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "post", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Post retrieved successfully")]
    public function show(Post $post)
    {
        $post->load(['user:id,first_name,last_name,profile_picture'])
             ->loadCount(['comments', 'likes']);

        return $this->success(new PostResource($post), 'Post retrieved successfully.');
    }

    #[OA\Put(path: "/posts/{post}", summary: "Update an existing post", tags: ["Posts"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "post", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\RequestBody(required: true, content: new OA\JsonContent(
        properties: [
            new OA\Property(property: "title", type: "string"),
            new OA\Property(property: "content", type: "string")
        ]
    ))]
    #[OA\Response(response: 200, description: "Post updated successfully")]
    public function update(UpdatePostRequest $request, Post $post)
    {
        Gate::authorize('update', $post);

        $updatedPost = $this->postService->updatePost($post, $request->validated());
        
        $updatedPost->load(['user:id,first_name,last_name,profile_picture'])
                    ->loadCount(['comments', 'likes']);

        return $this->success(new PostResource($updatedPost), 'Post updated successfully.');
    }

    #[OA\Delete(path: "/posts/{post}", summary: "Delete a post", tags: ["Posts"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "post", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Post deleted successfully")]
    public function destroy(Post $post)
    {
        Gate::authorize('delete', $post);

        $this->postService->deletePost($post);

        return $this->success(null, 'Post deleted successfully.');
    }

    #[OA\Get(path: "/posts/my-posts", summary: "Get current user's posts", tags: ["Posts"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "page", in: "query", description: "Page number", required: false, schema: new OA\Schema(type: "integer"))]
    #[OA\Response(response: 200, description: "My posts retrieved successfully")]
    public function myPosts(Request $request)
    {
        $posts = Post::withCount(['comments', 'likes'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate(15);
            
        return $this->success([
            'posts' => PostResource::collection($posts->items()),
            'meta' => [
                'current_page' => $posts->currentPage(),
                'last_page' => $posts->lastPage(),
                'total' => $posts->total(),
            ]
        ], 'My posts retrieved successfully.');
    }

    #[OA\Get(path: "/posts/search", summary: "Search posts by query", tags: ["Posts"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "q", in: "query", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Parameter(name: "page", in: "query", description: "Page number", required: false, schema: new OA\Schema(type: "integer"))]
    #[OA\Response(response: 200, description: "Search results retrieved successfully")]
    public function search(Request $request)
    {
        $query = $request->query('q');

        if (!$query) {
            return $this->error('Search query parameter "q" is required', null, 400);
        }

        $posts = Post::with(['user:id,first_name,last_name,profile_picture'])
            ->withCount(['comments', 'likes'])
            ->where('title', 'like', "%{$query}%")
            ->orWhere('content', 'like', "%{$query}%")
            ->latest()
            ->paginate(15);
            
        return $this->success([
            'posts' => PostResource::collection($posts->items()),
            'meta' => [
                'current_page' => $posts->currentPage(),
                'last_page' => $posts->lastPage(),
                'total' => $posts->total(),
            ]
        ], 'Search results retrieved successfully.');
    }
}
