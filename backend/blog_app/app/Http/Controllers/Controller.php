<?php

namespace App\Http\Controllers;

use OpenApi\Attributes as OA;

#[OA\Info(version: "1.0.0", description: "Blog API Documentation", title: "Blog App API")]
#[OA\Server(url: "http://localhost:8000/api/v1", description: "Local API V1 Server")]
#[OA\SecurityScheme(securityScheme: "bearerAuth", type: "http", scheme: "bearer")]
abstract class Controller
{
    //
}
