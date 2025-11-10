import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/password_reset_screen.dart';
import '../screens/new_password_screen.dart';
import '../screens/evaluation_screen.dart';
import '../screens/evaluation_form_screen1.dart';
import '../screens/evaluation_result_screen.dart';
import '../screens/evaluation_form_screen2.dart';
import '../models/evaluation_draft.dart';
import '../screens/history_screen.dart';
import '../screens/information_screen.dart';
import '../screens/about_app_screen.dart';
import '../screens/splash_decider.dart';
import '../screens/evaluation/evaluation_wizard.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/tus_datos_screen.dart';
import '../screens/home/registro_screen.dart';
import '../screens/risk_guide_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashDecider()),
      GoRoute(path: '/onboarding', builder: (_, __) => const EvaluationWizard()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      // rutas directas siguen mostrando AppBar propio:
      GoRoute(path: '/information', builder: (_, __) => const InformationScreen(embedded: false)),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen(embedded: false)),
      // Subrutas para los 3 apartados de Home
      GoRoute(path: '/home/tus-datos', builder: (_, __) => const TusDatosScreen()),
      GoRoute(path: '/home/registro', builder: (_, __) => const RegistroScreen()),
      // Alias hacia Información dentro de Home (puedes conservar también /information)
      GoRoute(path: '/home/informacion', builder: (_, __) => const InformationScreen()),

      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/password-reset', builder: (_, __) => const PasswordResetScreen()),
      GoRoute(path: '/new-password', builder: (_, __) => const NewPasswordScreen()),
      GoRoute(path: '/evaluation', builder: (_, __) => const EvaluationScreen()),
      GoRoute(path: '/evaluation-form', builder: (_, __) => const EvaluationFormScreen()),
      GoRoute(
        path: '/evaluation-form-step2',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! EvaluationDraft) return const EvaluationFormScreen();
          return EvaluationFormStep2Screen(draft: extra);
        },
      ),
      GoRoute(path: '/evaluation-result', builder: (_, __) => const EvaluationResultScreen()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/information', builder: (_, __) => const InformationScreen()),
      GoRoute(path: '/about', builder: (_, __) => const AboutAppScreen()),
      GoRoute(
        path: '/risk-guide',
        builder: (context, state) {
          final risk = (state.extra as String?) ?? 'bajo';
          return RiskGuideScreen(riskLevel: risk);
        },
      ),
    ],
  );
}