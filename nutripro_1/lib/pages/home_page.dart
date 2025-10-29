import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final pages = [
    const Center(child: Text('Novedades')),
    const Center(child: Text('Mi plan')),
    const Center(child: Text('Mis objetivos')),
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
        title: const Text('NutriPro'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF4CAF50),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Novedades"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Mi plan"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Mis objetivos"),
        ],
      ),
    );
  }
}