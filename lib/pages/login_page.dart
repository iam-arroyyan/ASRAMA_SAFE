// lib/pages/login_page.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/logo_widget.dart';
import '../widgets/custom_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              const LogoWidget(), // Widget Logo Kustom
              const SizedBox(height: 40),

              const CustomTextField(
                // Widget Input Kustom
                hintText: 'Username',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              const CustomTextField(
                // Widget Input Kustom
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  // TODO: Logika login

                  // Setelah login berhasil:
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'belum punya akun? ',
                    style: const TextStyle(color: kTextColor, fontSize: 15),
                    children: [
                      TextSpan(
                        text: 'daftar',
                        style: const TextStyle(
                          color: kLinkColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigasi menggunakan named route
                            Navigator.pushNamed(context, '/signup');
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
