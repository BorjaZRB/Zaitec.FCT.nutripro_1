import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutripro_1/data/providers/tracking_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  void _showAddRecordSheet(BuildContext context, String userId, String type) {
    final isWater = type == 'hidratacion';
    final TextEditingController controller = TextEditingController(
      text: isWater ? '250' : '500',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isWater ? 'Registrar Agua' : 'Registrar Comida',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: isWater ? 'Cantidad (mL)' : 'Calorías (kcal)',
                  suffixText: isWater ? 'mL' : 'kcal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(
                    isWater ? Icons.water_drop : Icons.local_fire_department,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isWater)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _QuickAddButton(
                      label: '+250',
                      onTap: () => controller.text = '250',
                    ),
                    _QuickAddButton(
                      label: '+500',
                      onTap: () => controller.text = '500',
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final int? amount = int.tryParse(controller.text);
                  if (amount != null && amount > 0) {
                    try {
                      await context.read<TrackingProvider>().addTrackingRecord(
                        userId: userId,
                        habitType: type,
                        value: amount,
                      );
                      if (mounted) Navigator.of(context).pop();
                    } catch (e) {
                      debugPrint('Error al registrar: $e');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Guardar Registro'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Error: Usuario no autenticado.'));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSummaryHeader(context, userId),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: context
                      .watch<TrackingProvider>()
                      .getDailyTrackingStream(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return _buildEmptyState(context);
                    }

                    final dayData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    if (dayData == null || !dayData.containsKey('records')) {
                      return _buildEmptyState(context);
                    }

                    final records = List<Map<String, dynamic>>.from(
                      dayData['records'] ?? [],
                    );

                    if (records.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    // Ordenar por hora (más reciente primero)
                    records.sort((a, b) {
                      final timeA = a['time'] as String? ?? '00:00';
                      final timeB = b['time'] as String? ?? '00:00';
                      return timeB.compareTo(timeA);
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.delete,
                              color: theme.colorScheme.onError,
                            ),
                          ),
                          onDismissed: (direction) async {
                            final todayKey = DateFormat(
                              'yyyy-MM-dd',
                            ).format(DateTime.now());
                            final trackingProvider = context
                                .read<TrackingProvider>();
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );

                            await trackingProvider.deleteTrackingRecord(
                              userId: userId,
                              record: record,
                              dateKey: todayKey,
                            );

                            scaffoldMessenger.hideCurrentSnackBar();
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: const Text('Registro eliminado'),
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'Deshacer',
                                  onPressed: () {
                                    trackingProvider.addTrackingRecord(
                                      userId: userId,
                                      habitType: record['habit_type'],
                                      value: record['value'],
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          child: _buildRecordCard(context, record, theme),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'water',
            onPressed: () =>
                _showAddRecordSheet(context, userId, 'hidratacion'),
            backgroundColor: theme.colorScheme.primary,
            child: Icon(Icons.water_drop, color: theme.colorScheme.onPrimary),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'food',
            onPressed: () =>
                _showAddRecordSheet(context, userId, 'alimentacion'),
            backgroundColor: theme.colorScheme.secondary,
            child: Icon(Icons.restaurant, color: theme.colorScheme.onSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, String userId) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de Hoy',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, d MMMM', 'es_ES').format(DateTime.now()),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Comienza tu día!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registra tu primera comida o vaso de agua.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    Map<String, dynamic> record,
    ThemeData theme,
  ) {
    final habitType = record['habit_type'] ?? 'general';
    final value = record['value'] ?? 0;
    final timeString = record['time'] ?? '??:??';

    final isWater = habitType == 'hidratacion';
    final color = isWater
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;
    final icon = isWater ? Icons.water_drop : Icons.restaurant;
    final title = isWater ? '$value mL' : '$value kcal';
    final subtitle = isWater ? 'Hidratación' : 'Alimentación';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          timeString,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
