import 'package:flutter/material.dart';
import '../theme/colors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Bantuan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // --- SECTION FAQ ---
                const Text(
                  'FAQ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                
                _buildExpansionItem(
                  title: 'Apa itu Asrama Safe?',
                  content: 'Asrama safe adalah aplikasi pemantauan keamanan berbasis IOT untuk mendeteksi kebocoran gas secara real-time.',
                ),
                _buildExpansionItem(
                  title: 'Bagaimana cara kerja sensor?',
                  content: 'Sensor membaca kadar gas di udara. Ketika melebihi batas aman, aplikasi mengirim notifikasi darurat dan mengirim notifikasi jika status kembali normal, notifikasi jika sensor disconnected ke aplikasi, dan notifikasi reconnected jika sensor terhubung kembali.',
                ),
                _buildExpansionItem(
                  title: 'Mengapa saya menerima banyak notifikasi dalam waktu dekat?',
                  contentWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Penyebab umum:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('• Jaringan sensor tidak stabil.'),
                      Text('• Ada perubahan kecil pada level gas.'),
                      SizedBox(height: 8),
                      Text('Aplikasi mengirim notifikasi agar pengguna tetap terinformasi.'),
                    ],
                  ),
                ),
                _buildExpansionItem(
                  title: 'Apakah aplikasi bisa digunakan di dua HP sekaligus?',
                  content: 'Bisa, selama pengguna login dengan akun yang sama.\nNotifikasi akan masuk ke kedua perangkat.',
                ),
                _buildExpansionItem(
                  title: 'Bagaimana cara memastikan area aman setelah kebocoran gas?',
                  content: 'Asrama Safe akan memberikan memberikan notifikasi status normal.',
                ),

                const SizedBox(height: 24),

                // --- SECTION PANDUAN KESELAMATAN ---
                const Text(
                  'PANDUAN KESELAMATAN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 10),

                _buildExpansionItem(
                  title: 'Langkah-langkah penanganan gas bocor',
                  contentWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _BulletPoint('Segera matikan sumber api seperti kompor'),
                      _BulletPoint('Tidak menyalakan listrik atau saklar lampu'),
                      _BulletPoint('Buka ventilasi udara'),
                      _BulletPoint('Melakukan evakuasi dan menjauhi area'),
                      _BulletPoint('Menghubungi pemadam kebakaran'),
                    ],
                  ),
                ),
                _buildExpansionItem(
                  title: 'Pencegahan kebocoran gas',
                  contentWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _BulletPoint('Melakukan pengecekan secara berkala terhadap tabung, regulator, dan selang.'),
                      _BulletPoint('Mengganti karet seal setiap 6 bulan sekali.'),
                      _BulletPoint('Menyimpan tabung di tempat yang tidak dekat dengan sumber panas'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer Hak Cipta
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0, top: 10),
            child: Column(
              children: [
                Text(
                  'Hak Cipta © 2025 Asrama Safe',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seluruh hak dilindungi',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'V. 1.0.0',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionItem({
    required String title,
    String? content,
    Widget? contentWidget,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: kTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconColor: kTextColor,
          collapsedIconColor: kTextColor,
          childrenPadding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2F6), // Warna background abu-abu kebiruan muda
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: contentWidget ?? Text(
                content ?? '',
                style: const TextStyle(fontSize: 13, color: kTextColor, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}