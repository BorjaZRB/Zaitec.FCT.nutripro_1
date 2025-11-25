import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutripro_1/data/providers/tracking_provider.dart';
import 'package:nutripro_1/presentation/widgets/dashboard_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  Future<Map<String, dynamic>>? _statsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
    _cleanupOldDataOnce(); // Limpiar datos antiguos una vez al día
  }

  void _loadData() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      setState(() {
        _statsFuture = context.read<TrackingProvider>().getDailyStats(userId);
      });
    }
  }

  Future<void> _cleanupOldDataOnce() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final prefs = await SharedPreferences.getInstance();
      final lastCleanup = prefs.getString('last_cleanup_date');
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (lastCleanup != today) {
        debugPrint('🧹 Iniciando limpieza de datos antiguos...');
        await context.read<TrackingProvider>().cleanupOldData(userId);
        await prefs.setString('last_cleanup_date', today);
        debugPrint('✅ Fecha de última limpieza guardada: $today');
      } else {
        debugPrint('⏭️ Limpieza ya realizada hoy ($today)');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Usuario no autenticado.')),
      );
    }

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final data =
              snapshot.data ??
              {
                "calories": 0,
                "meals": 0,
                "water": 0.0,
                "goalsProgress": 0.0,
                "weeklyCaloriesData": <double>[],
                "weeklyWaterData": <double>[],
                "weeklyMealsData": <double>[],
                "monthlyData": <double>[],
              };

          final weeklyCalories = (data['weeklyCaloriesData'] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList();
          final weeklyWater = (data['weeklyWaterData'] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList();
          final weeklyMeals = (data['weeklyMealsData'] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList();
          final monthly = (data['monthlyData'] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              _loadData();
              await _statsFuture;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: DashboardWidget(
                  calories: (data['calories'] ?? 0) as int,
                  meals: (data['meals'] ?? 0) as int,
                  water: ((data['water'] ?? 0) as num).toDouble(),
                  goalsProgress: ((data['goalsProgress'] ?? 0) as num)
                      .toDouble(),
                  weeklyCaloriesData: weeklyCalories,
                  weeklyWaterData: weeklyWater,
                  weeklyMealsData: weeklyMeals,
                  monthlyData: monthly,
                  goalCalories: (data['goalCalories'] ?? 2000) as int,
                  goalWater: ((data['goalWater'] ?? 2.0) as num).toDouble(),
                  goalMeals: (data['goalMeals'] ?? 3) as int,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
