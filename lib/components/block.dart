import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class Block extends PositionComponent {
  final Paint _paint;
  
  Block(Color color, {Vector2? position, double size = 20.0}) 
      : _paint = Paint()..color = color {
    this.position = position ?? Vector2.zero();
    this.size = Vector2.all(size);
  }
  
  @override
  void render(Canvas canvas) {
    // Desenha um retângulo preenchido representando o bloco
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
    
    // Adiciona borda ao bloco
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      borderPaint,
    );
  }
}

// Manter GameBlock para compatibilidade com o tabuleiro
class GameBlock extends RectangleComponent {
  final Color blockColor;
  final int gridX;
  final int gridY;
  
  GameBlock({
    required this.blockColor,
    required this.gridX,
    required this.gridY,
  }) : super(
    size: Vector2.all(GameConstants.cellSize),
    paint: Paint()..color = blockColor,
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
    super.render(canvas);
    
    // Adiciona borda ao bloco
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      borderPaint,
    );
  }
  
  void updatePosition(int newX, int newY) {
    position = Vector2(
      newX * GameConstants.cellSize,
      newY * GameConstants.cellSize,
    );
  }
}