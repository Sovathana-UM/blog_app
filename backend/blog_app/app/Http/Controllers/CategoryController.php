<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

class CategoryController extends Controller
{
    #[OA\Get(path: "/categories", summary: "Get all categories", tags: ["Categories"])]
    #[OA\Response(response: 200, description: "List of categories")]
    public function index()
    {
        $categories = Category::select('id', 'name')->get();
        return $this->formatResponse(true, 'Categories retrieved successfully', 200, $categories);
    }
}
