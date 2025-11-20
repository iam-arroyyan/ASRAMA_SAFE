// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../theme/colors.dart';

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
            Text(
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
                SizedBox(width: 8),
                Text(
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
            _buildQuickActions(),
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
      child: Center(
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
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: kTextColor,
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(Icons.notifications, 'Notifikasi'),
        _buildActionItem(Icons.history, 'Histori'),
        _buildActionItem(Icons.phone_in_talk, '113'),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 40, color: kTextColor),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(color: kTextColor)),
      ],
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
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
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