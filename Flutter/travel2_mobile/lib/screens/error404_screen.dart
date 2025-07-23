import 'package:flutter/material.dart';

class Error404Screen extends StatelessWidget {
  const Error404Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oops! Page not found'),
        backgroundColor: const Color(0xFF10a7a7),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Oops! Page not found',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10a7a7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Image.asset(
                'assets/images/404-1.png', // Mets ici ton image SVG/PNG
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                'We are sorry, but the page you requested was not found',
                style: TextStyle(fontSize: 18, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10a7a7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed:
                        () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        ),
                    child: const Text('GO TO HOMEPAGE'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/contact'),
                    child: const Text('GO TO CONTACT PAGE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
