import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TrackingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Agrega un registro al documento del día actual
  Future<void> addTrackingRecord({
    required String userId,
    required String habitType,
    required int value,
  }) async {
    try {
      // Obtener fecha y hora actuales
      DateTime now = DateTime.now();
      String dateKey = DateFormat('yyyy-MM-dd').format(now);
      String timeStr = DateFormat('HH:mm').format(now);
      String dayLabel = DateFormat('dd/MM').format(now);

      // Referencia al documento del día
      DocumentReference dayDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('tracking_daily')
          .doc(dateKey);

      // Agregar registro al array del día
      await dayDoc.set({
        'date': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
        'day_label': dayLabel,
        'records': FieldValue.arrayUnion([
          {
            'time': timeStr,
            'habit_type': habitType,
            'value': value,
            'timestamp': Timestamp.now(),
          },
        ]),
      }, SetOptions(merge: true));

      debugPrint('✅ Registro guardado: $dateKey - $habitType: $value');
    } catch (e) {
      debugPrint('❌ Error al agregar el registro: $e');
      rethrow;
    }
  }

  /// Elimina un registro específico del documento del día
  Future<void> deleteTrackingRecord({
    required String userId,
    required Map<String, dynamic> record,
    required String dateKey,
  }) async {
    try {
      DocumentReference dayDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('tracking_daily')
          .doc(dateKey);

      await dayDoc.update({
        'records': FieldValue.arrayRemove([record]),
      });

      debugPrint('🗑️ Registro eliminado: $dateKey');
    } catch (e) {
      debugPrint('❌ Error al eliminar el registro: $e');
      rethrow;
    }
  }

  /// Stream del documento del día actual para mostrar registros en tiempo real
  Stream<DocumentSnapshot> getDailyTrackingStream(String userId) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tracking_daily')
        .doc(today)
        .snapshots();
  }

  /// Obtiene estadísticas del día actual y datos históricos en una sola consulta
  Future<Map<String, dynamic>> getDailyStats(
    String userId, {
    int days = 7,
  }) async {
    try {
      DateTime now = DateTime.now();
      String todayKey = DateFormat('yyyy-MM-dd').format(now);

      // 0. Fetch User Profile for Targets
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      int targetCalories = (userData?['calorieGoal'] as num?)?.toInt() ?? 2000;
      double targetWaterLiters =
          (userData?['waterGoal'] as num?)?.toDouble() ?? 2.0;
      int targetMeals = (userData?['mealsPerDay'] as num?)?.toInt() ?? 3;

      double targetWaterGlasses = targetWaterLiters / 0.25; // 250ml per glass

      // 1. Determinar rango de fechas (hoy - 30 días para cubrir mes y semana)
      DateTime startDate = now.subtract(const Duration(days: 30));
      DateTime endDate = now;

      // 2. Fetch en batch de todos los documentos necesarios
      Map<String, Map<String, dynamic>> allData = await _getRecordsForRange(
        userId,
        startDate,
        endDate,
      );

      // 3. Procesar datos de HOY
      int totalCalories = 0;
      int totalWaterMl = 0;
      int mealCount = 0;

      if (allData.containsKey(todayKey)) {
        final dayData = allData[todayKey]!;
        final records = dayData['records'] as List<dynamic>? ?? [];
        for (var record in records) {
          final habitType = record['habit_type'];
          final value = (record['value'] ?? 0) as int;
          if (habitType == 'alimentacion') {
            totalCalories += value;
            mealCount++;
          } else if (habitType == 'hidratacion') {
            totalWaterMl += value;
          }
        }
      }

      double waterGlasses = totalWaterMl / 250.0;

      // Calcular progreso ponderado con metas dinámicas:
      // 50% Calorías
      // 30% Agua
      // 20% Comidas
      double calProgress = (totalCalories / targetCalories.toDouble()).clamp(
        0.0,
        1.0,
      );
      double waterProgress = (waterGlasses / targetWaterGlasses).clamp(
        0.0,
        1.0,
      );
      double mealProgress = (mealCount / targetMeals.toDouble()).clamp(
        0.0,
        1.0,
      );

      double goalsProgress =
          (calProgress * 0.5) + (waterProgress * 0.3) + (mealProgress * 0.2);

      // 4. Calcular datos SEMANALES (últimos 7 días) en memoria
      List<double> weeklyCalories = [];
      List<double> weeklyWater = [];
      List<double> weeklyMeals = [];

      for (int i = 6; i >= 0; i--) {
        DateTime targetDay = now.subtract(Duration(days: i));
        String key = DateFormat('yyyy-MM-dd').format(targetDay);

        int dayCal = 0;
        int dayWater = 0;
        int dayMeals = 0;

        if (allData.containsKey(key)) {
          final records = allData[key]!['records'] as List<dynamic>? ?? [];
          for (var record in records) {
            final type = record['habit_type'];
            final val = (record['value'] ?? 0) as int;
            if (type == 'alimentacion') {
              dayCal += val;
              dayMeals++;
            } else if (type == 'hidratacion') {
              dayWater += val;
            }
          }
        }
        weeklyCalories.add(dayCal.toDouble());
        weeklyWater.add(dayWater / 250.0);
        weeklyMeals.add(dayMeals.toDouble());
      }

      // 5. Calcular datos MENSUALES (últimas 4 semanas) en memoria
      List<double> monthlyData = [];
      for (int week = 3; week >= 0; week--) {
        int weeklyCalSum = 0;
        int daysCount = 0;
        for (int day = 0; day < 7; day++) {
          int daysAgo = (week * 7) + day;
          DateTime targetDay = now.subtract(Duration(days: daysAgo));
          String key = DateFormat('yyyy-MM-dd').format(targetDay);

          if (allData.containsKey(key)) {
            final records = allData[key]!['records'] as List<dynamic>? ?? [];
            for (var record in records) {
              if (record['habit_type'] == 'alimentacion') {
                weeklyCalSum += ((record['value'] ?? 0) as int);
              }
            }
          }
          daysCount++;
        }
        monthlyData.add(
          daysCount > 0 ? (weeklyCalSum / daysCount).roundToDouble() : 0.0,
        );
      }

      debugPrint('📊 Stats cargadas en batch (1 query).');

      return {
        'calories': totalCalories,
        'water': waterGlasses,
        'meals': mealCount,
        'goalsProgress': goalsProgress,
        'weeklyCaloriesData': weeklyCalories,
        'weeklyWaterData': weeklyWater,
        'weeklyMealsData': weeklyMeals,
        'monthlyData': monthlyData,
        'goalCalories': targetCalories,
        'goalWater': targetWaterGlasses,
        'goalMeals': targetMeals,
      };
    } catch (e) {
      debugPrint('❌ Error al obtener estadísticas diarias: $e');
      return {
        'calories': 0,
        'water': 0.0,
        'meals': 0,
        'goalsProgress': 0.0,
        'weeklyCaloriesData': List.filled(7, 0.0),
        'weeklyWaterData': List.filled(7, 0.0),
        'weeklyMealsData': List.filled(7, 0.0),
        'monthlyData': List.filled(4, 0.0),
        'goalCalories': 2000,
        'goalWater': 8.0,
        'goalMeals': 3,
      };
    }
  }

  /// Helper para obtener rango de documentos en una sola query
  Future<Map<String, Map<String, dynamic>>> _getRecordsForRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      String startKey = DateFormat('yyyy-MM-dd').format(start);
      String endKey = DateFormat('yyyy-MM-dd').format(end);

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tracking_daily')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endKey)
          .get();

      Map<String, Map<String, dynamic>> results = {};
      for (var doc in querySnapshot.docs) {
        results[doc.id] = doc.data();
      }
      return results;
    } catch (e) {
      debugPrint('❌ Error batch fetch: $e');
      return {};
    }
  }

  /// Limpia datos antiguos (> 30 días)
  Future<void> cleanupOldData(String userId) async {
    try {
      DateTime cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      String cutoffDateStr = DateFormat('yyyy-MM-dd').format(cutoffDate);

      debugPrint('🗑️ Limpiando datos anteriores a: $cutoffDateStr');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tracking_daily')
          .where(FieldPath.documentId, isLessThan: cutoffDateStr)
          .get();

      debugPrint('🗑️ Encontrados ${snapshot.docs.length} documentos antiguos');

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
        debugPrint('🗑️ Borrado: ${doc.id}');
      }

      debugPrint('✅ Limpieza completada');
    } catch (e) {
      debugPrint('❌ Error en limpieza: $e');
    }
  }

  /// Obtiene el historial de registros de los últimos N días como una lista plana
  Future<List<Map<String, dynamic>>> getTrackingHistory(
    String userId, {
    int days = 7,
  }) async {
    try {
      List<Map<String, dynamic>> allRecords = [];
      DateTime now = DateTime.now();

      for (int i = 0; i < days; i++) {
        DateTime targetDay = now.subtract(Duration(days: i));
        String dateKey = DateFormat('yyyy-MM-dd').format(targetDay);

        DocumentSnapshot dayDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('tracking_daily')
            .doc(dateKey)
            .get();

        if (dayDoc.exists) {
          final data = dayDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('records')) {
            List<dynamic> records = data['records'] ?? [];
            for (var record in records) {
              if (record is Map<String, dynamic>) {
                // Añadir fecha al registro para referencia si es necesario
                Map<String, dynamic> recordWithDate = Map.from(record);
                recordWithDate['date_key'] = dateKey;
                allRecords.add(recordWithDate);
              }
            }
          }
        }
      }

      return allRecords;
    } catch (e) {
      debugPrint('❌ Error al obtener historial de tracking: $e');
      return [];
    }
  }
}
