<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index()
    {
        $categories = Category::select('id', 'name')->get();
        return $this->formatResponse(true, 'Categories retrieved successfully', 200, $categories);
    }
}
