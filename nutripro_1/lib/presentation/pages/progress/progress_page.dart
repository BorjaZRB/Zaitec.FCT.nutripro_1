import 'package:flutter/material.dart';
import 'package:nutripro_1/presentation/widgets/dashboard_widget.dart';

class ProgressPage extends StatelessWidget {
  final Stream<Map<String, dynamic>>? stream;

  const ProgressPage({super.key, this.stream});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: StreamBuilder<Map<String, dynamic>>(
        stream: stream,
        builder: (context, snap) {
          // Datos por defecto si el stream aún no tiene datos
          final data = snap.data ?? {
            "calories": 2000,
            "meals": 3,
            "water": 3,
            "goalsProgress": 0.5,
            "weeklyData": [50.0, 60.0, 55.0, 70.0, 65.0, 75.0, 80.0],
            "monthlyData": [60.0, 70.0, 65.0, 80.0],
          };

          final weekly = (data['weeklyData'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();
          final monthly = (data['monthlyData'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
        
              child: DashboardWidget(
                calories: (data['calories'] ?? 0) as int,
                meals: (data['meals'] ?? 0) as int,
                water: ((data['water'] ?? 0) as num).toDouble(),
                goalsProgress: ((data['goalsProgress'] ?? 0) as num).toDouble(),
                weeklyData: weekly,
                monthlyData: monthly,
              ),
            ),
          );
        },
      ),
    );
  }
}
