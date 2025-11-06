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
  void _addWaterRecord(String userId) {
    final TextEditingController mlController = TextEditingController(text: '250');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Agua'),
          content: TextField(
            controller: mlController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cantidad (mL)',
              suffixText: 'mL',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final int? amount = int.tryParse(mlController.text);
                if (amount != null && amount > 0) {
                  try {
                    await context.read<TrackingProvider>().addTrackingRecord(
                          userId: userId,
                          habitType: 'hidratacion',
                          value: amount,
                        );
                    if (mounted) Navigator.of(context).pop();
                  } catch (e) {
                    debugPrint('Error al registrar agua: $e');
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _addFoodRecord(String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Comida'),
          content: const Text('¿Deseas registrar una comida principal (ej. almuerzo)?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<TrackingProvider>().addTrackingRecord(
                        userId: userId,
                        habitType: 'alimentacion',
                        value: 1,
                      );
                  if (mounted) Navigator.of(context).pop();
                } catch (e) {
                  debugPrint('Error al registrar comida: $e');
                }
              },
              child: const Text('Registrar'),
            ),
          ],
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
      body: Column(
        children: [
          
          Text(
            'Registros de Hoy',
            style: theme.textTheme.headlineSmall,
          ),
          const Divider(indent: 20, endIndent: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: context.watch<TrackingProvider>().getDailyTrackingStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Aún no hay registros hoy.'),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final habitType = data['habit_type'] ?? 'general';
                    final value = data['value'] ?? 0;
                    
                    IconData icon;
                    String title;
                    switch (habitType) {
                      case 'hidratacion':
                        icon = Icons.water_drop;
                        title = '$value mL de agua';
                        break;
                      case 'alimentacion':
                        icon = Icons.restaurant;
                        title = 'Comida registrada';
                        break;
                      default:
                        icon = Icons.check;
                        title = 'Hábito registrado';
                    }
                    
                    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                    final timeString = timestamp != null
                        ? DateFormat('HH:mm').format(timestamp)
                        : '??:??';

                    return ListTile(
                      leading: Icon(icon, color: theme.colorScheme.primary),
                      title: Text(title),
                      subtitle: Text('Tipo: $habitType'),
                      trailing: Text(timeString),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addWaterRecord(userId),
                  icon: const Icon(Icons.water_drop),
                  label: const Text('Agua'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _addFoodRecord(userId),
                  icon: const Icon(Icons.restaurant),
                  label: const Text('Comida'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}