import 'package:flutter/material.dart';
import 'package:nutripro_1/data/models/user_profile_model.dart';
import 'package:nutripro_1/data/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';

class AdminUserListTab extends StatefulWidget {
  const AdminUserListTab({super.key});

  @override
  State<AdminUserListTab> createState() => _AdminUserListTabState();
}

class _AdminUserListTabState extends State<AdminUserListTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = context.watch<UserProfileProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar por email o nombre',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<UserProfile>>(
            stream: userProfileProvider.getAllUsersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No se encontraron usuarios.'));
              }

              final allUsers = snapshot.data!;
              final filteredUsers = allUsers.where((user) {
                final emailMatch = user.email.toLowerCase().contains(_searchQuery);
                final nameMatch = (user.name ?? '').toLowerCase().contains(_searchQuery);
                return emailMatch || nameMatch;
              }).toList();

              return ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(user.isAdmin ? 'A' : 'U'),
                      ),
                      title: Text(user.name ?? 'Sin Nombre'),
                      subtitle: Text(user.email),
                      trailing: user.isAdmin
                          ? Chip(
                              label: Text('Admin', style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                            )
                          : null,
                      onTap: () {
                        // Aquí se podría navegar a una página de detalle/edición
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}