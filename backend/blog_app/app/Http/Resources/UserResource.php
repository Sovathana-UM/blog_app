<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: "User",
    title: "User",
    description: "User model",
    properties: [
        new OA\Property(property: "id", type: "string", format: "uuid"),
        new OA\Property(property: "first_name", type: "string"),
        new OA\Property(property: "last_name", type: "string"),
        new OA\Property(property: "email", type: "string", format: "email"),
        new OA\Property(property: "avatar_url", type: "string", nullable: true),
        new OA\Property(property: "bio", type: "string", nullable: true),
        new OA\Property(property: "location", type: "string", nullable: true),
        new OA\Property(property: "is_online", type: "boolean")
    ]
)]
class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'first_name' => $this->first_name,
            'last_name' => $this->last_name,
            'email' => $this->email,
            'avatar_url' => $this->profile_picture ? asset('storage/' . $this->profile_picture) : null,
            'bio' => $this->bio,
            'location' => $this->location,
            'is_online' => $this->isOnline(),
        ];
    }
}
