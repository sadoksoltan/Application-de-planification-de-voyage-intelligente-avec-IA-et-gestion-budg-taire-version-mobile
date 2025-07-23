import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
class LoginRegisterScreen extends StatefulWidget {
  final void Function(String userName)? onLogin;
  final VoidCallback? onLogout;

  const LoginRegisterScreen({super.key, this.onLogin, this.onLogout});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool isLogin = true;
  bool isAuthenticated = false;
  String? userName;
  String? userEmail;
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerPasswordConfirmController = TextEditingController();

  String? authToken;
  final String baseUrl = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('auth_token');
      userName = prefs.getString('name') ?? 'Profil';
      isAuthenticated = authToken != null;
    });
  }

  Future<void> handleLogin() async {
    try {
      await http.get(Uri.parse('$baseUrl/sanctum/csrf-cookie'));

      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _loginEmailController.text,
          'password': _loginPasswordController.text,
        }),
      );

      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = data['user'];
      if (response.statusCode == 200 && token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        if (user != null) {
          await prefs.setString('name', user['name'] ?? '');
          await prefs.setString('role', user['role']?.toString() ?? '');
          await prefs.setString('email', user['email'] ?? '');
        }
        setState(() {
          isAuthenticated = true;
          authToken = token;
          userName = user?['name'] ?? data['user']['name'] ?? 'Profil';
          userEmail = user?['email'] ?? data['user']['email'] ?? '';
        });
        // Appelle le callback du parent
        widget.onLogin?.call(userName ?? 'Profil');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful! Welcome back.')),
        );
        Navigator.pushReplacementNamed(context, '/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Login failed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> handleRegister() async {
    if (_registerPasswordController.text !=
        _registerPasswordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      await http.get(Uri.parse('$baseUrl/sanctum/csrf-cookie'));
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _registerNameController.text,
          'email': _registerEmailController.text,
          'password': _registerPasswordController.text,
          'password_confirmation': _registerPasswordConfirmController.text,
        }),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        setState(() {
          isLogin = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Registration failed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> handleLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        setState(() {
          isAuthenticated = false;
          authToken = null;
          userName = null;
        });
        widget.onLogout?.call();
        return;
      }
      final response = await http.post(
        Uri.parse('$baseUrl/api/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      await prefs.remove('auth_token');
      await prefs.remove('name');
      await prefs.remove('role');
      await prefs.remove('email');
      setState(() {
        isAuthenticated = false;
        authToken = null;
        userName = null;
      });
      widget.onLogout?.call();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have been logged out successfully.'),
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout failed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

Future<void> handleGoogleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final idToken = googleAuth.idToken;
      print('idToken: $idToken');
      if (idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur: Impossible de récupérer le token Google.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Envoie le token Google à Laravel
      final response = await http.post(
        Uri.parse('$baseUrl/api/login/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = data['user'];
      if (response.statusCode == 200 && token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        if (user != null) {
          await prefs.setString('name', user['name'] ?? '');
          await prefs.setString('role', user['role']?.toString() ?? '');
          await prefs.setString('email', user['email'] ?? '');
        }
        setState(() {
          authToken = token;
          userName = user?['name'] ?? 'Profil';
          isAuthenticated = true;
        });
        widget.onLogin?.call(userName ?? 'Profil');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login Google réussi !')));
        Navigator.pushReplacementNamed(context, '/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Login Google échoué.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur Google Sign-In: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login / Register'),
        backgroundColor: const Color(0xFF10a7a7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => setState(() => isLogin = true),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: isLogin ? const Color(0xFF10a7a7) : Colors.black54,
                      fontWeight: isLogin ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = false),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: !isLogin ? const Color(0xFF10a7a7) : Colors.black54,
                      fontWeight: !isLogin ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (isLogin)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFdd4b39),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text('Login with Google'),
                          onPressed: handleGoogleLogin,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF506dab),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.facebook),
                          label: const Text('Login with Facebook'),
                          onPressed: () {
                            // Ajoute ici la logique Facebook si besoin
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _loginEmailController,
                    decoration: const InputDecoration(
                      labelText: 'User Name or Email Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _loginPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (_) {}),
                      const Text('Remember me'),
                      const Spacer(),
                      TextButton(
                        onPressed:
                            () => Navigator.pushNamed(
                              context,
                              '/forgot-password',
                            ),
                        child: const Text('Lost your password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10a7a7),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => isLogin = false),
                    child: const Text(
                      "Don't have an account? Register",
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF506dab),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.facebook),
                          label: const Text('Login with Facebook'),
                          onPressed: () {
                            // Ajoute ici la logique Facebook si besoin
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFdd4b39),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text('Login with Google'),
                          onPressed: handleGoogleLogin,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _registerNameController,
                    decoration: const InputDecoration(
                      labelText: 'User Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _registerEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _registerPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _registerPasswordConfirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Re-enter Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (_) {}),
                      const Expanded(
                        child: Text(
                          'I have read and accept the Terms and Privacy Policy',
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10a7a7),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Register'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => isLogin = true),
                    child: const Text(
                      "Already have an account? Login",
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
