import 'package:cloud_firestore/cloud_firestore.dart';

enum RecommendationType { alimentacion, hidratacion, habitos, general }
enum RecommendationPriority { alta, media, baja }

class Recommendation {
  final String id;
  final String userId;
  final String message;
  final RecommendationType type;
  final RecommendationPriority priority;
  final Timestamp timestamp;
  final bool isRead;

  Recommendation({
    required this.id,
    required this.userId,
    required this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
  });

  String get _typeToString => type.toString().split('.').last;
  String get _priorityToString => priority.toString().split('.').last;

  static RecommendationType _typeFromString(String typeStr) {
    return RecommendationType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => RecommendationType.general,
    );
  }

  static RecommendationPriority _priorityFromString(String priorityStr) {
    return RecommendationPriority.values.firstWhere(
      (e) => e.toString().split('.').last == priorityStr,
      orElse: () => RecommendationPriority.baja,
    );
  }

  factory Recommendation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Recommendation(
      id: doc.id,
      userId: data['userId'] ?? '',
      message: data['message'] ?? 'Mensaje no disponible.',
      type: _typeFromString(data['type'] ?? 'general'),
      priority: _priorityFromString(data['priority'] ?? 'baja'),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'message': message,
      'type': _typeToString,
      'priority': _priorityToString,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}