import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/onboarding_service.dart';
import '../services/auth_service.dart';

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});
  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_decide);
  }

  Future<void> _decide() async {
    final authService = context.read<AuthService>();
    final onboarding = context.read<OnboardingService>();
    
    await onboarding.load();
    if (!mounted) return;
    
    // Verificar si el usuario está autenticado
    if (!authService.isAuthenticated) {
      context.go('/welcome');
      return;
    }
    
    // Usuario autenticado
    if (onboarding.evaluationDone) {
      context.go('/home');
    } else {
      // Usuario autenticado pero sin evaluación
      context.go('/evaluation-form');
    }
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}