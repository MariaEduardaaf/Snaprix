import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/tetris_game.dart';

class HudComponent extends Component with HasGameReference<TetrisGame> {
  late TextComponent scoreText;
  late TextComponent levelText;
  late TextComponent linesText;
  late RectangleComponent hudBackground;
  
  @override
  Future<void> onLoad() async {
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;
    print('🖥️ [SNAPRIX HUD] Carregando HUD - Tela: ${screenWidth.toInt()}x${screenHeight.toInt()}');
    
    // Fundo do HUD mais compacto e elegante, respeitando SafeArea
    hudBackground = RectangleComponent(
      size: Vector2(screenWidth - 20, 80),
      position: Vector2(10, 50), // Aumentado de 10 para 50 para evitar camera/notch
      paint: Paint()
        ..color = const Color(0xFF1a1a1a).withOpacity(0.95)
        ..style = PaintingStyle.fill,
    );
    add(hudBackground);
    
    // Borda com cantos arredondados simulados
    final hudBorder = RectangleComponent(
      size: Vector2(screenWidth - 20, 80),
      position: Vector2(10, 50), // Atualizado para corresponder ao background
      paint: Paint()
        ..color = const Color(0xFF00FFFF).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    add(hudBorder);
    
    // Título mais discreto
    final titleText = TextComponent(
      text: 'SNAPRIX',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00FFFF),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
      position: Vector2(screenWidth / 2, 65), // Ajustado para nova posição do HUD
      anchor: Anchor.center,
    );
    add(titleText);
    
    // Layout horizontal mais equilibrado
    final spacing = (screenWidth - 40) / 3;
    
    // Score (esquerda)
    scoreText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20 + spacing * 0.5, 105), // Ajustado para nova posição do HUD
      anchor: Anchor.center,
    );
    add(scoreText);
    
    // Label do Score
    final scoreLabel = TextComponent(
      text: 'SCORE',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      position: Vector2(20 + spacing * 0.5, 90), // Ajustado para nova posição do HUD
      anchor: Anchor.center,
    );
    add(scoreLabel);
    
    // Level (centro)
    levelText = TextComponent(
      text: '1',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFF8C00),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(screenWidth / 2, 105), // Ajustado para nova posição do HUD
      anchor: Anchor.center,
    );
    add(levelText);
    
    // Label do Level
    final levelLabel = TextComponent(
      text: 'LEVEL',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      position: Vector2(screenWidth / 2, 90), // Ajustado para nova posição do HUD
      anchor: Anchor.center,
    );
    add(levelLabel);
    
    // Lines (direita)
    linesText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF32CD32),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(screenWidth - 20 - spacing * 0.5, 105), // Ajustado para nova posição do HUD
      anchor: Anchor.center,
    );
    add(linesText);
    
    // Label do Lines
    final linesLabel = TextComponent(
      text: 'LINES',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      position: Vector2(screenWidth - 20 - spacing * 0.5, 90), // Ajustado para nova posição do HUD
      anchor: Anchor.center,
    );
    add(linesLabel);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Atualiza apenas os valores numéricos
    scoreText.text = _formatNumber(game.score);
    levelText.text = '${game.level}';
    linesText.text = '${game.linesCleared}';
    
    // Mostra game over se necessário
    if (game.isGameOver) {
      if (!children.any((child) => child is GameOverText)) {
        add(GameOverText());
      }
    }
  }
  
  // Formatar números grandes com separadores
  String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }
}

class GameOverText extends TextComponent with HasGameReference<TetrisGame> {
  @override
  Future<void> onLoad() async {
    text = 'GAME OVER';
    textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.red,
        fontSize: 36,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: Offset(3, 3),
            color: Colors.black,
            blurRadius: 6,
          ),
          Shadow(
            offset: Offset(-1, -1),
            color: Colors.white,
            blurRadius: 2,
          ),
        ],
      ),
    );
    
    // Centraliza o texto dinamicamente
    position = Vector2(game.size.x / 2 - 100, game.size.y / 2 - 50);
    anchor = Anchor.center;
  }
}