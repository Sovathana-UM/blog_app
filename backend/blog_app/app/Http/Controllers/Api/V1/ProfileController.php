<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\ChangePasswordRequest;
use App\Http\Requests\UpdateProfileRequest;
use App\Http\Resources\UserResource;
use App\Services\ProfileService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class ProfileController extends Controller
{
    use ApiResponse;

    public function __construct(private ProfileService $profileService)
    {
    }

    #[OA\Get(path: "/current-user", summary: "Get current user profile", tags: ["Profile"], security: [["bearerAuth" => []]])]
    #[OA\Response(response: 200, description: "Profile retrieved successfully")]
    public function show(Request $request)
    {
        return $this->success(new UserResource($request->user()), 'Profile retrieved successfully.');
    }

    #[OA\Put(path: "/current-user", summary: "Update profile details", tags: ["Profile"], security: [["bearerAuth" => []]])]
    #[OA\RequestBody(required: true, content: new OA\JsonContent(
        properties: [
            new OA\Property(property: "first_name", type: "string", example: "John"),
            new OA\Property(property: "last_name", type: "string", example: "Doe"),
            new OA\Property(property: "bio", type: "string", example: "Software Engineer"),
            new OA\Property(property: "location", type: "string", example: "New York")
        ]
    ))]
    #[OA\Response(response: 200, description: "Profile updated successfully")]
    public function update(UpdateProfileRequest $request)
    {
        $user = $this->profileService->updateProfile($request->user(), $request->validated());
        
        return $this->success(new UserResource($user), 'Profile updated successfully.');
    }

    #[OA\Post(path: "/current-user/avatar", summary: "Upload profile avatar", tags: ["Profile"], security: [["bearerAuth" => []]])]
    #[OA\RequestBody(required: true, content: new OA\MediaType(
        mediaType: "multipart/form-data",
        schema: new OA\Schema(
            required: ["avatar"],
            properties: [
                new OA\Property(property: "avatar", type: "string", format: "binary")
            ]
        )
    ))]
    #[OA\Response(response: 200, description: "Avatar uploaded successfully")]
    public function uploadAvatar(UpdateProfileRequest $request)
    {
        $user = $this->profileService->updateProfile($request->user(), $request->validated());
        
        return $this->success(new UserResource($user), 'Avatar uploaded successfully.');
    }

    #[OA\Put(path: "/current-user/password", summary: "Change user password", tags: ["Profile"], security: [["bearerAuth" => []]])]
    #[OA\RequestBody(required: true, content: new OA\JsonContent(
        required: ["current_password", "password", "password_confirmation"],
        properties: [
            new OA\Property(property: "current_password", type: "string", format: "password"),
            new OA\Property(property: "password", type: "string", format: "password"),
            new OA\Property(property: "password_confirmation", type: "string", format: "password")
        ]
    ))]
    #[OA\Response(response: 200, description: "Password changed successfully")]
    public function changePassword(ChangePasswordRequest $request)
    {
        $this->profileService->changePassword($request->user(), $request->validated('password'));
        
        return $this->success(null, 'Password changed successfully.');
    }

    #[OA\Post(path: "/current-user/fcm-token", summary: "Update FCM token", tags: ["Profile"], security: [["bearerAuth" => []]])]
    #[OA\RequestBody(required: true, content: new OA\JsonContent(
        required: ["fcm_token"],
        properties: [
            new OA\Property(property: "fcm_token", type: "string", example: "token_12345")
        ]
    ))]
    #[OA\Response(response: 200, description: "FCM token updated successfully")]
    public function updateFcmToken(Request $request)
    {
        $request->validate(['fcm_token' => 'required|string']);
        
        $user = $request->user();
        $user->fcm_token = $request->fcm_token;
        $user->save();

        return $this->success(null, 'FCM token updated successfully.');
    }

    #[OA\Delete(path: "/current-user/fcm-token", summary: "Remove FCM token", tags: ["Profile"], security: [["bearerAuth" => []]])]
    #[OA\Response(response: 200, description: "FCM token removed successfully")]
    public function removeFcmToken(Request $request)
    {
        $user = $request->user();
        $user->fcm_token = null;
        $user->save();

        return $this->success(null, 'FCM token removed successfully.');
    }
}
