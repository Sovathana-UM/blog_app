<?php

namespace App\Http\Controllers;

use App\Models\Comment;
use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use OpenApi\Attributes as OA;

class CommentController extends Controller
{
    #[OA\Get(path: "/posts/{id}/comments", summary: "Get all comments for a post", tags: ["Comments"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "List of comments")]
    #[OA\Response(response: 404, description: "Post not found")]
    public function index($id)
    {
        $post = Post::find($id);
        
        if (!$post) {
            return $this->formatResponse(false, 'Post not found', 404);
        }

        $comments = Comment::with('user')->where('post_id', $id)->latest()->get();
        
        return $this->formatResponse(true, 'Comments retrieved successfully', 200, $comments);
    }

    #[OA\Post(path: "/comments", summary: "Add a comment", tags: ["Comments"], security: [["bearerAuth" => []]])]
    #[OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            required: ["post_id", "comment"],
            properties: [
                new OA\Property(property: "post_id", type: "string", example: "uuid-1234"),
                new OA\Property(property: "comment", type: "string", example: "Great post!")
            ]
        )
    )]
    #[OA\Response(response: 201, description: "Comment added successfully")]
    #[OA\Response(response: 404, description: "Post not found")]
    #[OA\Response(response: 422, description: "Validation error")]
    public function store(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'post_id' => 'required|exists:posts,id',
                'comment' => 'required|string',
            ]);

            $post = Post::find($validatedData['post_id']);

            if (!$post) {
                return $this->formatResponse(false, 'Post not found', 404);
            }

            $comment = Comment::create([
                'post_id' => $post->id,
                'user_id' => $request->user()->id,
                'content' => $validatedData['comment'],
            ]);

            // Load user relationship to return with comment
            $comment->load('user');

            return $this->formatResponse(true, 'Comment added successfully', 201, $comment);
        } catch (ValidationException $e) {
            return $this->formatResponse(false, 'Validation error', 422, $e->errors());
        } catch (\Exception $e) {
            return $this->formatResponse(false, 'Failed to add comment', 500, ['error' => $e->getMessage()]);
        }
    }

    #[OA\Delete(path: "/comments/{id}", summary: "Delete a comment", tags: ["Comments"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Comment deleted successfully")]
    #[OA\Response(response: 403, description: "Unauthorized to delete this comment")]
    #[OA\Response(response: 404, description: "Comment not found")]
    public function destroy(Request $request, $id)
    {
        $comment = Comment::find($id);

        if (!$comment) {
            return $this->formatResponse(false, 'Comment not found', 404);
        }

        // Allow deletion if the user is the comment author OR the post author
        $post = Post::find($comment->post_id);
        
        if ($comment->user_id !== $request->user()->id && $post->user_id !== $request->user()->id) {
            return $this->formatResponse(false, 'Unauthorized to delete this comment', 403);
        }

        $comment->delete();

        return $this->formatResponse(true, 'Comment deleted successfully', 200);
    }
}
