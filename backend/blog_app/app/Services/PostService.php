<?php

namespace App\Services;

use App\Models\Post;
use Illuminate\Support\Facades\Storage;

class PostService
{
    /**
     * Create a new post.
     */
    public function createPost(array $data, string $userId): Post
    {
        $imagePaths = [];
        if (isset($data['images']) && is_array($data['images'])) {
            foreach ($data['images'] as $image) {
                $imagePaths[] = $image->store('posts', 'public');
            }
        }

        return Post::create([
            'user_id' => $userId,
            'title' => $data['title'] ?? null,
            'content' => $data['content'],
            'images' => empty($imagePaths) ? null : $imagePaths,
        ]);
    }

    /**
     * Update an existing post.
     */
    public function updatePost(Post $post, array $data): Post
    {
        if (isset($data['title'])) $post->title = $data['title'];
        if (isset($data['content'])) $post->content = $data['content'];

        if (isset($data['images']) && is_array($data['images'])) {
            // Delete old images if they exist
            if (!empty($post->images)) {
                foreach ($post->images as $oldImage) {
                    Storage::disk('public')->delete($oldImage);
                }
            }

            $imagePaths = [];
            foreach ($data['images'] as $image) {
                $imagePaths[] = $image->store('posts', 'public');
            }
            $post->images = empty($imagePaths) ? null : $imagePaths;
        }

        $post->save();

        return $post;
    }

    /**
     * Delete a post and its images.
     */
    public function deletePost(Post $post): void
    {
        if (!empty($post->images)) {
            foreach ($post->images as $image) {
                Storage::disk('public')->delete($image);
            }
        }

        $post->delete();
    }
}
