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

    #[OA\Post(path: "/user/update", summary: "Update user profile", tags: ["User"], security: [["bearerAuth" => []]])]
    #[OA\RequestBody(
        required: true,
        content: new OA\MediaType(
            mediaType: "multipart/form-data",
            schema: new OA\Schema(
                properties: [
                    new OA\Property(property: "first_name", type: "string", example: "John"),
                    new OA\Property(property: "last_name", type: "string", example: "Doe"),
                    new OA\Property(property: "gender", type: "string", enum: ["male", "female", "other"], example: "male"),
                    new OA\Property(property: "date_of_birth", type: "string", format: "date", example: "1990-01-01"),
                    new OA\Property(property: "profile_picture", type: "string", format: "binary")
                ]
            )
        )
    )]
    #[OA\Response(
        response: 200, 
        description: "Profile updated successfully",
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: "success", type: "boolean", example: true),
                new OA\Property(property: "message", type: "string", example: "Profile updated successfully"),
                new OA\Property(property: "statusCode", type: "integer", example: 200),
                new OA\Property(property: "data", type: "object")
            ]
        )
    )]
    #[OA\Response(response: 401, description: "Unauthenticated")]
    #[OA\Response(response: 422, description: "Validation Error")]
    #[OA\Response(response: 500, description: "Server Error")]
    public function updateProfile(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'first_name' => 'nullable|string|max:255',
                'last_name' => 'nullable|string|max:255',
                'gender' => 'nullable|in:male,female,other',
                'date_of_birth' => 'nullable|date',
                'profile_picture' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            ]);

            $user = $request->user();

            if (isset($validatedData['first_name'])) {
                $user->first_name = $validatedData['first_name'];
            }
            if (isset($validatedData['last_name'])) {
                $user->last_name = $validatedData['last_name'];
            }
            if (isset($validatedData['gender'])) {
                $user->gender = $validatedData['gender'];
            }
            if (isset($validatedData['date_of_birth'])) {
                $user->date_of_birth = $validatedData['date_of_birth'];
            }

            if ($request->hasFile('profile_picture')) {
                // Delete old picture if exists
                if ($user->profile_picture && Storage::disk('public')->exists($user->profile_picture)) {
                    Storage::disk('public')->delete($user->profile_picture);
                }

                $profilePicturePath = $request->file('profile_picture')->store('profile_pictures', 'public');
                $user->profile_picture = $profilePicturePath;
            }
            
            $user->save();

            return $this->formatResponse(true, 'Profile updated successfully', 200, $user);
        } catch (ValidationException $e) {
            return $this->formatResponse(false, 'Validation error', 422, $e->errors());
        } catch (\Exception $e) {
            return $this->formatResponse(false, 'An error occurred during update.', 500, ['error' => $e->getMessage()]);
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
}
