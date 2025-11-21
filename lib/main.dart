// lib/main.dart

import 'dart:io'; // Diperlukan untuk cek Platform
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import package FFI
import 'package:sqflite/sqflite.dart'; // Import sqflite utama

import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/main_shell.dart';
import 'theme/colors.dart';

void main() {
  // --- Inisialisasi Database untuk Windows/Desktop ---
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Inisialisasi FFI
    sqfliteFfiInit();
    // Ubah factory database ke FFI
    databaseFactory = databaseFactoryFfi;
  }
  
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

      // Mulai dari Login Page
      initialRoute: '/login', 
      
      routes: {
        '/': (context) => const MainShell(), 
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}