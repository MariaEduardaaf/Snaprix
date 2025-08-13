import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class Block extends PositionComponent {
  final Color _baseColor;
  
  Block(Color color, {Vector2? position, double size = 20.0}) 
      : _baseColor = color {
    this.position = position ?? Vector2.zero();
    this.size = Vector2.all(size);
  }
  
  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    
    // Cria gradiente radial para efeito 3D
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.0,
      colors: [
        _baseColor.withValues(alpha: 1.0),
        _baseColor.withValues(alpha: 0.9),
        _baseColor.withValues(alpha: 0.7),
        _baseColor.withValues(alpha: 0.5),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect);
    
    // Sombra externa
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    
    final shadowRect = Rect.fromLTWH(2, 2, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, const Radius.circular(3)),
      shadowPaint,
    );
    
    // Bloco principal com gradiente
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      gradientPaint,
    );
    
    // Highlight superior esquerdo
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.5;
    
    canvas.drawLine(
      const Offset(3, 3),
      Offset(size.x - 3, 3),
      highlightPaint,
    );
    canvas.drawLine(
      const Offset(3, 3),
      Offset(3, size.y - 3),
      highlightPaint,
    );
    
    // Sombra inferior direita
    final shadowLinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    
    canvas.drawLine(
      Offset(size.x - 3, 3),
      Offset(size.x - 3, size.y - 3),
      shadowLinePaint,
    );
    canvas.drawLine(
      Offset(3, size.y - 3),
      Offset(size.x - 3, size.y - 3),
      shadowLinePaint,
    );
    
    // Borda externa sutil
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      borderPaint,
    );
  }
}

// GameBlock modernizado para compatibilidade com o tabuleiro
class GameBlock extends RectangleComponent {
  final Color blockColor;
  int gridX;
  int gridY;
  
  GameBlock({
    required this.blockColor,
    required this.gridX,
    required this.gridY,
  }) : super(
    size: Vector2.all(GameConstants.cellSize),
  );
  
  @override
  Future<void> onLoad() async {
    position = Vector2(
      gridX * GameConstants.cellSize,
      gridY * GameConstants.cellSize,
    );
  }
  
  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    
    // Gradiente para efeito 3D
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.0,
      colors: [
        blockColor.withValues(alpha: 1.0),
        blockColor.withValues(alpha: 0.9),
        blockColor.withValues(alpha: 0.7),
        blockColor.withValues(alpha: 0.5),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect);
    
    // Sombra externa
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    
    final shadowRect = Rect.fromLTWH(1.5, 1.5, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, const Radius.circular(2)),
      shadowPaint,
    );
    
    // Bloco principal com gradiente
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      gradientPaint,
    );
    
    // Highlight superior esquerdo
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    
    canvas.drawLine(
      const Offset(2, 2),
      Offset(size.x - 2, 2),
      highlightPaint,
    );
    canvas.drawLine(
      const Offset(2, 2),
      Offset(2, size.y - 2),
      highlightPaint,
    );
    
    // Sombra inferior direita
    final shadowLinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;
    
    canvas.drawLine(
      Offset(size.x - 2, 2),
      Offset(size.x - 2, size.y - 2),
      shadowLinePaint,
    );
    canvas.drawLine(
      Offset(2, size.y - 2),
      Offset(size.x - 2, size.y - 2),
      shadowLinePaint,
    );
    
    // Borda externa
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      borderPaint,
    );
  }
  
  void updatePosition(int newX, int newY) {
    gridX = newX;
    gridY = newY;
    position = Vector2(
      newX * GameConstants.cellSize,
      newY * GameConstants.cellSize,
    );
  }
}