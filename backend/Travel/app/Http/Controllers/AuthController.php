<?php

namespace App\Http\Controllers;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Carbon;
use Illuminate\Support\Facades\RateLimiter;
use App\Helpers\CMAIL;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Auth\Events\PasswordReset;
use App\Http\Requests\ForgotPasswordRequest;
use App\Notifications\PasswordResetNotification;
use App\Http\Requests\ResetPasswordRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Password;
use Illuminate\Contracts\Auth\Authenticatable;
class AuthController extends Controller
{
    public function register(Request $request){

    $fields = $request->validate([
        'name' => 'required|max:255',
        'email' => 'required|email|unique:users',
        'password' => 'required|confirmed',
        'role' => 'in:user,admin'
    ]);

    $user = User::create([
        'name' => $fields['name'],
        'email' => $fields['email'],
        'password' => Hash::make($fields['password']),
        'role' => $fields['role'] ?? 'user'
    ]);

    $token = $user->createToken($request->name);

    return [
        'user' => $user,
        'token' => $token->plainTextToken
    ];
}
public function login(Request $request){
    $request->validate([
        'email' => 'required|email|exists:users',
        'password' => 'required'
    ]);

    $attemptsKey = 'login:' . $request->ip();
    if (RateLimiter::tooManyAttempts($attemptsKey, 5)) {
        return response()->json(['message' => 'Too many login attempts. Try again later.'], 429);
    }

    $user = User::where('email', $request->email)->first();
    if (!$user || !Hash::check($request->password, $user->password)) {
        RateLimiter::hit($attemptsKey, 60); // Bloque pendant 60 secondes après 5 essais
        return response()->json(['message' => 'Invalid credentials'], 401);
    }

    RateLimiter::clear($attemptsKey);
    return response()->json([
        'user' => $user,
        'token' => $user->createToken($user->name)->plainTextToken
    ]);
}

    public function logout(Request $request){

      $request->user()->tokens()->delete();

        return [
            'message' => 'You are logged out.' 
        ];
    }

    public function deleteUser($id)
{
    $user = User::find($id);

    if (!$user) {
        return response()->json(['message' => 'User not found.'], 404);
    }

    if ($user->role === 'admin') {
        return response()->json(['message' => 'You cannot delete another admin.'], 403);
    }

    $user->delete();

    return response()->json(['message' => 'User deleted successfully.'], 200);
}
public function updateProfile(Request $request)
{
    $user = $request->user();

    $fields = $request->validate([
        'name' => 'sometimes|required|max:255',
        'email' => 'sometimes|required|email|unique:users,email,' . $user->id,
        'password' => 'sometimes|required|min:6|confirmed',
        'role' => 'sometimes|in:user,admin'
    ]);

    // Vérifier si l'utilisateur veut changer son propre rôle
    if ($request->has('role') && $user->role === 'admin' && $fields['role'] !== 'admin') {
        return response()->json(['message' => 'You cannot downgrade yourself from admin.'], 403);
    }

    // Appliquer les mises à jour autorisées
    if ($request->has('name')) {
        $user->name = $fields['name'];
    }
    if ($request->has('email')) {
        $user->email = $fields['email'];
    }
    if ($request->has('password')) {
        $user->password = Hash::make($fields['password']);
    }

    $user->save();

    return response()->json([
        'message' => 'Profile updated successfully.',
        'user' => $user
    ], 200);
}
public function changeUserRole(Request $request, $id)
{
    $request->validate([
        'role' => 'required|in:user,admin'
    ]);

    $user = User::where('id', $id)->first();

    if (!$user) {
        return response()->json(['message' => 'User not found. Make sure the ID is correct.'], 404);
    }

    $authUser = $request->user();

    // Empêcher un admin de modifier un autre admin
    if ($user->role === 'admin' && $authUser->id !== $user->id) {
        return response()->json(['message' => 'You cannot change the role of another admin.'], 403);
    }

    // Permettre à un admin de se rétrograder en user
    if ($authUser->id === $user->id && $user->role === 'admin' && $request->role === 'user') {
        $user->role = 'user';
        $user->save();
        return response()->json(['message' => 'You have downgraded yourself to user.', 'user' => $user]);
    }

    // Appliquer les changements pour un utilisateur non admin
    $user->role = $request->role;
    $user->save();

    return response()->json(['message' => 'User role updated successfully.', 'user' => $user]);
}
public function forgotPassword(ForgotPasswordRequest $request)
{
    $request->validated();

    $status = Password::sendResetLink(
        $request->only('email')
    );

    return $status === Password::RESET_LINK_SENT
        ? response()->json(['message' => __($status)])
        : response()->json(['message' => __($status)], 400);
}

public function resetPassword(ResetPasswordRequest $request)
{
    $validated = $request->validated();

    $status = Password::reset(
    $validated,
    function ($user, string $password) {
        $user->forceFill([
            'password' => Hash::make($password),
            'remember_token' => Str::random(60),
        ])->save();

        event(new PasswordReset($user));
        $user->tokens()->delete();
    }
);
    return match($status) {
        Password::PASSWORD_RESET => response()->json([
            'message' => __($status),
            'success' => true
        ]),
        Password::INVALID_TOKEN => response()->json([
            'message' => 'Le lien de réinitialisation est invalide ou a expiré',
            'success' => false
        ], 400),
        default => response()->json([
            'message' => __($status),
            'success' => false
        ], 400)
    };
}
public function handlePasswordReset(Request $request)
{
    $validated = $request->validate([
        'token' => 'required',
        'email' => 'required|email',
        'password' => 'required|min:6',
    ]);

    $status = Password::reset(
        $validated,
        function ($user, $password) {
            $user->forceFill([
                'password' => Hash::make($password),
                'remember_token' => Str::random(60),
            ])->save();
        
            $user->tokens()->delete();
            
            event(new PasswordReset($user));
        }
    );

    return $status === Password::PASSWORD_RESET
        ? redirect('http://localhost:5173/login')
        : back()->withErrors(['email' => __($status)]);
}
public function getAllUsers()
{
    return response()->json(\App\Models\User::all());
}
public function updateUser(Request $request, $id)
{
    $user = \App\Models\User::findOrFail($id);

    $fields = $request->validate([
        'name' => 'sometimes|required|max:255',
        'email' => 'sometimes|required|email|unique:users,email,' . $user->id,
    ]);

    if (isset($fields['name'])) {
        $user->name = $fields['name'];
    }
    if (isset($fields['email'])) {
        $user->email = $fields['email'];
    }
    $user->save();

    return response()->json(['message' => 'Utilisateur modifié', 'user' => $user]);
}
public function store(Request $request)
{
    $fields = $request->validate([
        'name' => 'required|max:255',
        'email' => 'required|email|unique:users',
        'password' => 'required|min:6',
        'role' => 'in:user,admin'
    ]);

    $user = User::create([
        'name' => $fields['name'],
        'email' => $fields['email'],
        'password' => Hash::make($fields['password']),
        'role' => $fields['role'] ?? 'user'
    ]);

    return response()->json([
        'message' => 'Utilisateur créé avec succès',
        'user' => $user
    ], 201);
}
}
