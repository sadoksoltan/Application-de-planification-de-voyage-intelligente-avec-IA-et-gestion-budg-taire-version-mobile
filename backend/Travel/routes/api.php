<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\V1\TripController;
use Illuminate\Http\Request;
use App\Http\Controllers\AuthController;
use Illuminate\Foundation\Auth\EmailVerificationRequest;
use App\Http\Controllers\ReservationController;
use App\Http\Controllers\ContactMessageController;
use Laravel\Socialite\Facades\Socialite;
use App\Http\Controllers\SocialiteController;
use App\Http\Controllers\PasswordResetLinkController;
use App\Http\Controllers\NewPasswordController;
use App\Http\Controllers\FlightController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\HotelController;
use App\Http\Controllers\StatsController;
use App\Http\Controllers\AdminTourController;
use App\Http\Controllers\ArticleController;
use App\Http\Controllers\GeminiController;
use App\Http\Controllers\HotelRecoController;
// Route::prefix('v1')->group(function () {
//     Route::apiResource('/trips',TripController::class);
//   });
Route::post('/register',[AuthController::class,'register']);
Route::post('/login',[AuthController::class,'login']);
Route::post('/logout',[AuthController::class,'logout'])->middleware('auth:sanctum');
Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});
Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::apiResource('/admin/trips', TripController::class);
});
Route::middleware(['auth:sanctum', 'admin'])->delete('/users/{id}', [AuthController::class, 'deleteUser']);
// Route::middleware(['auth:sanctum'])->put('/users/profile', [AuthController::class, 'updateProfile']);
Route::middleware(['auth:sanctum', 'admin'])->put('/users/{id}/role', [AuthController::class, 'changeUserRole']);
Route::middleware(['auth:sanctum', 'admin'])->put('/users/self/role', [AuthController::class, 'changeUserRole']);
Route::get('/reservation', [ReservationController::class, 'create']);
Route::post('/reservation', [ReservationController::class, 'store']);
Route::post('/contact', [ContactMessageController::class, 'store']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);
Route::get('/flights/search', [FlightController::class, 'search']);
Route::get('/hotels/search', [\App\Http\Controllers\HotelController::class, 'search']);
Route::middleware('auth:sanctum')->group(function () {
  Route::post('/bookings', [BookingController::class, 'store']);
  Route::get('/bookings', [BookingController::class, 'userBookings']);
  Route::delete('/bookings/{id}', [BookingController::class, 'destroy']);
});
Route::middleware(['auth:sanctum', 'admin'])->get('/stats', [\App\Http\Controllers\StatsController::class, 'globalStats']);
Route::middleware(['auth:sanctum', 'admin'])->get('/users', [AuthController::class, 'getAllUsers']);
Route::middleware(['auth:sanctum', 'admin'])->put('/users/{id}', [AuthController::class, 'updateUser']);
Route::middleware(['auth:sanctum', 'admin'])->post('/users', [AuthController::class, 'store']);
Route::middleware(['auth:sanctum', 'admin'])->group(function () {
  Route::get('/admin/tours', [AdminTourController::class, 'index']);
  Route::post('/admin/tours', [AdminTourController::class, 'store']);
});
Route::get('/tours', [AdminTourController::class, 'index']);
Route::middleware('auth:sanctum')->group(function () {
  Route::get('/admin/posts', [ArticleController::class, 'index']);
  Route::post('/admin/posts/create', [ArticleController::class, 'store']);
});
Route::get('/posts', [ArticleController::class, 'publicIndex']);
Route::delete('/admin/posts/{id}', [ArticleController::class, 'destroy']);
Route::delete('/admin/tours/{id}', [AdminTourController::class, 'destroy']);
Route::get('/admin/tours/{id}', [AdminTourController::class, 'show']);
Route::put('/admin/tours/{id}', [AdminTourController::class, 'update']);
Route::get('/admin/posts/{id}', [ArticleController::class, 'show']);
Route::put('/admin/posts/{id}', [ArticleController::class, 'update']);
Route::middleware(['auth:sanctum'])->get('/admin/bookings', [BookingController::class, 'allBookings']);
Route::patch('/admin/bookings/{id}/pay', [BookingController::class, 'markAsPaid']);
Route::middleware(['auth:sanctum'])->get('/admin/bookings', [BookingController::class, 'allBookings']);
Route::post('/ai/generate', [\App\Http\Controllers\GeminiController::class, 'generateContent']);
Route::post('/ai/restaurants', [\App\Http\Controllers\GeminiController::class, 'getRestaurantsByDay']);
Route::post('/ai/museums', [\App\Http\Controllers\GeminiController::class, 'getMuseumsByDay']);
Route::post('/login/google', [SocialiteController::class, 'loginWithGoogleIdToken']);
Route::post('/recommander', [HotelRecoController::class, 'recommander']);