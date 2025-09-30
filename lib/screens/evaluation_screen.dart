import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/top_navigation_menu.dart';
import '../widgets/user_menu_button.dart';

class EvaluationScreen extends StatelessWidget {
  const EvaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'aTensión',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        centerTitle: false,
  // Estilo unificado ya especificado arriba
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => context.push('/about'),
          ),
          const UserMenuButton(),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(52),
          child: TopNavigationMenu(activeTab: 'evaluacion'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 280,
            child: CustomButton(
              text: 'Iniciar evaluación',
              onPressed: () => context.go('/evaluation-form'),
              backgroundColor: AppColors.primaryRed,
              textColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}