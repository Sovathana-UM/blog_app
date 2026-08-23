<?php

namespace App\Http\Controllers;

use OpenApi\Attributes as OA;

#[OA\Info(version: "1.0.0", description: "API Documentation", title: "Blog App API")]
#[OA\Server(url: "http://127.0.0.1:8000/api", description: "Local API Server")]
#[OA\SecurityScheme(securityScheme: "bearerAuth", type: "http", scheme: "bearer")]
abstract class Controller
{
    protected function formatResponse($success, $message, $statusCode, $data = null)
    {
        return response()->json([
            'success' => $success,
            'message' => $message,
            'statusCode' => $statusCode,
            'data' => $data
        ], $statusCode);
    }
}
