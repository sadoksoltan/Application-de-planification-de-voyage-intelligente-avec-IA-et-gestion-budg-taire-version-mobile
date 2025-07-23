<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure your settings for cross-origin resource sharing
    | or "CORS". This determines what cross-origin operations may execute
    | in web browsers. You are free to adjust these settings as needed.
    |
    | To learn more: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie', 'login', 'logout','reset-password', 'password/reset/*'],

    'allowed_methods' => ['*'],  // Permet toutes les méthodes HTTP (GET, POST, etc.)

    // Change '*' pour ton domaine front-end (ex: localhost ou ton domaine en prod)
    'allowed_origins' => ['http://localhost:5173'],['*'],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],  // Permet tous les en-têtes (Authorization, Content-Type, etc.)

    'exposed_headers' => [],

    'max_age' => 0,  // Définit la durée de mise en cache du pré-vol CORS (en secondes)

    // L'ajout de `true` permet d'envoyer et recevoir des cookies (credentials)
    'supports_credentials' => true,  // Important pour l’authentification avec Laravel Sanctum
];
