import 'package:flutter/material.dart';

class ChartDataProvider extends ChangeNotifier {
  List<ChartData> chartData;

  ChartDataProvider(List<Map<String, dynamic>> stats)
      : chartData = stats
            .map((e) => ChartData(
                  e['x']?.toString() ?? 'Unknown',
                  (e['y'] as num?)?.toDouble() ?? 0,
                  0,
                ))
            .toList() {
    print('Chart Data: $chartData');
  }

  void updateData(List<Map<String, dynamic>> stats) {
    chartData = stats
        .map((e) => ChartData(
              e['x']?.toString() ?? 'Unknown',
              (e['y'] as num?)?.toDouble() ?? 0,
              0,
            ))
        .toList();
    print('Updated Chart Data: $chartData');
    notifyListeners();
  }

  @override
  void dispose() {
    chartData.clear();
    super.dispose();
  }
}

class ChartData {
  ChartData(this.x, this.y, this.y2);

  final String x;
  final double y;
  final double y2;

  @override
  String toString() => 'ChartData(x: $x, y: $y, y2: $y2)';
}
