import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SettingsNotificationPage extends StatefulWidget {
  const SettingsNotificationPage({super.key});

  @override
  State<SettingsNotificationPage> createState() => _SettingsNotificationPageState();
}

class _SettingsNotificationPageState extends State<SettingsNotificationPage> {
  // State untuk switch
  bool _gasLeakNotif = true;
  bool _fireSmokeNotif = true;
  bool _sensorDisconnectNotif = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // Warna background cream/putih
      appBar: AppBar(
        backgroundColor: kPrimaryColor, // Warna orange
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Pengaturan Notifikasi',
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Card Container Putih
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSwitchItem(
                          title: 'Notifikasi Gas Bocor',
                          value: _gasLeakNotif,
                          onChanged: (val) => setState(() => _gasLeakNotif = val),
                        ),
                        _buildDivider(),
                        _buildSwitchItem(
                          title: 'Notifikasi Api / Asap',
                          value: _fireSmokeNotif,
                          onChanged: (val) => setState(() => _fireSmokeNotif = val),
                        ),
                        _buildDivider(),
                        _buildSwitchItem(
                          title: 'Notifikasi Disconnect Sensor',
                          value: _sensorDisconnectNotif,
                          onChanged: (val) => setState(() => _sensorDisconnectNotif = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Footer Hak Cipta
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
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

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: kTextColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: kPrimaryColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey[200],
      indent: 16,
      endIndent: 16,
    );
  }
}