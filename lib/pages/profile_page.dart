import 'package:apiiii/pages/help_page.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'settings_notification_page.dart'; // Import halaman pengaturan notifikasi

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Data dummy profil
  String _username = 'Meisya';
  String _email = 'meisyamn@gmail.com';

  // Controller untuk text field di dialog
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: _username);
    _emailController = TextEditingController(text: _email);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan dialog edit profil
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Profil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Input Username
                const Text('Username', style: TextStyle(color: Colors.grey, fontSize: 12)),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Input E-mail
                const Text('E-mail', style: TextStyle(color: Colors.grey, fontSize: 12)),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol Aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Reset nilai jika batal
                          _usernameController.text = _username;
                          _emailController.text = _email;
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('BATAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Simpan perubahan
                          setState(() {
                            _username = _usernameController.text;
                            _email = _emailController.text;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kProfileBgColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil Akun',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            // Logika back jika diperlukan, biasanya dihandle MainShell
          },
        ),
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Menu Pengaturan Notifikasi
                  _buildOptionItem(
                    icon: Icons.notifications_outlined,
                    title: 'Pengaturan Notifikasi',
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const SettingsNotificationPage()),
                      );
                    },
                  ),
                  
                  _buildOptionItem(
                    icon: Icons.help_outline,
                    title: 'Bantuan',
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const HelpPage()),
                      );
                    },
                  ),
                  
                  _buildOptionItem(
                    icon: Icons.info_outline,
                    title: 'Tentang Aplikasi',
                    onTap: () {},
                  ),
                  
                  const Spacer(),
                  _buildLogoutButton(),
                  const SizedBox(height: 40),
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
            child: const Icon(
              Icons.person_outline,
              size: 60,
              color: Colors.brown, // Sesuaikan warna icon agar mirip gambar
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          Text(
            _email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tombol Trigger Edit Profil
          GestureDetector(
            onTap: _showEditProfileDialog,
            child: const Text(
              'Edit Profil',
              style: TextStyle(
                color: Colors.grey,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon, 
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryColor), // Icon warna orange
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: kTextColor,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ElevatedButton(
        onPressed: () {
          // Navigasi kembali ke login dan hapus semua route sebelumnya
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC65231), // Warna merah bata/gelap tombol logout
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'logout',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}