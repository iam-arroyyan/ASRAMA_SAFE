// lib/pages/graph_page.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../services/firebase_service.dart';
import '../models/gas_reading.dart';

// Enum untuk filter waktu utama (hanya hari ini)
enum TimeRange { day }

// Enum untuk sub-filter agregasi (tanpa per jam)
enum DayAggregation { live, perMinute }

// Model untuk data yang sudah diagregasi
class AggregatedData {
  final DateTime timestamp;
  final double avgPpm;
  final String label;

  AggregatedData({
    required this.timestamp,
    required this.avgPpm,
    required this.label,
  });
}

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final FirebaseService _firebaseService = FirebaseService();
  
  // Sub-filter untuk agregasi hari ini (tanpa per jam)
  DayAggregation _dayAggregation = DayAggregation.live;

  // Filter readings untuk hari ini
  List<GasReading> _filterTodayReadings(List<GasReading> readings) {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day);
    
    return readings.where((r) => r.timestamp.isAfter(startTime)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // Agregasi data per menit
  List<AggregatedData> _aggregatePerMinute(List<GasReading> readings) {
    if (readings.isEmpty) return [];
    
    final Map<String, List<double>> grouped = {};
    
    for (final reading in readings) {
      final key = DateFormat('HH:mm').format(reading.timestamp);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(reading.ppm);
    }
    
    final result = <AggregatedData>[];
    grouped.forEach((key, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      final parts = key.split(':');
      final now = DateTime.now();
      final timestamp = DateTime(now.year, now.month, now.day, 
          int.parse(parts[0]), int.parse(parts[1]));
      result.add(AggregatedData(timestamp: timestamp, avgPpm: avg, label: key));
    });
    
    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return result;
  }

  // Hitung statistik dari agregasi
  Map<String, double> _calculateAggregatedStats(List<AggregatedData> data) {
    if (data.isEmpty) {
      return {'min': 0, 'max': 0, 'avg': 0};
    }
    
    final values = data.map((d) => d.avgPpm).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final avg = values.reduce((a, b) => a + b) / values.length;
    
    return {'min': min, 'max': max, 'avg': avg};
  }

  // Hitung statistik dari readings
  Map<String, double> _calculateStats(List<GasReading> readings) {
    if (readings.isEmpty) {
      return {'min': 0, 'max': 0, 'avg': 0};
    }
    
    final ppmValues = readings.map((r) => r.ppm).toList();
    final min = ppmValues.reduce((a, b) => a < b ? a : b);
    final max = ppmValues.reduce((a, b) => a > b ? a : b);
    final avg = ppmValues.reduce((a, b) => a + b) / ppmValues.length;
    
    return {'min': min, 'max': max, 'avg': avg};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Grafik Hari Ini',
          style: TextStyle(
            color: kTitleColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: StreamBuilder<List<GasReading>>(
        stream: _firebaseService.readingsHistoryStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allReadings = snapshot.data ?? [];
          final filteredReadings = _filterTodayReadings(allReadings);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // --- SUB-FILTER AGREGASI ---
                _buildAggregationFilter(),
                const SizedBox(height: 16),

                // --- KONTEN GRAFIK HARI INI ---
                _buildDayContent(filteredReadings),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayContent(List<GasReading> readings) {
    switch (_dayAggregation) {
      case DayAggregation.live:
        final stats = _calculateStats(readings);
        final hasExtremeSpike = stats['max']! > 500;
        return Column(
          children: [
            _buildStatsRow(stats, readings.length),
            // Warning jika ada spike ekstrem
            if (hasExtremeSpike) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ada spike ekstrem (${stats['max']!.toStringAsFixed(0)} PPM). Grafik di-cap pada 500 PPM.',
                        style: TextStyle(color: Colors.orange[800], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            _buildGraphCard(
              title: 'Grafik Live',
              subtitle: 'Data realtime hari ini',
              chart: _buildLiveChart(readings),
            ),
            const SizedBox(height: 16),
            if (readings.isNotEmpty) _buildLastReadingInfo(readings.last),
          ],
        );
        
      case DayAggregation.perMinute:
        final aggregated = _aggregatePerMinute(readings);
        final stats = _calculateAggregatedStats(aggregated);
        return Column(
          children: [
            _buildStatsRow(stats, aggregated.length),
            const SizedBox(height: 24),
            _buildGraphCard(
              title: 'Rata-rata Per Menit',
              subtitle: 'Data hari ini diagregasi per menit',
              chart: _buildAggregatedChart(aggregated, 'HH:mm'),
            ),
          ],
        );
    }
  }

  // Widget untuk sub-filter agregasi (hanya Live dan Per Menit)
  Widget _buildAggregationFilter() {
    return Wrap(
      spacing: 8,
      children: [
        _buildChip('Live', _dayAggregation == DayAggregation.live, () {
          setState(() => _dayAggregation = DayAggregation.live);
        }),
        _buildChip('Per Menit', _dayAggregation == DayAggregation.perMinute, () {
          setState(() => _dayAggregation = DayAggregation.perMinute);
        }),
      ],
    );
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? kPrimaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[600],
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Widget untuk statistik
  Widget _buildStatsRow(Map<String, double> stats, int dataCount) {
    return Row(
      children: [
        _buildStatCard('Min', '${stats['min']!.toStringAsFixed(1)} PPM', Colors.green),
        const SizedBox(width: 8),
        _buildStatCard('Max', '${stats['max']!.toStringAsFixed(1)} PPM', kWarningRed),
        const SizedBox(width: 8),
        _buildStatCard('Rata-rata', '${stats['avg']!.toStringAsFixed(1)} PPM', kPrimaryColor),
        const SizedBox(width: 8),
        _buildStatCard('Data', '$dataCount titik', Colors.grey),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk info reading terakhir
  Widget _buildLastReadingInfo(GasReading reading) {
    final timeAgo = DateTime.now().difference(reading.timestamp);
    String timeText;
    if (timeAgo.inMinutes < 1) {
      timeText = 'Baru saja';
    } else if (timeAgo.inMinutes < 60) {
      timeText = '${timeAgo.inMinutes} menit yang lalu';
    } else {
      timeText = DateFormat('dd MMM HH:mm').format(reading.timestamp);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: reading.isAlert ? kWarningRed.withOpacity(0.1) : kSafeGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reading.isAlert ? kWarningRed : kSafeGreen,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            reading.isAlert ? Icons.warning : Icons.check_circle,
            color: reading.isAlert ? kWarningRed : kSafeGreen,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reading Terakhir: ${reading.ppm.toStringAsFixed(1)} PPM',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Status: ${reading.statusText} | $timeText',
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
            style: const TextStyle(
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
          SizedBox(
            height: 250,
            child: chart,
          ),
        ],
      ),
    );
  }

  // Grafik untuk data live
  Widget _buildLiveChart(List<GasReading> readings) {
    if (readings.isEmpty) {
      return _buildEmptyChart();
    }

    final spots = <FlSpot>[];
    const double maxDisplayPpm = 500.0; // Cap for display
    for (int i = 0; i < readings.length; i++) {
      // Clamp nilai PPM agar tidak melebihi maxY
      final double clampedPpm = readings[i].ppm.clamp(0, maxDisplayPpm).toDouble();
      spots.add(FlSpot(i.toDouble(), clampedPpm));
    }
    
    final stats = _calculateStats(readings);
    final dataLength = readings.length;
    final interval = (dataLength / 6).ceil().toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: interval > 0 ? interval : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < readings.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('HH:mm').format(readings[index].timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        // Cap maxY at 500 PPM for better readability, extreme values will exceed the chart
        maxY: (stats['max']! * 1.1).clamp(100, 500),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < readings.length) {
                  final reading = readings[index];
                  return LineTooltipItem(
                    '${reading.ppm.toStringAsFixed(1)} PPM\n${DateFormat('HH:mm:ss').format(reading.timestamp)}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: kWarningRed,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: dataLength < 20,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: kWarningRed,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  kWarningRed.withOpacity(0.3),
                  kWarningRed.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Grafik untuk data yang sudah diagregasi
  Widget _buildAggregatedChart(List<AggregatedData> data, String labelFormat) {
    if (data.isEmpty) {
      return _buildEmptyChart();
    }

    final spots = <FlSpot>[];
    const double maxDisplayPpm = 500.0; // Cap for display
    for (int i = 0; i < data.length; i++) {
      // Clamp nilai PPM agar tidak melebihi maxY
      final double clampedPpm = data[i].avgPpm.clamp(0, maxDisplayPpm).toDouble();
      spots.add(FlSpot(i.toDouble(), clampedPpm));
    }
    
    final stats = _calculateAggregatedStats(data);
    final dataLength = data.length;
    final interval = (dataLength / 6).ceil().toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: interval > 0 ? interval : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[index].label,
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        // Cap maxY at 500 PPM for better readability, extreme values will exceed the chart
        maxY: (stats['max']! * 1.1).clamp(100, 500),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < data.length) {
                  final item = data[index];
                  return LineTooltipItem(
                    'Avg: ${item.avgPpm.toStringAsFixed(1)} PPM\n${item.label}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: kPrimaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: kPrimaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withOpacity(0.3),
                  kPrimaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada data untuk periode ini',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
