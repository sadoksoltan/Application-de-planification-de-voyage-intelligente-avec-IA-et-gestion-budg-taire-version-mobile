<?php

use Illuminate\Support\Facades\Route;
use Laravel\Socialite\Facades\Socialite;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\SocialiteController;
Route::get('/', function () {
    return view('Welcome');
});

// PAS de name sur la redirection
Route::get('/auth/google', [SocialiteController::class, 'redirectToGoogle']);
Route::get('/auth/google/callback', [SocialiteController::class, 'handleGoogleCallback'])->name('auth.google.callback');
Route::get('/auth/facebook', [SocialiteController::class, 'redirectToFacebook']);
Route::get('/auth/facebook/callback', [SocialiteController::class, 'handleFacebookCallback']);

// Route pour afficher le formulaire de réinitialisation
Route::get('/reset-password/{token}', function (string $token) {
    return view('auth.reset-password', [
        'token' => $token,
        'email' => request()->query('email') // Récupère l'email depuis l'URL
    ]);
})->name('password.reset');
// Route pour traiter la soumission du formulaire
Route::post('/reset-password', [AuthController::class, 'handlePasswordReset'])
    ->name('password.update');