import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../utils/colors.dart';

class UserMenuButton extends StatelessWidget {
  const UserMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.person, color: Colors.white),
      onPressed: () {
        _showUserMenu(context);
      },
    );
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Consumer<ThemeService>(
          builder: (context, themeService, child) {
            return Container(
              decoration: BoxDecoration(
                color: themeService.isDarkTheme ? AppColors.darkBackground : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              // Indicador visual superior
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Información del usuario
              Consumer2<AuthService, ThemeService>(
                builder: (context, authService, themeService, child) {
                  final user = authService.currentUser;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user != null ? '${user.nombre} ${user.apellidos}' : 'Usuario',
                                style: TextStyle(
                                  color: themeService.isDarkTheme ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'correo@ejemplo.com',
                                style: TextStyle(
                                  color: themeService.isDarkTheme ? Colors.white70 : Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const Divider(color: Colors.grey, thickness: 0.5),
              
              // Opción cambiar tema
              ListTile(
                leading: Icon(Icons.palette, color: themeService.isDarkTheme ? Colors.white : Colors.black87),
                title: Text(
                  'Cambiar tema',
                  style: TextStyle(color: themeService.isDarkTheme ? Colors.white : Colors.black87, fontSize: 16),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: themeService.isDarkTheme ? Colors.white70 : Colors.black54, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showThemeOptions(context);
                },
              ),
              
              // Opción cerrar sesión
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.errorRed),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: AppColors.errorRed, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutConfirmation(context);
                },
              ),
              
              const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showThemeOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Consumer<ThemeService>(
          builder: (context, themeService, child) {
            return Container(
              decoration: BoxDecoration(
                color: themeService.isDarkTheme ? AppColors.darkBackground : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicador visual superior
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Seleccionar tema',
                      style: TextStyle(
                        color: themeService.isDarkTheme ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tema oscuro
                  ListTile(
                    leading: Icon(
                      Icons.dark_mode, 
                      color: themeService.isDarkTheme ? Colors.white : Colors.black87,
                    ),
                    title: Text(
                      'Tema oscuro',
                      style: TextStyle(
                        color: themeService.isDarkTheme ? Colors.white : Colors.black87, 
                        fontSize: 16,
                      ),
                    ),
                    trailing: themeService.isDarkTheme 
                        ? const Icon(Icons.check, color: AppColors.primaryRed)
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      await themeService.setTheme(AppTheme.dark);
                    },
                  ),
                  
                  // Tema claro
                  ListTile(
                    leading: Icon(
                      Icons.light_mode, 
                      color: themeService.isDarkTheme ? Colors.white70 : Colors.black54,
                    ),
                    title: Text(
                      'Tema claro',
                      style: TextStyle(
                        color: themeService.isDarkTheme ? Colors.white70 : Colors.black54, 
                        fontSize: 16,
                      ),
                    ),
                    trailing: !themeService.isDarkTheme 
                        ? const Icon(Icons.check, color: AppColors.primaryRed)
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      await themeService.setTheme(AppTheme.light);
                    },
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeService>(
          builder: (context, themeService, child) {
            return AlertDialog(
              backgroundColor: themeService.isDarkTheme ? AppColors.darkBackground : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: themeService.isDarkTheme ? Colors.white : Colors.black87, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                '¿Estás seguro de que deseas cerrar tu sesión?',
                style: TextStyle(
                  color: themeService.isDarkTheme ? Colors.white70 : Colors.black54,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: themeService.isDarkTheme ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _logout(context);
                  },
                  child: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _logout(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();
    context.go('/login');
  }
}