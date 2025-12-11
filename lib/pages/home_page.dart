// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';                    // ← TAMBAH
import '../theme/colors.dart';
import '../services/firebase_service.dart';         // ← TAMBAH
import '../models/gas_reading.dart';                // ← TAMBAH
import 'notification_page.dart';
import 'graph_page.dart';

class HomePage extends StatefulWidget {             // ← UBAH jadi StatefulWidget
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _firebaseService = FirebaseService();  // ← TAMBAH

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
            StreamBuilder<GasReading?>(          // ← UBAH jadi StreamBuilder
              stream: _firebaseService.latestReadingStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final reading = snapshot.data!;
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
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.person, color: Colors.grey[800]),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Meisya',
                  style: TextStyle(
                    color: kTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),                    // ← REALTIME dari Firebase
            const SizedBox(height: 24),
            _buildSectionTitle('Aksi Cepat'),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildSectionTitle('Aktivitas Terakhir'),
            const SizedBox(height: 16),
            _buildActivityList(),                  // ← REALTIME dari Firebase
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return StreamBuilder<GasReading?>(            // ← REALTIME dari Firebase
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
        final isSafe = reading?.isSafe ?? true;
        final statusText = reading?.statusText ?? 'MENUNGGU DATA';
        final ppmValue = reading?.ppm.toStringAsFixed(1) ?? '-';
        final bgColor = isSafe ? kSafeGreen : Colors.red;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
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
                  style: const TextStyle(color: Colors.white, fontSize: 14),
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
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Memanggil Layanan Darurat 113...')),
            );
          },
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
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 40, color: kTextColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: kTextColor)),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return StreamBuilder<List>(                   // ← REALTIME dari Firebase
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

        final alerts = snapshot.data!.take(2).toList(); // Ambil 2 alert terbaru
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
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 30),
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
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
