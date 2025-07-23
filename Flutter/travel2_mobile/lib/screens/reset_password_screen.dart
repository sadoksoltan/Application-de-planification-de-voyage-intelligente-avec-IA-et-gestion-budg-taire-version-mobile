import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool isLoading = false;

  Future<void> submit() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty || confirm.isEmpty) {
      showToast(context, 'Please fill in all fields', false);
      return;
    }
    if (password.length < 5) {
      showToast(context, 'Password must be at least 5 characters', false);
      return;
    }
    if (password != confirm) {
      showToast(context, 'Passwords do not match', false);
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'token': widget.token,
          'password': password,
          'password_confirmation': confirm,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        showToast(context, data['message'] ?? 'Password reset successful!');
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pushReplacementNamed('/login');
        });
      } else {
        showToast(
          context,
          data['message'] ?? 'Error resetting password',
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
      appBar: AppBar(title: const Text('Reset Password')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Enter your new password'),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
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
                        : const Text('Reset Password'),
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
