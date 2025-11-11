import 'package:flutter/material.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),

      // Usamos un ListView para mostrar el historial
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Ejemplo de un recordatorio en el historial
          ListTile(
            leading: const Icon(Icons.alarm_on),
            title: const Text('Recordatorio de Agua'),
            subtitle: const Text('Todos los días a las 9:00 AM'),
            trailing: Icon(Icons.check_circle, color: Colors.green[400]),
            onTap: () {
              // Aquí se podría editar el recordatorio
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.alarm),
            title: const Text('Recordatorio de Comida'),
            subtitle: const Text('Todos los días a la 1:00 PM'),
            trailing: Icon(Icons.check_circle_outline, color: Colors.grey[400]),
            onTap: () {},
          ),
          const Divider(),

          // Puedes añadir más ListTiles aquí para más historial
        ],
      ),

      // Para añadir nuevos recordatorios
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Aquí irá la lógica para mostrar un diálogo
          // y crear un nuevo recordatorio (Tarea MSG-003)
        },
        tooltip: 'Añadir Recordatorio',
        child: const Icon(Icons.add),
      ),
    );
  }
}
