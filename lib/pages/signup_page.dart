// lib/pages/signup_page.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/logo_widget.dart';
import '../models/user_model.dart';
import '../services/database_helper.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Fungsi Pendaftaran
  void _handleSignUp() async {
    if (_usernameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua kolom')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Cek apakah username sudah ada
    bool exists = await DatabaseHelper.instance.checkUsernameExists(_usernameController.text);
    
    if (exists) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username sudah digunakan')),
      );
    } else {
      // Simpan ke Database
      User newUser = User(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text, // Catatan: Sebaiknya di-hash untuk keamanan produksi
      );

      await DatabaseHelper.instance.registerUser(newUser);

      if (!mounted) return;
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: kSafeGreen, content: Text('Akun berhasil dibuat! Silakan Login.')),
      );
      
      Navigator.pop(context); // Kembali ke Login
    }
  }

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
              const LogoWidget(),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Daftar',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kTextColor),
                ),
              ),
              const SizedBox(height: 30),
              
              // Input Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // Input Username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 20),

              // Input Password
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
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
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: (_agreeToTerms && !_isLoading) ? _handleSignUp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
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
                        style: const TextStyle(color: kLinkColor, fontWeight: FontWeight.bold, fontSize: 15),
                        recognizer: TapGestureRecognizer()..onTap = () {
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