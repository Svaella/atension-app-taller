import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../widgets/user_menu_button.dart';
import '../../services/profile_service.dart';
import 'tus_datos_screen.dart';
import 'registro_screen.dart';
import '../information_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _maybeFetchProfile(_index));
  }

  void _maybeFetchProfile(int index) {
    debugPrint('🔍 _maybeFetchProfile llamado con index=$index');
    if (!mounted || index != 0) {
      debugPrint('⚠️ No fetch: mounted=$mounted, index=$index');
      return;
    }
    final profile = context.read<ProfileService>();
    debugPrint('📊 ProfileService: summary=${profile.summary != null}, isLoading=${profile.isLoading}');
    if (profile.summary == null && !profile.isLoading) {
      debugPrint('🚀 Ejecutando profile.fetch()');
      profile.fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      TusDatosScreen(),
      RegistroScreen(),
      InformationScreen(embedded: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'aTensión',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => context.push('/about'),
          ),
          const UserMenuButton(),
        ],
      ),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.botttomBar 
                : Colors.white,
            selectedItemColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimary
                : AppColors.primaryRed,
            unselectedItemColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white60
                : Colors.grey[600],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) {
            setState(() => _index = i);
            _maybeFetchProfile(i);
          },
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tus Datos'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Registro'),
            BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Información'),
          ],
        ),
      ),
    );
  }
}