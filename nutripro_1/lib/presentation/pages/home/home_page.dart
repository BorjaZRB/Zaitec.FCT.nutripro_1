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

  static const List<Widget> _pages = <Widget>[
    DailyMenuPage(),
    ProgressPage(),
    TrackingPage(),
    ProfilePage(),
    ConfPage(),
  ];

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(_titles[_selectedIndex]),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Menú',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progreso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config.',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}