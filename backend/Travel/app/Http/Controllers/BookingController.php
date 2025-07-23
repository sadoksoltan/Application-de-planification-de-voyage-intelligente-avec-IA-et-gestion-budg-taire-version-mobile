<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Booking;
use Illuminate\Support\Facades\Auth;

class BookingController extends Controller
{

  public function store(Request $request)
  {
      $user = auth('sanctum')->user();
      if (!$user) {
          return response()->json(['error' => 'Non authentifié'], 401);
      }
      $request->validate([
          'flight' => 'required|array',
      ]);
      $booking = \App\Models\Booking::create([
          'user_id' => $user->id,
          'flight_data' => $request->flight,
      ]);
      return response()->json(['success' => true, 'booking' => $booking]);
  }

  public function userBookings()
  {
      $user = auth('sanctum')->user();
      if (!$user) {
          return response()->json(['error' => 'Non authentifié'], 401);
      }
      $bookings = Booking::where('user_id', $user->id)->latest()->get();
      return response()->json(['bookings' => $bookings]);
  }
  public function destroy($id)
{
    $user = auth('sanctum')->user();
    $booking = Booking::where('id', $id)->where('user_id', $user->id)->first();
    if (!$booking) {
        return response()->json(['error' => 'Réservation introuvable'], 404);
    }
    $booking->delete();
    return response()->json(['success' => true]);
}
public function allBookings()
{
    $user = auth('sanctum')->user();
    if (!$user || $user->role !== 'admin') {
        return response()->json(['error' => 'Non autorisé'], 403);
    }
    $bookings = \App\Models\Booking::with('user')->latest()->get();
    return response()->json(['bookings' => $bookings]);
}
public function markAsPaid($id)
{
    $booking = \App\Models\Booking::findOrFail($id);
    $booking->paid = true;
    $booking->save();
    return response()->json(['success' => true]);
}
}
