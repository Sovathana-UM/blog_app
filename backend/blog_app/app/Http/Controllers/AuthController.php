<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;
use OpenApi\Attributes as OA;

class AuthController extends Controller
{

    #[OA\Post(path: "/register", summary: "Register a new user", tags: ["Authentication"])]
    #[OA\RequestBody(
        required: true,
        content: new OA\MediaType(
            mediaType: "multipart/form-data",
            schema: new OA\Schema(
                required: ["first_name", "last_name", "email", "password"],
                properties: [
                    new OA\Property(property: "first_name", type: "string", example: "John"),
                    new OA\Property(property: "last_name", type: "string", example: "Doe"),
                    new OA\Property(property: "email", type: "string", format: "email", example: "john@example.com"),
                    new OA\Property(property: "password", type: "string", format: "password", example: "password123"),
                    new OA\Property(property: "gender", type: "string", enum: ["male", "female", "other"], example: "male"),
                    new OA\Property(property: "date_of_birth", type: "string", format: "date", example: "1990-01-01"),
                    new OA\Property(property: "profile_picture", type: "string", format: "binary")
                ]
            )
        )
    )]
    #[OA\Response(
        response: 201, 
        description: "Successful registration",
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: "success", type: "boolean", example: true),
                new OA\Property(property: "message", type: "string", example: "Registration successful"),
                new OA\Property(property: "statusCode", type: "integer", example: 201),
                new OA\Property(property: "data", type: "object", properties: [
                    new OA\Property(property: "token", type: "string"),
                    new OA\Property(property: "user", type: "object")
                ])
            ]
        )
    )]
    #[OA\Response(response: 422, description: "Validation Error")]
    #[OA\Response(response: 500, description: "Server Error")]
    public function register(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'first_name' => 'required|string|max:255',
                'last_name' => 'required|string|max:255',
                'email' => 'required|string|email|max:255|unique:users',
                'password' => 'required|string|min:8',
                'gender' => 'nullable|in:male,female,other',
                'date_of_birth' => 'nullable|date',
                'profile_picture' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            ]);

            $profilePicturePath = null;
            if ($request->hasFile('profile_picture')) {
                $profilePicturePath = $request->file('profile_picture')->store('profile_pictures', 'public');
            }

            $user = User::create([
                'first_name' => $validatedData['first_name'],
                'last_name' => $validatedData['last_name'],
                'email' => $validatedData['email'],
                'password' => Hash::make($validatedData['password']),
                'gender' => $validatedData['gender'] ?? null,
                'date_of_birth' => $validatedData['date_of_birth'] ?? null,
                'profile_picture' => $profilePicturePath,
            ]);

            $accessToken = $user->createToken('access_token')->plainTextToken;

            return $this->formatResponse(true, 'Registration successful', 201, [
                'token' => $accessToken,
                'user' => $user
            ]);
        } catch (ValidationException $e) {
            return $this->formatResponse(false, 'Validation error', 422, $e->errors());
        } catch (\Exception $e) {
            return $this->formatResponse(false, 'An error occurred during registration.', 500, ['error' => $e->getMessage()]);
        }
    }

    #[OA\Post(path: "/login", summary: "Log in to the application", tags: ["Authentication"])]
    #[OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            required: ["email", "password"],
            properties: [
                new OA\Property(property: "email", type: "string", format: "email", example: "john@example.com"),
                new OA\Property(property: "password", type: "string", format: "password", example: "password123")
            ]
        )
    )]
    #[OA\Response(
        response: 200, 
        description: "Successful login",
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: "success", type: "boolean", example: true),
                new OA\Property(property: "message", type: "string", example: "Login successful"),
                new OA\Property(property: "statusCode", type: "integer", example: 200),
                new OA\Property(property: "data", type: "object", properties: [
                    new OA\Property(property: "token", type: "string"),
                    new OA\Property(property: "user", type: "object")
                ])
            ]
        )
    )]
    #[OA\Response(response: 401, description: "Invalid credentials")]
    #[OA\Response(response: 422, description: "Validation Error")]
    #[OA\Response(response: 500, description: "Server Error")]
    public function login(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'email' => 'required|string|email',
                'password' => 'required|string',
            ]);

            $user = User::where('email', $validatedData['email'])->first();

            if (!$user || !Hash::check($validatedData['password'], $user->password)) {
                return $this->formatResponse(false, 'Invalid credentials', 401, null);
            }

            $accessToken = $user->createToken('access_token')->plainTextToken;

            return $this->formatResponse(true, 'Login successful', 200, [
                'token' => $accessToken,
                'user' => $user
            ]);
        } catch (ValidationException $e) {
            return $this->formatResponse(false, 'Validation error', 422, $e->errors());
        } catch (\Exception $e) {
            return $this->formatResponse(false, 'An error occurred during login.', 500, ['error' => $e->getMessage()]);
        }
    }

    #[OA\Post(path: "/logout", summary: "Log out of the application", tags: ["Authentication"], security: [["bearerAuth" => []]])]
    #[OA\Response(
        response: 200, 
        description: "Logged out successfully",
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: "success", type: "boolean", example: true),
                new OA\Property(property: "message", type: "string", example: "Logged out successfully"),
                new OA\Property(property: "statusCode", type: "integer", example: 200),
                new OA\Property(property: "data", type: "object", nullable: true)
            ]
        )
    )]
    #[OA\Response(response: 401, description: "Unauthenticated")]
    #[OA\Response(response: 500, description: "Server Error")]
    public function logout(Request $request)
    {
        try {
            // Revoke current access token
            $request->user()->currentAccessToken()->delete();

            return $this->formatResponse(true, 'Logged out successfully', 200, null);
        } catch (\Exception $e) {
            return $this->formatResponse(false, 'An error occurred during logout.', 500, ['error' => $e->getMessage()]);
        }
    }
}
