import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:showcaseview/showcaseview.dart";

import "core/router/app_router.dart";
import "core/theme/app_theme.dart";
import "firebase_options.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting("fr_FR");
  runApp(const ProviderScope(child: EssenciaApp()));
}

class EssenciaApp extends StatelessWidget {
  const EssenciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "E-sensya & Co",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      locale: const Locale("fr", "FR"),
      supportedLocales: const [Locale("fr", "FR")],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => ShowCaseWidget(builder: (context) => child!),
    );
  }
}
