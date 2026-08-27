<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\SoftDeletes;

class Post extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'user_id',
        'title',
        'content',
        'images',
        'shared_post_id',
    ];

    protected $casts = [
        'images' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function comments()
    {
        return $this->hasMany(Comment::class);
    }

    public function likes()
    {
        return $this->hasMany(Like::class);
    }


    public function savedByUsers()
    {
        return $this->belongsToMany(User::class, 'saved_posts')->withTimestamps();
    }

    public function sharedPost()
    {
        return $this->belongsTo(Post::class, 'shared_post_id');
    }

    /**
     * Scope that pre-loads all relations and counts needed for the feed.
     * Fixes the N+1 query issue on is_liked and is_saved.
     */
    public function scopeForFeed(Builder $query): Builder
    {
        return $query
            ->with([
                'user:id,first_name,last_name,profile_picture',
                'sharedPost.user:id,first_name,last_name,profile_picture',
            ])
            ->withCount(['comments', 'likes'])
            ->withExists([
                'likes as is_liked' => fn (Builder $q) => $q->where('user_id', auth()->id()),
                'savedByUsers as is_saved' => fn (Builder $q) => $q->where('saved_posts.user_id', auth()->id()),
            ]);
    }
}
