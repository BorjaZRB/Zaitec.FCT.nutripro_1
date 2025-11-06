import 'package:flutter/material.dart';
import 'package:nutripro_1/data/models/recommendation_model.dart';
import 'package:nutripro_1/data/providers/recommendation_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final String userId;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.userId,
  });

  IconData _getIconForType(RecommendationType type) {
    switch (type) {
      case RecommendationType.hidratacion:
        return Icons.water_drop;
      case RecommendationType.alimentacion:
        return Icons.restaurant_menu;
      case RecommendationType.habitos:
        return Icons.directions_run;
      default:
        return Icons.lightbulb;
    }
  }

  Color _getColorForPriority(
      RecommendationPriority priority, BuildContext context) {
    switch (priority) {
      case RecommendationPriority.alta:
        return Theme.of(context).colorScheme.error;
      case RecommendationPriority.media:
        return Theme.of(context).colorScheme.secondary;
      case RecommendationPriority.baja:
        return Theme.of(context).colorScheme.primary;
      }
  }

  String _formatDate(Timestamp timestamp) {
    return DateFormat('dd/MM/yyyy', 'es_ES').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _getColorForPriority(recommendation.priority, context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: priorityColor.withOpacity(0.5), width: 1),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: priorityColor.withOpacity(0.1),
          child: Icon(
            _getIconForType(recommendation.type),
            color: priorityColor,
          ),
        ),
        title: Text(
          recommendation.message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${recommendation.priority.toString().split('.').last.toUpperCase()} · ${_formatDate(recommendation.timestamp)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: priorityColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.check_circle_outline,
              color: theme.colorScheme.primary),
          tooltip: 'Marcar como leída',
          onPressed: () {
            context
                .read<RecommendationProvider>()
                .markRecommendationAsRead(userId, recommendation.id);
          },
        ),
      ),
    );
  }
}