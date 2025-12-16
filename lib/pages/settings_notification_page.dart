import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/notification_preferences_service.dart';

class SettingsNotificationPage extends StatefulWidget {
  const SettingsNotificationPage({super.key});

  @override
  State<SettingsNotificationPage> createState() => _SettingsNotificationPageState();
}

class _SettingsNotificationPageState extends State<SettingsNotificationPage> {
  // State untuk switch - Gas Bocor (hanya tinggi dan kritis)
  bool _gasHighNotif = true;
  bool _gasCriticalNotif = true;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    
    _gasHighNotif = await NotificationPreferencesService.getGasHighEnabled();
    _gasCriticalNotif = await NotificationPreferencesService.getGasCriticalEnabled();
    
    setState(() => _isLoading = false);
  }

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
          'Pengaturan Notifikasi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        
                        // Section: Gas Bocor
                        _buildSectionTitle('Notifikasi Gas Bocor'),
                        const SizedBox(height: 10),
                        _buildSectionDescription(
                          'Pilih tingkat keparahan yang ingin Anda terima notifikasinya:',
                        ),
                        const SizedBox(height: 12),
                        
                        // Card untuk Gas Bocor options
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
                              _buildSwitchItemWithBadge(
                                title: 'Gas Tinggi',
                                subtitle: 'Level tinggi, perlu perhatian segera',
                                value: _gasHighNotif,
                                badgeColor: const Color(0xFFFF6600),
                                onChanged: (val) async {
                                  setState(() => _gasHighNotif = val);
                                  await NotificationPreferencesService.setGasHighEnabled(val);
                                },
                              ),
                              _buildDivider(),
                              _buildSwitchItemWithBadge(
                                title: 'Gas Kritis',
                                subtitle: 'Level berbahaya, tindakan darurat',
                                value: _gasCriticalNotif,
                                badgeColor: const Color(0xFFFF0000),
                                onChanged: (val) async {
                                  setState(() => _gasCriticalNotif = val);
                                  await NotificationPreferencesService.setGasCriticalEnabled(val);
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Info box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue[600]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Status koneksi sensor dapat dilihat di halaman beranda.',
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: kTextColor,
      ),
    );
  }

  Widget _buildSectionDescription(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildSwitchItemWithBadge({
    required String title,
    required String subtitle,
    required bool value,
    required Color badgeColor,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          // Color badge indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: kTextColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
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
      indent: 40,
      endIndent: 16,
    );
  }
}