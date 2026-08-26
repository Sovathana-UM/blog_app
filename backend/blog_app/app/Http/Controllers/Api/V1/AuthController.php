<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Services\AuthService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class AuthController extends Controller
{
    use ApiResponse;

    public function __construct(private AuthService $authService)
    {
    }

    #[OA\Post(path: "/auth/register", summary: "Register a new user", tags: ["Auth"])]
    #[OA\RequestBody(required: true, content: new OA\JsonContent(
        required: ["first_name", "last_name", "email", "password", "password_confirmation"],
        properties: [
            new OA\Property(property: "first_name", type: "string", example: "John"),
            new OA\Property(property: "last_name", type: "string", example: "Doe"),
            new OA\Property(property: "email", type: "string", format: "email", example: "john@example.com"),
            new OA\Property(property: "password", type: "string", format: "password", example: "password123"),
            new OA\Property(property: "password_confirmation", type: "string", format: "password", example: "password123")
        ]
    ))]
    #[OA\Response(response: 201, description: "User registered successfully")]
    #[OA\Response(response: 422, description: "Validation error")]
    public function register(RegisterRequest $request)
    {
        $result = $this->authService->register($request->validated());

        return $this->success([
            'user' => new UserResource($result['user']),
            'token' => $result['token'],
        ], 'User registered successfully.', 201);
    }

    #[OA\Post(path: "/auth/login", summary: "Login user", tags: ["Auth"])]
    #[OA\RequestBody(required: true, content: new OA\JsonContent(
        required: ["email", "password"],
        properties: [
            new OA\Property(property: "email", type: "string", format: "email", example: "john@example.com"),
            new OA\Property(property: "password", type: "string", format: "password", example: "password123")
        ]
    ))]
    #[OA\Response(response: 200, description: "Logged in successfully")]
    #[OA\Response(response: 422, description: "Invalid credentials")]
    public function login(LoginRequest $request)
    {
        $result = $this->authService->login($request->validated());

        return $this->success([
            'user' => new UserResource($result['user']),
            'token' => $result['token'],
        ], 'Logged in successfully.');
    }

    #[OA\Post(path: "/auth/logout", summary: "Logout user", tags: ["Auth"], security: [["bearerAuth" => []]])]
    #[OA\Response(response: 200, description: "Logged out successfully")]
    public function logout(Request $request)
    {
        $this->authService->logout($request->user());

        return $this->success(null, 'Logged out successfully.');
    }
}
