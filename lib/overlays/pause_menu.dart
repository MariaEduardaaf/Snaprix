import 'package:flutter/material.dart';
import '../game/tetris_game.dart';
import '../l10n/app_localizations.dart';

class PauseMenu extends StatelessWidget {
  final TetrisGame game;

  const PauseMenu({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.paused, 
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                game.resumeGame();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(
                AppLocalizations.of(context)!.continueGame,
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('PauseMenu');
                game.startGame();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(
                AppLocalizations.of(context)!.restart,
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('PauseMenu');
                game.overlays.add('MainMenu');
                game.resetGame();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                AppLocalizations.of(context)!.exitToMenu,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}