// lib/pages/notification_page.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kTitleColor, size: 28),
          onPressed: () {
            // Karena ini adalah bagian dari tab, tombol kembali ini
            // mungkin seharusnya mengarahkan ke tab 'Beranda'.
            // Untuk saat ini, kita biarkan non-fungsional atau
            // Anda bisa membuatnya pop() jika halaman ini didorong (push).
          },
        ),
        title: Text(
          'Notifikasi',
          style: TextStyle(
            color: kTitleColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNotificationItem(
            title: 'Terjadi Kebocoran Gas',
            color: kWarningRed,
            timestamp: '30 menit yang lalu',
          ),
          _buildNotificationItem(
            title: 'Status Kembali Normal',
            color: kSafeGreen,
            timestamp: '3 jam yang lalu',
          ),
          _buildNotificationItem(
            title: 'Terjadi Kebocoran Gas',
            color: kWarningRed,
            timestamp: '4 jam yang lalu',
          ),
          _buildNotificationItem(
            title: 'Status Kembali Normal',
            color: kSafeGreen,
            timestamp: '8 jam yang lalu',
          ),
          _buildNotificationItem(
            title: 'Terjadi Kebocoran Gas',
            color: kWarningRed,
            timestamp: '7 jam yang lalu',
          ),
          _buildNotificationItem(
            title: 'Status Kembali Normal',
            color: kSafeGreen,
            timestamp: '9 jam yang lalu',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required Color color,
    required String timestamp,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50), // Membuatnya oval/stadium
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_rounded, color: kTextColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timestamp,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
            textAlign: TextAlign.right,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}