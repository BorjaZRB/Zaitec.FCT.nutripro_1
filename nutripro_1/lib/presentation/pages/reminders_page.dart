import 'package:flutter/material.dart';
import 'package:nutripro_1/services/notification_service.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
    // Mostrar diálogo de permisos después de que la UI esté lista solo si
    // el usuario NO ha aceptado aún los permisos.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final accepted = await _notificationService.isNotificationsAccepted();
        if (!accepted) {
          _showPermissionsDialog();
        }
      } catch (e) {
        // En caso de error, no bloquear la UI
      }
    });
  }

  /// Muestra un diálogo para solicitar activar notificaciones
  void _showPermissionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Activar Notificaciones'),
        content: const Text(
          'Para que funcionen los recordatorios, necesitamos permiso para enviar notificaciones.\n\n¿Deseas activarlas ahora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Después'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Solicitar permisos
              await _notificationService.requestNotificationPermissions();
              // Guardar que el usuario aceptó (para no mostrar el diálogo otra vez)
              await _notificationService.setNotificationsAccepted(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permisos de notificación solicitados ✓'),
                ),
              );
            },
            child: const Text(
              'Activar',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  /// Carga los recordatorios guardados desde SharedPreferences
  Future<void> _loadReminders() async {
    try {
      final loadedReminders = await _notificationService.loadReminders();
      setState(() {
        reminders = loadedReminders.isEmpty 
            ? _getDefaultReminders() 
            : loadedReminders;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar recordatorios: $e');
      setState(() {
        reminders = _getDefaultReminders();
        _isLoading = false;
      });
    }
    
    // Inicializar el servicio sin esperar bloqueante
    _initializeNotificationsAsync();
  }

  /// Recordatorios por defecto si no hay guardados
  List<Map<String, dynamic>> _getDefaultReminders() {
    return [
      {
        'id': 1,
        'title': 'Recordatorio de Agua',
        'subtitle': 'Todos los días a las 9:00 AM',
        'hour': 9,
        'minute': 0,
        'enabled': true,
      },
      {
        'id': 2,
        'title': 'Recordatorio de Comida',
        'subtitle': 'Todos los días a la 1:00 PM',
        'hour': 13,
        'minute': 0,
        'enabled': false,
      },
    ];
  }

  /// Inicializa notificaciones en background sin bloquear la UI.
  void _initializeNotificationsAsync() {
    Future.microtask(() async {
      try {
        await _notificationService.init(null);
      } catch (e) {
        print('Error al inicializar notificaciones: $e');
      }
    });
  }

  void _showAddReminderDialog() {
    TimeOfDay selectedTime = TimeOfDay.now();
    String reminderTitle = '';
    String reminderBody = '';
    bool isDaily = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nuevo Recordatorio'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Campo para el título
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Título del Recordatorio',
                        hintText: 'Ej: Beber agua',
                      ),
                      onChanged: (value) => reminderTitle = value,
                    ),
                    const SizedBox(height: 16),

                    // Campo para la descripción
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        hintText: 'Ej: Recuerda hidratarte',
                      ),
                      onChanged: (value) => reminderBody = value,
                    ),
                    const SizedBox(height: 16),

                    // Selector de hora
                    Row(
                      children: [
                        const Text('Hora: '),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (time != null) {
                              setDialogState(() => selectedTime = time);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(selectedTime.format(context)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Selector de tipo (diario/horario)
                    DropdownButton<bool>(
                      value: isDaily,
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => isDaily = value);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: true,
                          child: Text('Recordatorio Diario'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Recordatorio Horario'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    if (reminderTitle.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor ingresa un título'),
                        ),
                      );
                      return;
                    }

                    try {
                      // Programar el recordatorio
                      if (isDaily) {
                        await _notificationService.scheduleDailyReminder(
                          reminders.length + 1,
                          reminderTitle,
                          reminderTitle,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      } else {
                        await _notificationService.scheduleHourlyReminder();
                      }

                      // Agregar a la lista
                      setState(() {
                        reminders.add({
                          'id': reminders.length + 1,
                          'title': reminderTitle,
                          'subtitle': isDaily
                              ? 'Todos los días a las ${selectedTime.format(context)}'
                              : 'Cada hora',
                          'hour': selectedTime.hour,
                          'minute': selectedTime.minute,
                          'enabled': true,
                        });
                      });

                      // Guardar en SharedPreferences
                      await _notificationService.saveReminders(reminders);

                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Recordatorio configurado ✓'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
        actions: [
          IconButton(
            tooltip: 'Probar notificación inmediata',
            icon: const Icon(Icons.notifications_active),
            onPressed: () async {
              try {
                await _notificationService.showNotification('Prueba', 'Notificación inmediata');
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notificación enviada')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al enviar: $e')),
                );
              }
            },
          ),
          IconButton(
            tooltip: 'Ver notificaciones pendientes',
            icon: const Icon(Icons.schedule),
            onPressed: () async {
              try {
                final pending = await _notificationService.getPendingNotifications();
                if (!mounted) return;
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Pendientes'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: pending.isEmpty
                              ? [const Text('No hay notificaciones pendientes')]
                              : pending.map((p) => Text('id:${p.id} title:${p.title} payload:${p.payload}')).toList(),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
                    ],
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
          ),
        ],
      ),
      body: reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alarm_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay recordatorios',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return Dismissible(
                  key: Key('reminder_${reminder['id']}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete_forever, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    // Confirmación simple
                    return await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Eliminar recordatorio'),
                        content: const Text('¿Deseas eliminar este recordatorio?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (direction) async {
                    // Cancelar la notificación programada
                    try {
                      final id = reminder['id'] as int;
                      await _notificationService.cancel(id);
                    } catch (e) {
                      // Ignorar errores de cancelación
                    }

                    setState(() {
                      reminders.removeAt(index);
                    });

                    // Guardar cambios
                    await _notificationService.saveReminders(reminders);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recordatorio eliminado')),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          reminder['enabled'] ? Icons.alarm_on : Icons.alarm_off,
                        ),
                        title: Text(reminder['title']),
                        subtitle: Text(reminder['subtitle']),
                        trailing: IconButton(
                          icon: Icon(
                            reminder['enabled']
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: reminder['enabled'] ? Colors.green[400] : Colors.grey[400],
                          ),
                          onPressed: () async {
                            setState(() {
                              reminder['enabled'] = !reminder['enabled'];
                            });
                            // Persistir el cambio de estado
                            await _notificationService.saveReminders(reminders);
                          },
                        ),
                        onTap: () {
                          // TODO: Editar recordatorio
                        },
                      ),
                      const Divider(),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        tooltip: 'Añadir Recordatorio',
        child: const Icon(Icons.add),
      ),
    );
  }
}
