import 'package:flutter/material.dart';
import 'package:nutripro_1/presentation/pages/admin/admin_config_tab.dart';
import 'package:nutripro_1/presentation/pages/admin/admin_register_tab.dart';
import 'package:nutripro_1/presentation/pages/admin/admin_user_list_tab.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    AdminRegisterTab(),
    AdminUserListTab(),
    AdminConfigTab(),
  ];

  static const List<String> _pageTitles = [
    'Registrar Usuario',
    'Lista de Usuarios',
    'Ajustes de Administrador',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        // El botón de logout ahora estará en la pestaña de configuración
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     tooltip: 'Cerrar Sesión',
        //     onPressed: () async {
        //       await context.read<AuthProvider>().signOut();
        //     },
        //   ),
        // ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Registrar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt), // Icono de 3 líneas
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}