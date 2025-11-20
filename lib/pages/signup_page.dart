// lib/pages/signup_page.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/logo_widget.dart';
import '../widgets/custom_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _agreeToTerms = false;

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
              const SizedBox(height: 60),
              const LogoWidget(), // Widget Logo Kustom
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Daftar',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              const CustomTextField(
                hintText: 'Email',
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              const CustomTextField(
                hintText: 'username',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              const CustomTextField(
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: kPrimaryColor,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "I'm agree to The ",
                        style: const TextStyle(color: kTextColor, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _agreeToTerms ? () {
                  // TODO: Logika pendaftaran
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'sudah punya akun? ',
                    style: const TextStyle(color: kTextColor, fontSize: 15),
                    children: [
                      TextSpan(
                        text: 'login',
                        style: const TextStyle(
                          color: kLinkColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Kembali ke halaman login
                            Navigator.pop(context);
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