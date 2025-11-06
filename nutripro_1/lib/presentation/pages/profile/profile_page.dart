import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutripro_1/data/models/recommendation_model.dart';
import 'package:nutripro_1/data/models/user_profile_model.dart';
import 'package:nutripro_1/data/providers/recommendation_provider.dart';
import 'package:nutripro_1/data/providers/tracking_provider.dart';
import 'package:nutripro_1/data/providers/user_profile_provider.dart';
import 'package:nutripro_1/data/services/recommendation_service.dart';
import 'package:nutripro_1/presentation/widgets/recommendation_card.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoadingAnalysis = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES');
  }

  String _calculateIMC(double? heightCm, double? weightKg) {
    if (heightCm == null || weightKg == null || heightCm <= 0 || weightKg <= 0) {
      return 'N/A';
    }
    try {
      final double heightM = heightCm / 100;
      final double imc = weightKg / pow(heightM, 2);
      return imc.toStringAsFixed(1);
    } catch (e) {
      return 'N/A';
    }
  }

  Future<void> _runAnalysis(String userId) async {
    setState(() => _isLoadingAnalysis = true);

    try {
      final trackingProvider = context.read<TrackingProvider>();
      final recommendationProvider = context.read<RecommendationProvider>();

      final recommendationService = RecommendationService(recommendationProvider);

      final trackingHistory =
          await trackingProvider.getTrackingHistory(userId, days: 7);

      await recommendationService.analyzeUserData(userId, trackingHistory);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Análisis completado. Nuevas sugerencias generadas (si aplica).'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error durante el análisis: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAnalysis = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error: Usuario no encontrado.'),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<UserProfile?>(
        stream: context
            .watch<UserProfileProvider>()
            .getUserProfileStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar el perfil: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Perfil no encontrado.'));
          }

          final profile = snapshot.data!;
          final imc = _calculateIMC(profile.height, profile.weight);

          return ListView(
            children: [
              _buildProfileHeader(profile, imc, theme),

              _buildRecommendationsSection(user.uid, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile, String imc, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 100,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            profile.name ?? 'Sin nombre',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${profile.height?.toStringAsFixed(0) ?? 'N/A'} cm / ${profile.weight?.toStringAsFixed(1) ?? 'N/A'} Kg',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'IMC: $imc',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(String userId, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recomendaciones para ti',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),

          StreamBuilder<List<Recommendation>>(
            stream: context
                .watch<RecommendationProvider>()
                .getUnreadRecommendationsStream(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                        'Error al cargar recomendaciones: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      '¡Vas muy bien! No hay sugerencias nuevas por ahora.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final recommendations = snapshot.data!;
              
              return ListView.builder(
                itemCount: recommendations.length,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return RecommendationCard(
                    recommendation: recommendations[index],
                    userId: userId,
                  );
                },
              );
            },
          ),

          // Botón de Análisis
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: _isLoadingAnalysis
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () => _runAnalysis(userId),
                      icon: const Icon(Icons.analytics_outlined),
                      label: const Text('Analizar mis datos (Test)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}