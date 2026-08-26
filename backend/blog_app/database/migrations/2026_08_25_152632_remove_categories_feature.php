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
        Schema::table('posts', function (Blueprint $table) {
            $table->dropForeign(['category_id']);
            $table->dropIndex(['category_id']);
            $table->dropColumn('category_id');
        });

        Schema::dropIfExists('categories');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::create('categories', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->timestamps();
        });

        Schema::table('posts', function (Blueprint $table) {
            $table->foreignId('category_id')->nullable()->after('content')->constrained('categories')->onDelete('set null');
            $table->index('category_id');
        });
    }
};
