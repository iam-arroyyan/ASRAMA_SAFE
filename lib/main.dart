// lib/main.dart

import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/main_shell.dart'; // <-- IMPORT BARU
import 'theme/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asrama Safe',
      
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        primaryColor: kPrimaryColor,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: kTextColor),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIconColor: Colors.grey[600],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: kPrimaryColor, width: 2.0),
          ),
        ),
      ),

      // --- Mengatur Rute Navigasi ---
      // initialRoute: '/login', // Tetap mulai dari login
      
      // Ganti initialRoute ke '/' agar kita bisa tes MainShell
      initialRoute: '/login', // <-- GANTI SEMENTARA UNTUK TES
      
      routes: {
        // Rute baru untuk halaman utama
        '/': (context) => const MainShell(), 
        
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}