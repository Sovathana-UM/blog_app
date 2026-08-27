<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCommentRequest;
use App\Http\Resources\CommentResource;
use App\Models\Comment;
use App\Models\Post;
use App\Services\CommentService;
use App\Traits\ApiResponse;
use Illuminate\Support\Facades\Gate;
use OpenApi\Attributes as OA;

class CommentController extends Controller
{
    use ApiResponse;

    public function __construct(private CommentService $commentService) {}

    #[OA\Get(path: "/posts/{post}/comments", summary: "Get comments for a post", tags: ["Comments"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "post", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Parameter(name: "page", in: "query", description: "Page number", required: false, schema: new OA\Schema(type: "integer"))]
    #[OA\Response(response: 200, description: "Comments retrieved successfully")]
    public function index(Post $post)
    {
        $comments = $post->comments()
            ->with('user:id,first_name,last_name,profile_picture')
            ->latest()
            ->paginate(10);

        return $this->success([
            'comments' => CommentResource::collection($comments->items()),
            'meta'     => $this->paginationMeta($comments),
        ], 'Comments retrieved successfully.');
    }

    #[OA\Post(path: "/posts/{post}/comments", summary: "Add a comment to a post", tags: ["Comments"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "post", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\RequestBody(required: true, content: new OA\JsonContent(
        required: ["content"],
        properties: [new OA\Property(property: "content", type: "string")]
    ))]
    #[OA\Response(response: 201, description: "Comment added successfully")]
    public function store(StoreCommentRequest $request, Post $post)
    {
        $comment = $this->commentService->createComment(
            $post,
            $request->user(),
            $request->validated('content')
        );

        return $this->success(new CommentResource($comment), 'Comment added successfully.', 201);
    }

    #[OA\Put(path: "/comments/{comment}", summary: "Update a comment", tags: ["Comments"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "comment", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\RequestBody(required: true, content: new OA\JsonContent(
        required: ["content"],
        properties: [new OA\Property(property: "content", type: "string")]
    ))]
    #[OA\Response(response: 200, description: "Comment updated successfully")]
    public function update(StoreCommentRequest $request, Comment $comment)
    {
        Gate::authorize('update', $comment);

        $comment->update(['content' => $request->validated('content')]);
        $comment->load('user:id,first_name,last_name,profile_picture');

        return $this->success(new CommentResource($comment), 'Comment updated successfully.');
    }

    #[OA\Delete(path: "/comments/{comment}", summary: "Delete a comment", tags: ["Comments"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "comment", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Comment deleted successfully")]
    public function destroy(Comment $comment)
    {
        Gate::authorize('delete', $comment);
        $comment->delete();

        return $this->success(null, 'Comment deleted successfully.');
    }
}
