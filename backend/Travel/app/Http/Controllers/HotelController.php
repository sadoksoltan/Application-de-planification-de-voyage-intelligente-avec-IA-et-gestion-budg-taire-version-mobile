<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use GuzzleHttp\Client;

class HotelController extends Controller
{
    protected $rapidApiKey;

    public function __construct()
    {
        $this->rapidApiKey = config('services.rapidapi.key');
    }

    protected function getDestinationId($query)
    {
        $client = new Client();
        try {
            $response = $client->get('https://booking-com15.p.rapidapi.com/api/v1/hotels/searchDestination', [
                'headers' => [
                    'x-rapidapi-key' => $this->rapidApiKey,
                    'x-rapidapi-host' => 'booking-com15.p.rapidapi.com',
                ],
                'query' => [
                    'query' => $query,
                ],
            ]);
            $data = json_decode($response->getBody(), true);
            \Log::info('searchDestination response', $data);
    
            // Essaye plusieurs structures selon la doc et la réalité de l'API
            if (!empty($data['data'][0]['dest_id'])) {
                return $data['data'][0]['dest_id'];
            }
            if (!empty($data['result'][0]['dest_id'])) {
                return $data['result'][0]['dest_id'];
            }
            // Log si rien trouvé
            \Log::warning('Aucun dest_id trouvé pour la query : ' . $query . ' | Réponse : ' . json_encode($data));
        } catch (\Exception $e) {
            \Log::error('Erreur RapidAPI dest_id: ' . $e->getMessage());
        }
        return null;
    }
public function search(Request $request)
{
    $validated = $request->validate([
        'query' => 'required|string',
        'arrival_date' => 'required|date',
        'departure_date' => 'required|date|after:arrival_date',
        'adults' => 'nullable|integer|min:1',
    ]);

    $destId = $this->getDestinationId($request->input('query'));
    if (!$destId) {
        return response()->json(['error' => 'Destination inconnue'], 400);
    }

    $params = [
        'dest_id' => $destId,
        'search_type' => 'CITY',
        'arrival_date' => $request->arrival_date,
        'departure_date' => $request->departure_date,
        'adults' => $request->adults ?? 1,
        'room_qty' => $request->room_qty ?? 1,
        'page_number' => $request->page_number ?? 1,
        'currency_code' => 'EUR',
        'languagecode' => 'fr',
    ];
    if ($request->has('price_min')) $params['price_min'] = $request->price_min;
    if ($request->has('price_max')) $params['price_max'] = $request->price_max;

    $client = new Client();
    try {
        $response = $client->get('https://booking-com15.p.rapidapi.com/api/v1/hotels/searchHotels', [
            'headers' => [
                'x-rapidapi-key' => $this->rapidApiKey,
                'x-rapidapi-host' => 'booking-com15.p.rapidapi.com',
            ],
            'query' => $params,
        ]);
        $data = json_decode($response->getBody(), true);
        return response()->json($data);
    } catch (\Exception $e) {
        return response()->json(['error' => $e->getMessage()], 500);
    }
}
}