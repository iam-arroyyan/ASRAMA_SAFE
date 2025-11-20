// lib/widgets/logo_widget.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Asrama Safe',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: kTitleColor,
          ),
        ),
        const SizedBox(height: 20),
        // GANTI 'assets/logo.png' DENGAN PATH LOGO ANDA
        Image.asset(
          'assets/logo.png', // <-- GANTI INI
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Icon(
                Icons.security_outlined,
                size: 80,
                color: kPrimaryColor,
              ),
            );
          },
        ),
      ],
    );
  }
}