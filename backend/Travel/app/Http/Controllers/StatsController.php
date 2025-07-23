<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Booking;
use App\Models\Trip;
use App\Models\Hotel;
use App\Models\ContactMessage;
use App\Models\Flight;
use App\Models\Tour; 
use App\Models\Article;

class StatsController extends Controller
{
    public function globalStats()
    {

      return response()->json([
            'users_count' => User::count(),
            'bookings_count' => Booking::count(),
            'trips_count' => Trip::count(),
            'hotels_count' => 0,
            'latest_users' => User::orderBy('created_at', 'desc')->take(5)->get(['name', 'email', 'created_at']),
            'latest_bookings' => Booking::orderBy('created_at', 'desc')->take(5)->get(['id', 'user_id', 'created_at']),
            'contact_messages_count' => ContactMessage::count(),
            'tour_count' => Tour::count(),
            'post_count' => Article::count(),
            
        ]);
    }
}