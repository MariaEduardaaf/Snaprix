import 'package:flutter/material.dart';
import '../game/tetris_game.dart';

class MainMenu extends StatelessWidget {
  final TetrisGame game;

  const MainMenu({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tretix', 
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(3, 3),
                    color: Colors.blue,
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Inicia o jogo ao clicar "Jogar"
                game.overlays.remove('MainMenu');
                game.startGame();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              child: Text('Jogar'),
            ),
            const SizedBox(height: 30),
            Text(
              'Controles Mobile:\n🖱️ Arrastar: Mover peças\n👆 Duplo toque: Rotacionar\n👆 Toque parte inferior: Queda rápida\n\nControles Teclado:\n⬅ ➡ Mover    ⬇ Acelerar\n⬆ Rotacionar    SPACE Queda rápida\nESC Pausar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}