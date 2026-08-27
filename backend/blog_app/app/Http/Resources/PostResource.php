<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PostResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'content' => $this->content,
            'image_urls' => collect($this->images)->map(fn($path) => asset('storage/' . $path))->toArray(),
            'likes_count' => $this->likes_count ?? 0,
            'comments_count' => $this->comments_count ?? 0,
            'shares_count' => $this->shares_count ?? 0,
            'share_url' => config('app.url') . '/api/posts/' . $this->id,
            'is_liked'       => (bool) $this->is_liked,
            'is_saved'       => (bool) $this->is_saved,
            'shared_post_id' => $this->shared_post_id,
            'shared_post' => new PostResource($this->whenLoaded('sharedPost')),
            'author' => new UserResource($this->whenLoaded('user')),

            'created_at' => $this->created_at->toIso8601String(),
        ];
    }
}
