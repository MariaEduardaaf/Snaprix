import 'package:flutter/material.dart';
import '../game/tetris_game.dart';

class GameOverMenu extends StatelessWidget {
  final TetrisGame game;

  const GameOverMenu({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.95),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Game Over', 
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                shadows: [
                  Shadow(
                    offset: Offset(3, 3),
                    color: Colors.black,
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Pontuação: ${game.score}', 
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Nível alcançado: ${game.level}', 
              style: TextStyle(
                fontSize: 22,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Linhas: ${game.linesCleared}', 
              style: TextStyle(
                fontSize: 18,
                color: Colors.white60,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('GameOver');
                game.startGame();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Jogar Novamente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('GameOver');
                game.overlays.add('MainMenu');
                game.resetGame();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Menu Inicial',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}