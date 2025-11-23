import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/bp_service.dart';
import 'services/auth_service.dart';
import 'services/evaluation_service.dart';
import 'services/onboarding_service.dart';
import 'services/profile_service.dart';
import 'services/rating_service.dart';
import 'routes/app_routes.dart';
import 'services/theme_service.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ATensionApp());
}

class ATensionApp extends StatelessWidget {
  const ATensionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, ProfileService>(
          create: (_) => ProfileService(),
          update: (_, auth, service) => service!..attachAuth(auth),
        ),
        ChangeNotifierProvider(create: (_) => EvaluationService()),
        ChangeNotifierProvider<OnboardingService>(create: (_) => OnboardingService()),
        ChangeNotifierProxyProvider<AuthService, BPService>(
          create: (_) => BPService(),
          update: (_, auth, svc) => (svc!..attachAuth(auth)),
        ),
        ChangeNotifierProxyProvider<AuthService, RatingService>(
          create: (_) => RatingService(),
          update: (_, auth, service) => service!..attachAuth(auth),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp.router(
            title: 'aTensión',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'ES'),
            ],
            locale: const Locale('es', 'ES'),
            theme: themeService.lightTheme,
            darkTheme: themeService.darkTheme,
            themeMode: themeService.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}