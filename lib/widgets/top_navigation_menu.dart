import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/colors.dart';

class TopNavigationMenu extends StatelessWidget {
  final String? activeTab; // puede ser null o '' para no resaltar
  const TopNavigationMenu({super.key, this.activeTab});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: isDark ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _buildTabItem(context, 'Evaluación', activeTab == 'evaluacion', () => context.go('/evaluation-form')),
              _buildTabItem(context, 'Historial', activeTab == 'historial', () => context.go('/history')),
              _buildTabItem(context, 'Información', activeTab == 'informacion', () => context.go('/information')),
            ],
          ),
        ),
        Container(
          height: 1,
          color: isDark 
            // ignore: deprecated_member_use
            ? Colors.white.withOpacity(0.15)
            // ignore: deprecated_member_use
            : Colors.grey.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    String title,
    bool isActive,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: isActive ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primaryRed : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive 
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? AppColors.textSecondary : Colors.grey[600]),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
