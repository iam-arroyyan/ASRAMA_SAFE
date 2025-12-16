// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/colors.dart';
import '../services/firebase_service.dart';
import '../services/image_service.dart';
import '../models/gas_reading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'notification_page.dart';
import 'graph_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  
  String _userName = 'Loading...';
  String? _photoBase64;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from Firebase
  Future<void> _loadUserData() async {
    if (_currentUser != null) {
      try {
        final snapshot = await _dbRef.child('users').child(_currentUser.uid).get();
        if (snapshot.exists) {
          final userData = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            _userName = userData['fullName'] ?? _currentUser.displayName ?? 'User';
            _photoBase64 = userData['photoBase64'];
          });
        } else {
          setState(() {
            _userName = _currentUser.displayName ?? 'User';
          });
        }
      } catch (e) {
        setState(() {
          _userName = 'User';
        });
      }
    }
  }

  // Check if sensor is connected based on last update time
  bool _isSensorConnected(GasReading? reading) {
    if (reading == null) return false;
    
    // Anggap sensor disconnect jika tidak ada update selama 30 detik
    final timeSinceLastUpdate = DateTime.now().difference(reading.timestamp);
    return timeSinceLastUpdate.inSeconds < 30;
  }

  // Call emergency number
  Future<void> _callEmergency(BuildContext context) async {
    // TEST: Gunakan nomor test (ganti ke '113' untuk production)
    const String emergencyNumber = '12345'; // Nomor test invalid
    // const String emergencyNumber = '113'; // Nomor darurat pemadam kebakaran
    
    final Uri phoneUri = Uri(scheme: 'tel', path: emergencyNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka aplikasi telepon'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asrama Safe',
              style: TextStyle(
                color: kTitleColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            StreamBuilder<GasReading?>(
              stream: _firebaseService.latestReadingStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final reading = snapshot.data!;
                  final isConnected = _isSensorConnected(reading);
                  
                  if (!isConnected) {
                    return Row(
                      children: [
                        Icon(Icons.sensors_off, size: 12, color: Colors.red[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Sensor terputus',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }
                  
                  final timeAgo = DateTime.now().difference(reading.timestamp);
                  String syncText;
                  if (timeAgo.inMinutes < 1) {
                    syncText = 'Baru saja';
                  } else if (timeAgo.inMinutes < 60) {
                    syncText = '${timeAgo.inMinutes} menit yang lalu';
                  } else {
                    syncText = '${timeAgo.inHours} jam yang lalu';
                  }
                  return Text(
                    'Last sync: $syncText',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  );
                }
                return Text(
                  'Last sync: Loading...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Navigate ke Profile Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                ).then((_) {
                  // Reload user data setelah kembali dari profile
                  _loadUserData();
                });
              },
              child: Row(
                children: [
                  ImageService.buildProfileImage(
                    base64String: _photoBase64,
                    radius: 18,
                    backgroundColor: kPrimaryColor.withOpacity(0.2),
                    iconColor: kPrimaryColor,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: kTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Lihat Profil',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Aksi Cepat'),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildSectionTitle('Aktivitas Terakhir'),
            const SizedBox(height: 16),
            _buildActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return StreamBuilder<GasReading?>(
      stream: _firebaseService.latestReadingStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final reading = snapshot.data;
        final isConnected = _isSensorConnected(reading);
        
        // Jika sensor terputus, tampilkan status TERPUTUS
        if (!isConnected) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'Status Asrama Saat Ini:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.sensors_off, color: Colors.white, size: 40),
                      SizedBox(width: 12),
                      Text(
                        'TERPUTUS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sensor tidak terhubung',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reading != null 
                      ? 'Terakhir terhubung: ${DateFormat('dd MMM HH:mm').format(reading.timestamp)}'
                      : 'Belum pernah terhubung',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Sensor terhubung - tampilkan status normal
        final isSafe = reading?.isSafe ?? true;
        final statusText = reading?.statusText ?? 'MENUNGGU DATA';
        final ppmValue = reading?.ppm.toStringAsFixed(1) ?? '-';
        final bgColor = isSafe ? kSafeGreen : Colors.red;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                const Text(
                  'Status Asrama Saat Ini:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nilai Gas rata-rata: $ppmValue PPM',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: kTextColor,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(
          icon: Icons.notifications,
          label: 'Notifikasi',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );
          },
        ),
        _buildActionItem(
          icon: Icons.auto_graph,
          label: 'Grafik',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GraphPage()),
            );
          },
        ),
        _buildActionItem(
          icon: Icons.phone_in_talk,
          label: '113',
          onTap: () => _callEmergency(context),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
            ),
            child: Icon(icon, size: 40, color: kPrimaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: kTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return StreamBuilder<List>(
      stream: _firebaseService.alertsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            children: [
              _buildActivityItem(
                icon: Icons.check_circle,
                iconColor: kSafeGreen,
                title: 'Status: AMAN',
                subtitle: 'Tidak ada aktivitas mencurigakan',
              ),
            ],
          );
        }

        final alerts = snapshot.data!.take(3).toList(); // Ambil 3 alert terbaru
        return Column(
          children: alerts.map((alert) {
            final timeAgo = DateTime.now().difference(alert.detectedAt);
            String timeText;
            if (timeAgo.inMinutes < 60) {
              timeText = '${timeAgo.inMinutes} menit yang lalu';
            } else if (timeAgo.inHours < 24) {
              timeText = '${timeAgo.inHours} jam yang lalu';
            } else {
              timeText = DateFormat('dd MMM HH:mm').format(alert.detectedAt);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildActivityItem(
                icon: Icons.warning,
                iconColor: alert.severity == 'critical'
                    ? Colors.red
                    : kWarningYellow,
                title: 'PERINGATAN: GAS ${alert.mq2Value} (${alert.severity.toUpperCase()})',
                subtitle: timeText,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
