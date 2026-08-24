<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $notifications = $request->user()->notifications()->orderBy('created_at', 'desc')->get();
        return $this->formatResponse(true, 'Notifications retrieved successfully', 200, $notifications);
    }
}
