import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/evaluation_service.dart';
import 'services/theme_service.dart';

void main() {
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
        ChangeNotifierProvider(create: (_) => EvaluationService()),
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
              Locale('es', 'ES'), // Español
            ],
            locale: const Locale('es', 'ES'),
            theme: themeService.themeData,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}