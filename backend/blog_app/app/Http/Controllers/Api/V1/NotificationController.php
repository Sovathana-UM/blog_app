<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\NotificationResource;
use App\Models\Notification;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class NotificationController extends Controller
{
    use ApiResponse;

    #[OA\Get(path: "/notifications", summary: "Get user notifications", tags: ["Notifications"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "page", in: "query", description: "Page number", required: false, schema: new OA\Schema(type: "integer"))]
    #[OA\Response(response: 200, description: "Notifications retrieved successfully")]
    public function index(Request $request)
    {
        $notifications = $request->user()
                                 ->notifications()
                                 ->with(['sender:id,first_name,last_name,profile_picture', 'post:id,content'])
                                 ->latest()
                                 ->paginate(20);

        return $this->success([
            'notifications' => NotificationResource::collection($notifications->items()),
            'meta' => [
                'current_page' => $notifications->currentPage(),
                'last_page' => $notifications->lastPage(),
                'total' => $notifications->total(),
            ]
        ], 'Notifications retrieved successfully.');
    }

    #[OA\Get(path: "/notifications/unread-count", summary: "Get unread notifications count", tags: ["Notifications"], security: [["bearerAuth" => []]])]
    #[OA\Response(response: 200, description: "Unread count retrieved successfully")]
    public function unreadCount(Request $request)
    {
        $count = $request->user()
                         ->notifications()
                         ->whereNull('read_at')
                         ->count();

        return $this->success(['count' => $count], 'Unread count retrieved successfully.');
    }

    #[OA\Patch(path: "/notifications/{notification}/read", summary: "Mark a notification as read", tags: ["Notifications"], security: [["bearerAuth" => []]])]
    #[OA\Parameter(name: "notification", in: "path", required: true, schema: new OA\Schema(type: "string"))]
    #[OA\Response(response: 200, description: "Notification marked as read")]
    public function markAsRead(Request $request, Notification $notification)
    {
        if ($notification->user_id !== $request->user()->id) {
            return $this->error('Unauthorized', null, 403);
        }

        if (is_null($notification->read_at)) {
            $notification->update(['read_at' => now()]);
        }

        return $this->success(new NotificationResource($notification), 'Notification marked as read.');
    }

    #[OA\Patch(path: "/notifications/read-all", summary: "Mark all notifications as read", tags: ["Notifications"], security: [["bearerAuth" => []]])]
    #[OA\Response(response: 200, description: "All notifications marked as read")]
    public function markAllAsRead(Request $request)
    {
        $request->user()
                ->notifications()
                ->whereNull('read_at')
                ->update(['read_at' => now()]);

        return $this->success(null, 'All notifications marked as read.');
    }
}
