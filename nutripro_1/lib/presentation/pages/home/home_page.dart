import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nutripro_1/presentation/pages/config/conf_page.dart';
import 'package:nutripro_1/presentation/pages/profile/profile_page.dart';
import 'package:nutripro_1/presentation/pages/daily_menu/daily_menu_page.dart';
import 'package:nutripro_1/presentation/pages/progress/progress_page.dart';
import 'package:nutripro_1/presentation/pages/traking/tracking_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;

  late StreamController<Map<String, dynamic>> _streamController;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

  
    _streamController = StreamController<Map<String, dynamic>>.broadcast();


    _streamController.add({
      "calories": 2000,
      "meals": 3,
      "water": 3,
      "goalsProgress": 0.5,
      "weeklyData": [50.0, 60.0, 55.0, 70.0, 65.0, 75.0, 80.0],
      "monthlyData": [60.0, 70.0, 65.0, 80.0],
    });

    _pages = [
      DailyMenuPage(),
      ProgressPage(stream: _streamController.stream),
      TrackingPage(),
      ProfilePage(),
      ConfPage(),
    ];
  }

  static const List<String> _titles = <String>[
    'Menú Diario',
    'Progreso',
    'Home',
    'Perfil',
    'Configuración',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  
  void updateUserData(Map<String, dynamic> newData) {
    _streamController.add(newData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AÑADIDO: El panel lateral (EndDrawer) para el formulario de contacto
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Importante para que no haya padding extra
          children: <Widget>[
            DrawerHeader(
              // Un encabezado simple para el Drawer
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Contactar Administrador',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            // AÑADIDO: El campo de 'Email'
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            // AÑADIDO: El campo de 'Asunto'
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Asunto',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            // AÑADIDO: El campo de 'Mensaje'
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Mensaje',
                  border: OutlineInputBorder(),
                  alignLabelWithHint:
                      true, // Alinea la etiqueta arriba para multilínea
                ),
                maxLines:
                    5, // Caja de texto para el mensaje, con múltiples líneas
                keyboardType: TextInputType.multiline,
              ),
            ),
            // AÑADIDO: El botón de 'Enviar'
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para enviar el mensaje
                  print('Mensaje enviado');
                  Navigator.pop(context); // Cierra el Drawer después de enviar
                },
                child: Text('Enviar Mensaje'),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        // MODIFICADO: Añadimos 'actions' para el botón de chat
        actions: [
          // CORRECCIÓN: Usamos un 'Builder' para obtener el 'context' correcto
          // que pueda encontrar el Scaffold y abrir el 'endDrawer'.
          Builder(
            builder: (BuildContext newContext) {
              return IconButton(
                icon: Icon(Icons.chat_bubble_outline),
                // Ahora usa 'newContext' para abrir el panel
                onPressed: () {
                  Scaffold.of(newContext).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Menú'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progreso',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config.'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
