<?php

namespace App\Http\Controllers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class HotelRecoController extends Controller
{
  public function recommander(Request $request)
  {
      \Log::info('Front request:', $request->all());
      $response = Http::post('http://127.0.0.1:8001/recommander/', [
          'ville' => $request->ville,
          'budget' => $request->budget,
          'interets' => $request->interets,
          'periode' => $request->periode,
          'top_k' => $request->top_k ?? 2
      ]);
      \Log::info('FastAPI response:', $response->json());
      return response()->json($response->json());
  }
}
