<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Laravel\Socialite\Facades\Socialite;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Exception;
use Google_Client;

class SocialiteController extends Controller
{
    public function redirectToGoogle()
    {
        return Socialite::driver('google')->redirect();
    }

    public function redirectToFacebook()
    {
        return Socialite::driver('facebook')->redirect();
    }

    public function handleGoogleCallback(Request $request)
{
    try {
        $googleUser = Socialite::driver('google')->stateless()->user();

        $user = User::where('social_id', $googleUser->id)->first();

        if (!$user) {
            $user = User::create([
                'name' => $googleUser->name,
                'email' => $googleUser->email,
                'social_id' => $googleUser->id,
                'social_type' => 'google',
                'password' => Hash::make(uniqid()),
                'role' => 'user'
            ]);
        }

        Auth::login($user);
        $token = $user->createToken($user->name)->plainTextToken;

        // Si mobile, redirige vers un deep link
        if ($request->has('mobile')) {
            return redirect()->away('myapp://auth?token=' . $token . '&name=' . urlencode($user->name));
        }
        // Sinon, web classique
        return redirect()->away('http://localhost:5173/booking?token=' . $token);
    } catch (Exception $e) {
        return response()->json(['error' => $e->getMessage()], 500);
    }
}

    public function handleFacebookCallback()
    {
        try {
            $user = Socialite::driver('facebook')->user();

            $finduser = User::where('social_id', $user->id)->first();

            if ($finduser) {
                Auth::login($finduser);
                return response()->json(
                  $finduser
                );
            } else {
                $newUser = User::create([
                    'name' => $user->name,
                    'email' => $user->email,
                    'social_id' => $user->id,
                    'social_type' => 'facebook',
                    'password' => Hash::make('my-facebook'),
                ]);

                Auth::login($newUser);
                return response()->json(
                  $finduser
                );
            }
        } catch (Exception $e) {
            dd($e->getMessage());
        }
    }
    public function loginWithGoogleIdToken(Request $request)
{
    $request->validate(['id_token' => 'required|string']);

    $client = new \Google_Client(['client_id' => env('GOOGLE_CLIENT_ID')]);
    $payload = $client->verifyIdToken($request->id_token);

    if ($payload) {
        $email = $payload['email'];
        $name = $payload['name'] ?? $email;
        $googleId = $payload['sub'];

        $user = User::where('email', $email)->first();
        if (!$user) {
            $user = User::create([
                'name' => $name,
                'email' => $email,
                'social_id' => $googleId,
                'social_type' => 'google',
                'password' => \Hash::make(\Str::random(16)),
                'role' => 'user'
            ]);
        }
        $token = $user->createToken($user->name)->plainTextToken;
        return response()->json(['user' => $user, 'token' => $token]);
    } else {
        return response()->json(['message' => 'Invalid Google token'], 401);
    }
}
    
}
