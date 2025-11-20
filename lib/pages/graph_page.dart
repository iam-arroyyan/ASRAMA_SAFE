// lib/pages/graph_page.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/colors.dart';

// Enum untuk mengelola pilihan filter waktu
enum TimeRange { day, week, month }

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  // Melacak filter waktu mana yang sedang aktif
  Set<TimeRange> _selectedTimeRange = {TimeRange.day};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        // Tombol kembali (opsional, bisa dihapus jika tidak perlu)
        leading: Icon(Icons.arrow_back, color: kTitleColor, size: 28),
        title: Text(
          'Grafik',
          style: TextStyle(
            color: kTitleColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- FILTER WAKTU ---
            _buildTimeFilter(),
            const SizedBox(height: 24),

            // --- KARTU GRAFIK GAS (MQ2) ---
            _buildGraphCard(
              title: 'Grafik Nilai Gas (MQ2)',
              subtitle: 'Data dalam PPM',
              chart: _buildGasChart(), // Grafik untuk Gas
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget untuk filter waktu di atas
  Widget _buildTimeFilter() {
    return SegmentedButton<TimeRange>(
      segments: const <ButtonSegment<TimeRange>>[
        ButtonSegment(value: TimeRange.day, label: Text('Hari Ini')),
        ButtonSegment(value: TimeRange.week, label: Text('Minggu Ini')),
        ButtonSegment(value: TimeRange.month, label: Text('Bulan Ini')),
      ],
      selected: _selectedTimeRange,
      onSelectionChanged: (Set<TimeRange> newSelection) {
        setState(() {
          // TODO: Ganti data grafik berdasarkan filter
          _selectedTimeRange = newSelection;
        });
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.white,
        selectedBackgroundColor: kPrimaryColor.withOpacity(0.2),
        selectedForegroundColor: kPrimaryColor,
        foregroundColor: Colors.grey[600],
      ),
    );
  }

  // Widget template untuk kartu grafik
  Widget _buildGraphCard({
    required String title,
    required String subtitle,
    required Widget chart,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          // Container untuk menampung grafik
          Container(
            height: 250,
            child: chart,
          ),
        ],
      ),
    );
  }

  // --- GRAFIK UNTUK GAS (MQ2) ---
  Widget _buildGasChart() {
    // TODO: Ganti ini dengan data asli dari sensor MQ2 Anda
    final List<FlSpot> dummyData = [
      FlSpot(0, 150),
      FlSpot(1, 155),
      FlSpot(2, 160),
      FlSpot(3, 158),
      FlSpot(4, 250), // Lonjakan gas
      FlSpot(5, 220),
      FlSpot(6, 180),
      FlSpot(7, 160),
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: dummyData,
            isCurved: true,
            color: kWarningRed, // Warna merah/oranye untuk gas
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: kWarningRed.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}