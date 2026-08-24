<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class NotificationController extends Controller
{
    #[OA\Get(path: "/notifications", summary: "Get all notifications", tags: ["Notifications"], security: [["bearerAuth" => []]])]
    #[OA\Response(response: 200, description: "List of notifications")]
    public function index(Request $request)
    {
        $notifications = $request->user()->notifications()->orderBy('created_at', 'desc')->get();
        return $this->formatResponse(true, 'Notifications retrieved successfully', 200, $notifications);
    }

    #[OA\Post(path: "/notifications/{id}/read", summary: "Mark a notification as read", tags: ["Notifications"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "id", in: "path", required: true, schema: new OA\Schema(type: "integer"))]
    #[OA\Response(response: 200, description: "Notification marked as read")]
    public function markAsRead(Request $request, $id)
    {
        $notification = $request->user()->notifications()->find($id);

        if (!$notification) {
            return $this->formatResponse(false, 'Notification not found', 404);
        }

        $notification->read_at = now();
        $notification->save();

        return $this->formatResponse(true, 'Notification marked as read', 200, $notification);
    }

    #[OA\Post(path: "/notifications/read-all", summary: "Mark all notifications as read", tags: ["Notifications"], security: [["bearerAuth" => []]])]
    #[OA\Response(response: 200, description: "All notifications marked as read")]
    public function markAllAsRead(Request $request)
    {
        $request->user()->notifications()->whereNull('read_at')->update(['read_at' => now()]);

        return $this->formatResponse(true, 'All notifications marked as read', 200);
    }
}
