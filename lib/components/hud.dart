import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/tetris_game.dart';

class HudComponent extends Component with HasGameReference<TetrisGame> {
  late TextComponent scoreText;
  late TextComponent levelText;
  late TextComponent linesText;
  
  @override
  Future<void> onLoad() async {
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;
    
    // Adiciona espaço para SafeArea (status bar, notch, etc.)
    final safeAreaTop = 50.0; // Espaço seguro no topo
    
    print('🖥️ [SNAPRIX HUD] Carregando HUD INOVADOR - Tela: ${screenWidth.toInt()}x${screenHeight.toInt()}');
    print('📱 [SNAPRIX HUD] SafeArea Top: ${safeAreaTop}px');
    
    // === SEM FUNDO - APENAS TEXTO LIMPO ===
    
    // === STATS NO TOPO HORIZONTAL ===
    _createTopStats(screenWidth, safeAreaTop);
  }
  
  void _createTopStats(double screenWidth, double safeAreaTop) {
    // Posicionamento horizontal dos stats no topo
    final centerY = safeAreaTop + 30; // Mesma altura onde estava o título
    final spacing = screenWidth / 4; // Espaçamento horizontal entre stats
    final startX = screenWidth / 2 - spacing; // Começa um pouco à esquerda do centro
    
    // Cor das bordas (ciano)
    const borderColor = Color(0xFF00FFFF);
    
    // === SCORE (Esquerda) ===
    _createHorizontalStat(
      label: 'SCORE',
      value: '0', 
      color: borderColor,
      x: startX,
      y: centerY,
      isScore: true,
    );
    
    // === LEVEL (Centro) ===
    _createHorizontalStat(
      label: 'LEVEL',
      value: '1',
      color: borderColor,
      x: startX + spacing,
      y: centerY,
      isLevel: true,
    );
    
    // === LINES (Direita) ===
    _createHorizontalStat(
      label: 'LINES',
      value: '0',
      color: borderColor,
      x: startX + (spacing * 2),
      y: centerY,
      isLines: true,
    );
  }
  
  void _createHorizontalStat({
    required String label,
    required String value,
    required Color color,
    required double x,
    required double y,
    bool isScore = false,
    bool isLevel = false,
    bool isLines = false,
  }) {
    // Label (nome do stat)
    final labelComponent = TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: TextStyle(
          color: color.withValues(alpha: 0.8),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
      position: Vector2(x, y - 8),
      anchor: Anchor.center,
    );
    add(labelComponent);
    
    // Valor (número)
    final valueComponent = TextComponent(
      text: value,
      textRenderer: TextPaint(
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: color.withValues(alpha: 0.3),
              offset: const Offset(0, 0),
              blurRadius: 8,
            ),
            Shadow(
              offset: const Offset(1, 1),
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      position: Vector2(x, y + 8),
      anchor: Anchor.center,
    );
    add(valueComponent);
    
    // Guardar referência para atualização
    if (isScore) scoreText = valueComponent;
    if (isLevel) levelText = valueComponent;
    if (isLines) linesText = valueComponent;
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