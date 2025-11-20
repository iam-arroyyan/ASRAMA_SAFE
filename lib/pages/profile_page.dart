// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kProfileBgColor, // Warna BG beda
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: Text(
          'Profil Akun',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Ini akan di-handle oleh MainShell, tapi bagus untuk ada
          },
        ),
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: Container(
              color: Colors.white, // Bagian bawah putih
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildOptionItem(
                    icon: Icons.notifications_outlined,
                    title: 'Pengaturan Notifikasi',
                  ),
                  _buildOptionItem(
                    icon: Icons.help_outline,
                    title: 'Bantuan',
                  ),
                  _buildOptionItem(
                    icon: Icons.info_outline,
                    title: 'Tentang Aplikasi',
                  ),
                  Spacer(),
                  _buildLogoutButton(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      color: kProfileBgColor,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: kPrimaryColor.withOpacity(0.2),
            child: Icon(
              Icons.person,
              size: 60,
              color: kPrimaryColor,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Meisya',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          Text(
            'meisyamn@gmail.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 16, color: kPrimaryColor),
                SizedBox(width: 4),
                Text(
                  'Edit Profil',
                  style: TextStyle(color: kPrimaryColor),
                ),
                Icon(Icons.chevron_right, size: 16, color: kPrimaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({required IconData icon, required String title}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: kTextColor,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: () {},
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Tambahkan logika logout
          // Contoh: kembali ke halaman Login
          // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor.withOpacity(0.15),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: kPrimaryColor),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 18,
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}