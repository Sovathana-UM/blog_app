<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use OpenApi\Attributes as OA;

class UserController extends Controller
{

    #[OA\Get(path: "/user", summary: "Get current user info", tags: ["User"], security: [["bearerAuth" => []]])]
    #[OA\Response(
        response: 200, 
        description: "Successful response",
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: "success", type: "boolean", example: true),
                new OA\Property(property: "message", type: "string", example: "User retrieved successfully"),
                new OA\Property(property: "statusCode", type: "integer", example: 200),
                new OA\Property(property: "data", type: "object")
            ]
        )
    )]
    #[OA\Response(response: 401, description: "Unauthenticated")]
    public function getUser(Request $request)
    {
        return $this->formatResponse(true, 'User retrieved successfully', 200, $request->user());
    }

    #[OA\Put(path: "/profile", summary: "Update user profile", tags: ["User"], security: [["bearerAuth" => []]])]
    #[OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: "first_name", type: "string", example: "John"),
                new OA\Property(property: "last_name", type: "string", example: "Doe"),
                new OA\Property(property: "gender", type: "string", enum: ["male", "female", "other"], example: "male"),
                new OA\Property(property: "date_of_birth", type: "string", format: "date", example: "1990-01-01"),
                new OA\Property(property: "bio", type: "string", example: "Flutter Developer"),
                new OA\Property(property: "location", type: "string", example: "Cambodia")
            ]
        )
    )]
    #[OA\Response(response: 200, description: "Profile updated successfully")]
    public function updateProfile(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'first_name' => 'nullable|string|max:255',
                'last_name' => 'nullable|string|max:255',
                'gender' => 'nullable|in:male,female,other',
                'date_of_birth' => 'nullable|date',
                'bio' => 'nullable|string',
                'location' => 'nullable|string',
            ]);

            $user = $request->user();

            if (isset($validatedData['first_name'])) $user->first_name = $validatedData['first_name'];
            if (isset($validatedData['last_name'])) $user->last_name = $validatedData['last_name'];
            if (isset($validatedData['gender'])) $user->gender = $validatedData['gender'];
            if (isset($validatedData['date_of_birth'])) $user->date_of_birth = $validatedData['date_of_birth'];
            if (isset($validatedData['bio'])) $user->bio = $validatedData['bio'];
            if (isset($validatedData['location'])) $user->location = $validatedData['location'];
            
            $user->save();

            return $this->formatResponse(true, 'Profile updated successfully', 200, $user);
        } catch (ValidationException $e) {
            return $this->formatResponse(false, 'Validation error', 422, $e->errors());
        } catch (\Exception $e) {
            return $this->formatResponse(false, 'An error occurred during update.', 500, ['error' => $e->getMessage()]);
        }
    }

    #[OA\Post(path: "/profile/avatar", summary: "Upload profile avatar", tags: ["User"], security: [["bearerAuth" => []]])]
    #[OA\RequestBody(
        required: true,
        content: new OA\MediaType(
            mediaType: "multipart/form-data",
            schema: new OA\Schema(
                required: ["avatar"],
                properties: [
                    new OA\Property(property: "avatar", type: "string", format: "binary")
                ]
            )
        )
    )]
    #[OA\Response(response: 200, description: "Avatar uploaded successfully")]
    public function uploadAvatar(Request $request)
    {
        try {
            $request->validate([
                'avatar' => 'required|image|mimes:jpeg,png,jpg,gif|max:5120',
            ]);

            $user = $request->user();

            if ($user->profile_picture && Storage::disk('public')->exists($user->profile_picture)) {
                Storage::disk('public')->delete($user->profile_picture);
            }

            $path = $request->file('avatar')->store('profile_pictures', 'public');
            $user->profile_picture = $path;
            $user->save();

            return $this->formatResponse(true, 'Avatar uploaded successfully', 200, $user);
        } catch (ValidationException $e) {
            return $this->formatResponse(false, 'Validation error', 422, $e->errors());
        } catch (\Exception $e) {
            return $this->formatResponse(false, 'An error occurred during upload.', 500, ['error' => $e->getMessage()]);
        }
    }

    #[OA\Post(path: "/user/update-email", summary: "Securely update email", tags: ["User"], security: [["bearerAuth" => []]])]
    #[OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            required: ["email", "password"],
            properties: [
                new OA\Property(property: "email", type: "string", format: "email", example: "newemail@example.com"),
                new OA\Property(property: "password", type: "string", format: "password", example: "your_current_password")
            ]
        )
    )]
    #[OA\Response(
        response: 200, 
        description: "Email updated successfully",
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: "success", type: "boolean", example: true),
                new OA\Property(property: "message", type: "string", example: "Email updated successfully"),
                new OA\Property(property: "statusCode", type: "integer", example: 200),
                new OA\Property(property: "data", type: "object")
            ]
        )
    )]
    #[OA\Response(response: 401, description: "Incorrect password")]
    #[OA\Response(response: 422, description: "Validation Error")]
    #[OA\Response(response: 500, description: "Server Error")]
    public function updateEmail(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'email' => 'required|string|email|max:255|unique:users',
                'password' => 'required|string',
            ]);

            $user = $request->user();

            if (!Hash::check($validatedData['password'], $user->password)) {
                return $this->formatResponse(false, 'Incorrect password. Cannot change email.', 401, null);
            }

            $user->email = $validatedData['email'];
            $user->save();

            return $this->formatResponse(true, 'Email updated successfully', 200, $user);
        } catch (ValidationException $e) {
            return $this->formatResponse(false, 'Validation error', 422, $e->errors());
        } catch (\Exception $e) {
            return $this->formatResponse(false, 'An error occurred while updating email.', 500, ['error' => $e->getMessage()]);
        }
    }

    #[OA\Put(path: "/change-password", summary: "Change password", tags: ["User"], security: [["bearerAuth" => []]])]
    #[OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            required: ["current_password", "new_password", "new_password_confirmation"],
            properties: [
                new OA\Property(property: "current_password", type: "string", example: "oldpass123"),
                new OA\Property(property: "new_password", type: "string", example: "newpass123"),
                new OA\Property(property: "new_password_confirmation", type: "string", example: "newpass123")
            ]
        )
    )]
    #[OA\Response(response: 200, description: "Password changed successfully")]
    #[OA\Response(response: 422, description: "Validation error or incorrect current password")]
    public function changePassword(Request $request)
    {
        try {
            $request->validate([
                'current_password' => 'required',
                'new_password' => 'required|min:8|confirmed',
            ]);

            $user = $request->user();

            if (!\Illuminate\Support\Facades\Hash::check($request->current_password, $user->password)) {
                return $this->formatResponse(false, 'Current password is incorrect', 422);
            }

            $user->password = \Illuminate\Support\Facades\Hash::make($request->new_password);
            $user->save();

            return $this->formatResponse(true, 'Password changed successfully', 200);
        } catch (ValidationException $e) {
            return $this->formatResponse(false, 'Validation error', 422, $e->errors());
        } catch (\Exception $e) {
            return $this->formatResponse(false, 'An error occurred.', 500, ['error' => $e->getMessage()]);
        }
    }

    #[OA\Post(path: "/user/fcm-token", summary: "Update FCM token for push notifications", tags: ["User"], security: [["bearerAuth" => []]])]
    #[OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            required: ["token"],
            properties: [
                new OA\Property(property: "token", type: "string", example: "eFk_m928...")
            ]
        )
    )]
    #[OA\Response(response: 200, description: "FCM token updated successfully")]
    public function updateFcmToken(Request $request)
    {
        $request->validate([
            'token' => 'required|string',
        ]);

        $user = $request->user();
        $user->fcm_token = $request->token;
        $user->save();

        return $this->formatResponse(true, 'FCM token updated successfully', 200);
    }
}
