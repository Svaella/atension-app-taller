import 'package:flutter/material.dart';
import '../widgets/top_navigation_menu.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('aTensión'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(52),
          child: TopNavigationMenu(activeTab: ''),
        ),
      ),
      body: const Center(
        child: Text("Aquí irá la información del usuario", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
