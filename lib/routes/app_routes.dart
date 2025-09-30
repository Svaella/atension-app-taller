import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/password_reset_screen.dart';
import '../screens/new_password_screen.dart';
import '../screens/evaluation_screen.dart';
import '../screens/evaluation_form_screen1.dart';
import '../screens/evaluation_result_screen.dart';
import '../screens/evaluation_form_step2_screen.dart';
import '../models/evaluation_draft.dart';
import '../screens/history_screen.dart';
import '../screens/information_screen.dart';
import '../screens/about_app_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/password-reset',
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        path: '/new-password',
        builder: (context, state) => const NewPasswordScreen(),
      ),
      GoRoute(
        path: '/evaluation',
        builder: (context, state) => const EvaluationScreen(),
      ),
      GoRoute(
        path: '/evaluation-form',
        builder: (context, state) => const EvaluationFormScreen(),
      ),
      GoRoute(
        path: '/evaluation-form-step2',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! EvaluationDraft) {
            // Si se accede sin draft válido, regresar al paso 1
            return const EvaluationFormScreen();
          }
            return EvaluationFormStep2Screen(draft: extra);
        },
      ),
      GoRoute(
        path: '/evaluation-result',
        builder: (context, state) => const EvaluationResultScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/information',
        builder: (context, state) => const InformationScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutAppScreen(),
      ),
    ],
  );
}