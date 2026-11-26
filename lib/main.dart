import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_shell.dart';
import 'state/app_state.dart';
import 'widgets/ios_liquid_glass.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge iOS-style status bar & navigation bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ECC Global Error Boundary: friendly iOS card instead of raw framework error
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: const Text(
              'Bileşen yüklenirken geçici bir sorun oluştu. Lütfen ekranı yenileyin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  };

  PlatformDispatcher.instance.onError = (_, __) => true;

  final appState = OtonomAppState();
  await appState.loadSavedPreferences();
  unawaited(appState.refreshAllLiveApis());
  runApp(OtonomApp(appState: appState));
}

class OtonomApp extends StatelessWidget {
  final OtonomAppState appState;

  const OtonomApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final brandTheme = appState.brandTheme;
        return MaterialApp(
          title: 'Otonom · ${brandTheme.name}',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const IosBouncingScrollBehavior(),
          theme: brandTheme.toMaterialTheme(),
          home: HomeShell(appState: appState),
        );
      },
    );
  }
}
