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
    
    // Adiciona espaço para SafeArea (status bar, notch, etc.)
    final safeAreaTop = 50.0; // Espaço seguro no topo
    
    print('🖥️ [SNAPRIX HUD] Carregando HUD - Tela: ${screenWidth.toInt()}x${screenHeight.toInt()}');
    print('📱 [SNAPRIX HUD] SafeArea Top: ${safeAreaTop}px');
    
    // Fundo do HUD mais elegante e compacto
    hudBackground = RectangleComponent(
      size: Vector2(screenWidth, 100),
      position: Vector2(0, safeAreaTop),
      paint: Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF000033).withValues(alpha: 0.95),
            const Color(0xFF000066).withValues(alpha: 0.85),
          ],
        ).createShader(Rect.fromLTWH(0, safeAreaTop, screenWidth, 100))
        ..style = PaintingStyle.fill,
    );
    add(hudBackground);
    
    // Borda inferior elegante
    final hudBorder = RectangleComponent(
      size: Vector2(screenWidth, 2),
      position: Vector2(0, safeAreaTop + 98),
      paint: Paint()
        ..color = const Color(0xFF00FFFF).withValues(alpha: 0.8)
        ..style = PaintingStyle.fill,
    );
    add(hudBorder);
    
    // Título elegante no centro
    final titleText = TextComponent(
      text: 'SNAPRIX',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00FFFF),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 3.0,
          shadows: [
            Shadow(
              color: Color(0xFF0066FF),
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      position: Vector2(screenWidth / 2, safeAreaTop + 35),
      anchor: Anchor.center,
    );
    add(titleText);
    
    // Layout bem distribuído em três colunas
    final leftX = screenWidth * 0.15;   // 15% da tela (score)
    final centerX = screenWidth * 0.5;  // 50% da tela (level)
    final rightX = screenWidth * 0.85;  // 85% da tela (lines)
    
    // === SCORE (Esquerda) ===
    final scoreLabel = TextComponent(
      text: 'SCORE',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
      position: Vector2(leftX, safeAreaTop + 70),
      anchor: Anchor.center,
    );
    add(scoreLabel);
    
    scoreText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(leftX, safeAreaTop + 105),
      anchor: Anchor.center,
    );
    add(scoreText);
    
    // === LEVEL (Centro) ===
    final levelLabel = TextComponent(
      text: 'LEVEL',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
      position: Vector2(centerX, safeAreaTop + 70),
      anchor: Anchor.center,
    );
    add(levelLabel);
    
    levelText = TextComponent(
      text: '1',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFF8C00),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(centerX, safeAreaTop + 105),
      anchor: Anchor.center,
    );
    add(levelText);
    
    // === LINES (Direita) ===
    final linesLabel = TextComponent(
      text: 'LINES',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
      position: Vector2(rightX, safeAreaTop + 70),
      anchor: Anchor.center,
    );
    add(linesLabel);
    
    linesText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF32CD32),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(rightX, safeAreaTop + 105),
      anchor: Anchor.center,
    );
    add(linesText);
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