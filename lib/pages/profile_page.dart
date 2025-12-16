// lib/pages/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import '../services/image_service.dart';
import 'settings_notification_page.dart';
import 'help_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  
  // Data user dari Firebase
  String _username = 'Loading...';
  String _email = 'Loading...';
  String _phone = '';
  String? _photoBase64;
  bool _isLoading = true;

  // Controller untuk edit profil
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Load user data from Firebase
  Future<void> _loadUserData() async {
    if (_currentUser != null) {
      setState(() => _isLoading = true);
      
      final userData = await _authService.getUserData(_currentUser.uid);
      
      setState(() {
        if (userData != null) {
          _username = userData['fullName'] ?? _currentUser.displayName ?? 'User';
          _email = userData['email'] ?? _currentUser.email ?? '';
          _phone = userData['phone'] ?? '';
          _photoBase64 = userData['photoBase64'];
        } else {
          _username = _currentUser.displayName ?? 'User';
          _email = _currentUser.email ?? '';
        }
        
        _usernameController.text = _username;
        _phoneController.text = _phone;
        _isLoading = false;
      });
    }
  }

  // Pick and upload new photo
  Future<void> _changeProfilePhoto() async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildPhotoPickerSheet(),
    );
    
    if (result == 'reload') {
      _loadUserData();
    }
  }

  Widget _buildPhotoPickerSheet() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ubah Foto Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library, color: Colors.blue),
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.green),
              ),
              title: const Text('Ambil Foto'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadPhoto(ImageSource.camera);
              },
            ),
            if (_photoBase64 != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text('Hapus Foto'),
                onTap: () async {
                  Navigator.pop(context);
                  await _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memproses foto...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final file = await ImageService.pickImage(source: source, context: context);
      
      if (file == null) {
        if (mounted) Navigator.pop(context);
        return;
      }
      
      final base64 = await ImageService.fileToBase64(file);
      
      if (base64 == null) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memproses foto'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Update to Firebase
      final success = await _authService.updateUserProfile(
        uid: _currentUser!.uid,
        photoBase64: base64,
      );
      
      if (mounted) Navigator.pop(context);
      
      if (success) {
        setState(() {
          _photoBase64 = base64;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil berhasil diubah!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengubah foto profil'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    final success = await _authService.updateUserProfile(
      uid: _currentUser!.uid,
      photoBase64: '',  // Empty string to remove
    );
    
    if (success) {
      setState(() {
        _photoBase64 = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // Dialog Edit Profil
  void _showEditProfileDialog() {
    // Reset controller dengan data terbaru
    _usernameController.text = _username;
    _phoneController.text = _phone;
    
    showDialog(
      context: context,
      builder: (context) {
        bool isSaving = false;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                    const Text('Nama Lengkap', style: TextStyle(color: Colors.grey, fontSize: 12)),
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

                    // Input Phone
                    const Text('Nomor Telepon', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
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
                    const SizedBox(height: 8),
                    
                    // Info Email (Read Only)
                    Text(
                      'Email tidak dapat diubah: $_email',
                      style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Aksi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving ? null : () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('BATAL', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving ? null : () async {
                              // Validasi
                              if (_usernameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Nama tidak boleh kosong'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              setDialogState(() => isSaving = true);
                              
                              // Update ke Firebase
                              final success = await _authService.updateUserProfile(
                                uid: _currentUser!.uid,
                                fullName: _usernameController.text.trim(),
                                phone: _phoneController.text.trim(),
                              );
                              
                              if (success) {
                                // Update local state
                                setState(() {
                                  _username = _usernameController.text.trim();
                                  _phone = _phoneController.text.trim();
                                });
                                
                                if (!mounted) return;
                                Navigator.pop(context);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profil berhasil diupdate!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                setDialogState(() => isSaving = false);
                                
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Gagal update profil'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      },
    );
  }

  // Handle Logout
  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil Akun',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'ASRAMA SAFE',
                              applicationVersion: '1.0.0',
                              applicationIcon: const Icon(Icons.security, size: 40, color: kPrimaryColor),
                              children: [
                                const Text('Aplikasi monitoring keamanan asrama dengan sensor gas MQ2 dan Firebase Realtime Database.'),
                              ],
                            );
                          },
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
          // Profile Photo with edit button
          GestureDetector(
            onTap: _changeProfilePhoto,
            child: Stack(
              children: [
                ImageService.buildProfileImage(
                  base64String: _photoBase64,
                  radius: 50,
                  backgroundColor: kPrimaryColor.withOpacity(0.2),
                  iconColor: kPrimaryColor,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
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
          if (_phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _phone,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 16),
          
          // Tombol Edit Profil
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
      leading: Icon(icon, color: kPrimaryColor),
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
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC65231),
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
