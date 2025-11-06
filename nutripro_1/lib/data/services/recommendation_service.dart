import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutripro_1/data/models/recommendation_model.dart';
import 'package:nutripro_1/data/providers/recommendation_provider.dart';

class RecommendationService {
  final RecommendationProvider _recommendationProvider;

  RecommendationService(this._recommendationProvider);

  Future<void> analyzeUserData(
    String userId,
    List<QueryDocumentSnapshot> trackingDocs,
  ) async {
    debugPrint('Iniciando análisis de ${trackingDocs.length} registros...');

    final Map<String, List<Map<String, dynamic>>> groupedData = {
      'hidratacion': [],
      'alimentacion': [],
      'habitos': [],
    };

    for (var doc in trackingDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final type = data['habit_type'];
      if (groupedData.containsKey(type)) {
        groupedData[type]!.add(data);
      }
    }

    await _analyzeHydration(userId, groupedData['hidratacion']!);
    await _analyzeNutrition(userId, groupedData['alimentacion']!);
    
    debugPrint('Análisis completado.');
  }

  Future<void> _analyzeHydration(
      String userId, List<Map<String, dynamic>> hydrationData) async {
    // ---- EJEMPLO DE LÓGICA REAL (Comentada) ----
    // if (hydrationData.isEmpty) return;
    // double totalML = 0;
    // hydrationData.forEach((data) => totalML += (data['value'] as int));
    // double averageML = totalML / hydrationData.length; // O dividir por días únicos
    
    // if (averageML < 1500) { ... }
    // ---- FIN LÓGICA REAL ----

    if (hydrationData.length < 2) {
      final rec = Recommendation(
        id: '',
        userId: userId,
        message:
            'Hemos notado que registras poca agua. ¡Intenta beber y registrar al menos 2 litros al día!',
        type: RecommendationType.hidratacion,
        priority: RecommendationPriority.media,
        timestamp: Timestamp.now(),
        isRead: false,
      );
      await _recommendationProvider.addRecommendation(userId, rec);
    }
  }

  Future<void> _analyzeNutrition(
      String userId, List<Map<String, dynamic>> nutritionData) async {
    if (nutritionData.isEmpty) {
      final rec = Recommendation(
        id: '',
        userId: userId,
        message:
            'No hemos visto registros de comidas recientes. ¡Recuerda añadir tus comidas para un mejor seguimiento!',
        type: RecommendationType.alimentacion,
        priority: RecommendationPriority.baja,
        timestamp: Timestamp.now(),
        isRead: false,
      );
      await _recommendationProvider.addRecommendation(userId, rec);
    }
  }
}