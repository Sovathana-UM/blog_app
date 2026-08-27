<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Composite index to speed up unread-count queries and fetching user notifications
        Schema::table('notifications', function (Blueprint $table) {
            $table->index(['user_id', 'read_at'], 'notifications_user_read_idx');
        });

        // Unique composite index on saved_posts so a user cannot save the same post twice
        // (also speeds up the exists() check)
        Schema::table('saved_posts', function (Blueprint $table) {
            // Only add if it doesn't already exist
            $table->unique(['user_id', 'post_id'], 'saved_posts_user_post_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('notifications', function (Blueprint $table) {
            $table->dropIndex('notifications_user_read_idx');
        });

        Schema::table('saved_posts', function (Blueprint $table) {
            $table->dropUnique('saved_posts_user_post_unique');
        });
    }
};
