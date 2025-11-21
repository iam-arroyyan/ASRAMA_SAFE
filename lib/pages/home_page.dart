// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'notification_page.dart'; // Import halaman notifikasi
import 'graph_page.dart'; // Import halaman grafik

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            Text(
              'Last sync: 1 min ago',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
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
            _buildStatusCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Aksi Cepat'),
            const SizedBox(height: 16),
            // Pass context agar bisa melakukan navigasi
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSafeGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          children: [
            Text(
              'Status Asrama Saat Ini:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'AMAN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Nilai Gas rata-rata: 150 PPM',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
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
        // Tombol Notifikasi
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
        // Tombol Grafik (Pengganti Histori)
        _buildActionItem(
          icon: Icons.auto_graph, // Menggunakan icon grafik
          label: 'Grafik',        // Label diganti jadi Grafik
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GraphPage()),
            );
          },
        ),
        // Tombol 113
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

  // Widget item yang bisa diklik
  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap, // Parameter untuk aksi klik
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
    return Column(
      children: [
        _buildActivityItem(
          icon: Icons.warning,
          iconColor: kWarningYellow,
          title: 'PERINGATAN DINI: GAS 205 PPM',
          subtitle: '(1 jam yang lalu)',
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          icon: Icons.check_circle,
          iconColor: kSafeGreen,
          title: 'Status Kembali Normal: AMAN',
          subtitle: '(Status Diperbarui)',
        ),
      ],
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
