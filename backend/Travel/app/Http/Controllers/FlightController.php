<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use GuzzleHttp\Client;

class FlightController extends Controller
{
    protected $clientId;
    protected $clientSecret;

    public function __construct()
    {
        $this->clientId = config('services.amadeus.client_id');
        $this->clientSecret = config('services.amadeus.client_secret');
    }

    protected function getAmadeusAccessToken()
    {
        $client = new Client();
        $response = $client->post('https://test.api.amadeus.com/v1/security/oauth2/token', [
            'form_params' => [
                'grant_type' => 'client_credentials',
                'client_id' => $this->clientId,
                'client_secret' => $this->clientSecret,
            ],
        ]);
        $data = json_decode($response->getBody(), true);
        return $data['access_token'] ?? null;
    }

    protected function getIataCode($city)
{
  $manualMappings = [
    // Tunisie (déjà présents)
    'tunis' => 'TUN',
    'carthage' => 'TUN',
    'monastir' => 'MIR',
    'sousse' => 'MIR',
    'djerba' => 'DJE',
    'houmt souk' => 'DJE',
    'sfax' => 'SFA',
    'tozeur' => 'TOE',
    'gabes' => 'GAE',
    'gafsa' => 'GAF',
    'tabarka' => 'TBJ',
    'kairouan' => 'TUN',
    'bizerte' => 'TUN',
    'nabeul' => 'NBE',
    'hammamet' => 'NBE',
    'enfidha' => 'NBE',
    'zarzis' => 'DJE',
    'el kef' => 'TUN',
    'mahdia' => 'MIR',
    'siliana' => 'TUN',
    'medenine' => 'DJE',
    'beja' => 'TUN',
    'kebili' => 'TOE',
    // Villes tunisiennes supplémentaires
    'beni khiar' => 'NBE',
    'korba' => 'NBE',
    'kelibia' => 'NBE',
    'soliman' => 'TUN',
    'manouba' => 'TUN',
    'marsa' => 'TUN',
    'la marsa' => 'TUN',
    'raoued' => 'TUN',
    'mornag' => 'TUN',
    'mateur' => 'TUN',
    'dahmani' => 'TUN',
    'metlaoui' => 'GAF',
    'redeyef' => 'GAF',
    'nefta' => 'TOE',
    'chebika' => 'TOE',
    'ain drahem' => 'TBJ',
    'jendouba' => 'TBJ',
    'douz' => 'TOE',
    'ben guerdane' => 'DJE',
    'kebir' => 'DJE',
    'sejnane' => 'TUN',
    'mohamedia' => 'TUN',
    'sayada' => 'MIR',
    'ksar hellal' => 'MIR',
    'jemmel' => 'MIR',
    'zeramdine' => 'MIR',
    'maknassy' => 'SFA',
    'regueb' => 'SFA',
    'sidi bouzid' => 'SFA',
    'thala' => 'TUN',

    // Maroc
    'casablanca' => 'CMN',      // Mohammed V Int’l
    'rabat' => 'RBA',           // Rabat–Salé
    'marrakech' => 'RAK',       // Menara Airport
    'fes' => 'FEZ',             // Fès–Saïs
    'tangier' => 'TNG',         // Ibn Battuta
    'agadir' => 'AGA',          // Al Massira
    'oujda' => 'OUD',           // Angads
    'nador' => 'NDR',           // Al Aroui
    'tetouan' => 'TTU',         // Sania Ramel
    'laayoune' => 'EUN',        // Hassan I Airport
    'dakhla' => 'VIL',          // Dakhla Airport
    'safi' => 'RAK',            // fallback Marrakech
    'kenitra' => 'RBA',         // proche de Rabat
    'el jadida' => 'CMN',       // proche Casablanca
    'mohammedia' => 'CMN',      // banlieue de Casablanca
    'meknes' => 'FEZ',          // proche Fès
    'berkane' => 'OUD',         // proche Oujda
    'taourirt' => 'OUD',        // proche Oujda
    'guercif' => 'FEZ',         // fallback
    'khemisset' => 'RBA',       // proche Rabat
    'settat' => 'CMN',          // sud Casablanca
    'benslimane' => 'CMN',    
    ////////egypt
    'cairo' => 'CAI',           // Le Caire - Cairo International
    'giza' => 'CAI',            // proche du Caire
    'alexandria' => 'HBE',      // Borg El Arab Airport
    'borg el arab' => 'HBE',    // aéroport d’Alexandrie
    'hurghada' => 'HRG',        // Hurghada International
    'sharm el sheikh' => 'SSH', // Sharm El Sheikh Int’l
    'luxor' => 'LXR',           // Luxor International
    'aswan' => 'ASW',           // Aswan International
    'marsaalam' => 'RMF',       // Marsa Alam Int’l
    'port said' => 'PSD',       // petit aéroport régional
    'el gouna' => 'HRG',        // station balnéaire, proche Hurghada
    'dahab' => 'SSH',           // proche Sharm El Sheikh
    'taba' => 'TCP',            // Taba International (nord Sinaï)
    'suez' => 'CAI',            // fallback sur Le Caire
    'ismailia' => 'CAI',        // idem
    'fayoum' => 'CAI',          // à l'ouest du Caire
    'beni suef' => 'CAI',       // sud du Caire
    'minya' => 'LXR',           // fallback sur Louxor
    'assiut' => 'ATZ',          // Assiut Airport
    'sohag' => 'HMB',           // Sohag International
    'qena' => 'LXR',            // proche Louxor
    'el minya' => 'LXR',        // équivalent de "minya"
    'matrouh' => 'MUH',  
    'siwa' => 'MUH',
];

  

    $normalizedCity = strtolower(trim($city));

    if (isset($manualMappings[$normalizedCity])) {
        return $manualMappings[$normalizedCity];
    }

    // 2. Sinon, procéder à la recherche via Amadeus
    $token = $this->getAmadeusAccessToken();
    if (!$token) return null;

    $client = new Client();

    // Recherche d'abord les villes
    try {
        $response = $client->get('https://test.api.amadeus.com/v1/reference-data/locations', [
            'headers' => [
                'Authorization' => 'Bearer ' . $token,
            ],
            'query' => [
                'keyword' => $city,
                'subType' => 'CITY',
            ],
        ]);

        $data = json_decode($response->getBody(), true);

        if (!empty($data['data'])) {
            foreach ($data['data'] as $item) {
                if (!empty($item['iataCode']) && $item['subType'] === 'CITY') {
                    return $item['iataCode'];
                }
            }
        }

        // Fallback : chercher un aéroport
        $response = $client->get('https://test.api.amadeus.com/v1/reference-data/locations', [
            'headers' => [
                'Authorization' => 'Bearer ' . $token,
            ],
            'query' => [
                'keyword' => $city,
                'subType' => 'AIRPORT',
            ],
        ]);

        $data = json_decode($response->getBody(), true);

        if (!empty($data['data'])) {
            foreach ($data['data'] as $item) {
                if (!empty($item['iataCode'])) {
                    return $item['iataCode'];
                }
            }
        }
    } catch (\Exception $e) {
        \Log::error("Erreur lors de la récupération du code IATA pour '$city': " . $e->getMessage());
    }

    return null;
}



    public function search(Request $request)
    {
        $validated = $request->validate([
          'origin' => 'required|string',
            'destination' => 'required|string',
            'departure_date' => 'required|date',
            'adults' => 'required|integer|min:1',
        ]);

        $origin = $this->getIataCode($request->origin);
        $destination = $this->getIataCode($request->destination);

        if (!$origin) {
          return response()->json(['error' => 'Origine inconnue'], 400);
      }
      if (!$destination) {
          return response()->json(['error' => 'Destination inconnue'], 400);
      }

        $params = [
            'originLocationCode' => $origin,
            'destinationLocationCode' => $destination,
            'departureDate' => $request->departure_date,
            'adults' => $request->adults,
            'currencyCode' => 'EUR',
            'max' => 10,
        ];

        if ($request->has('budget')) {
            $params['maxPrice'] = $request->budget;
        }

        $token = $this->getAmadeusAccessToken();
        if (!$token) {
            return response()->json(['error' => 'Impossible de récupérer le token Amadeus'], 500);
        }

        $client = new Client();
        try {
            $response = $client->get('https://test.api.amadeus.com/v2/shopping/flight-offers', [
                'headers' => [
                    'Authorization' => 'Bearer ' . $token,
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