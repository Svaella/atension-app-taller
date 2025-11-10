import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/onboarding_service.dart';

class EvaluationWizard extends StatefulWidget {
  const EvaluationWizard({super.key});

  @override
  State<EvaluationWizard> createState() => _EvaluationWizardState();
}

class _EvaluationWizardState extends State<EvaluationWizard> {
  bool _submitting = false;

  Future<void> _finishEvaluation() async {
    setState(() => _submitting = true);
    try {
      // TODO: aquí llama a tu EvaluationService.createEvaluation(...)
      await OnboardingService().markEvaluationDone();
      if (!mounted) return;
      context.go('/home');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evaluación (primera vez)')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Aquí va tu flujo de evaluación.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitting ? null : _finishEvaluation,
              child: Text(_submitting ? 'Guardando...' : 'Finalizar evaluación'),
            ),
          ],
        ),
      ),
    );
  }
}