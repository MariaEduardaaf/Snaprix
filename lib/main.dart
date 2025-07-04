import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'game/tetris_game.dart';
import 'overlays/main_menu.dart';
import 'overlays/pause_menu.dart';
import 'overlays/game_over_menu.dart';
import 'overlays/mobile_controls.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final game = TetrisGame();
  runApp(
    MaterialApp(
      title: 'Snaprix',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt'), // Portuguese
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('ru'), // Russian
        Locale('ja'), // Japanese
        Locale('ar'), // Arabic
      ],
      home: GameWidget<TetrisGame>.controlled(
        gameFactory: () => game,
        overlayBuilderMap: {
          'MainMenu': (_, game) => MainMenu(game: game),
          'PauseMenu': (_, game) => PauseMenu(game: game),
          'GameOver': (_, game) => GameOverMenu(game: game),
          'MobileControls': (_, game) => MobileControls(game: game),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}
