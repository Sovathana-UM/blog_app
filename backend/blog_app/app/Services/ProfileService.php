<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class ProfileService
{
    /**
     * Update user profile.
     */
    public function updateProfile(User $user, array $data): User
    {
        $fillableData = collect($data)->except('avatar')->toArray();
        $user->fill($fillableData);

        if (isset($data['avatar'])) {
            if ($user->profile_picture) {
                Storage::disk('public')->delete($user->profile_picture);
            }
            $user->profile_picture = $data['avatar']->store('avatars', 'public');
        }

        $user->save();
        return $user;
    }

    /**
     * Change user password.
     */
    public function changePassword(User $user, string $newPassword): void
    {
        $user->password = Hash::make($newPassword);
        $user->save();
    }
}
