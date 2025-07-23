import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;

  Future<void> submit() async {
    setState(() => isLoading = true);
    final email = _emailController.text.trim();

    try {
      // Optionnel: await http.get(Uri.parse('$baseUrl/sanctum/csrf-cookie'));
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        showToast(context, data['message'] ?? 'Password reset email sent!');
        _emailController.clear();
        // Redirige vers /login après 2 secondes
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pushReplacementNamed('/login');
        });
      } else {
        showToast(
          context,
          data['message'] ?? 'Failed to send reset link',
          false,
        );
      }
    } catch (e) {
      showToast(context, 'Network error', false);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Enter your email to reset your password'),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: !isLoading,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : submit,
                child:
                    isLoading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Send Reset Link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showToast(BuildContext context, String message, [bool success = true]) {
  final color = success ? Colors.green : Colors.red;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
}
