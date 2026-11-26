import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/home_shell.dart';
import 'state/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = OtonomAppState();
  await appState.loadSavedPreferences();
  // Fire live GPS, Nominatim, Open-Meteo, OSRM & Overpass APIs asynchronously
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
          theme: brandTheme.toMaterialTheme(),
          home: HomeShell(appState: appState),
        );
      },
    );
  }
}
