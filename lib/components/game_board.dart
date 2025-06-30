import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'block.dart';

class GameBoard extends PositionComponent {
  late List<List<int>> board;
  late List<List<Color?>> boardColors;
  List<GameBlock> staticBlocks = [];
  
  @override
  Future<void> onLoad() async {
    // Inicializa o tabuleiro vazio
    board = List.generate(
      GameConstants.rows,
      (_) => List.filled(GameConstants.columns, 0),
    );
    
    boardColors = List.generate(
      GameConstants.rows,
      (_) => List.filled(GameConstants.columns, null),
    );
    
    // Adiciona as linhas de grade
    add(GridLines());
  }
  
  bool isValidPosition(int x, int y) {
    return x >= 0 && 
           x < GameConstants.columns && 
           y >= 0 && 
           y < GameConstants.rows && 
           board[y][x] == 0;
  }
  
  bool canPlacePiece(List<Vector2> blockPositions) {
    for (final pos in blockPositions) {
      final x = pos.x.toInt();
      final y = pos.y.toInt();
      
      if (!isValidPosition(x, y)) {
        return false;
      }
    }
    return true;
  }
  
  void placePiece(List<Vector2> blockPositions, Color color) {
    for (final pos in blockPositions) {
      final x = pos.x.toInt();
      final y = pos.y.toInt();
      
      if (x >= 0 && x < GameConstants.columns && y >= 0 && y < GameConstants.rows) {
        board[y][x] = 1;
        boardColors[y][x] = color;
        
        final block = GameBlock(
          blockColor: color,
          gridX: x,
          gridY: y,
        );
        staticBlocks.add(block);
        add(block);
      }
    }
  }
  
  List<int> getFullLines() {
    List<int> fullLines = [];
    
    for (int row = 0; row < GameConstants.rows; row++) {
      bool isFull = true;
      for (int col = 0; col < GameConstants.columns; col++) {
        if (board[row][col] == 0) {
          isFull = false;
          break;
        }
      }
      if (isFull) {
        fullLines.add(row);
      }
    }
    
    return fullLines;
  }
  
  void clearLines(List<int> linesToClear) {
    linesToClear.sort((a, b) => b.compareTo(a)); // Ordenar de baixo para cima
    
    for (final lineIndex in linesToClear) {
      // Remove blocos visuais da linha
      staticBlocks.removeWhere((GameBlock block) {
        if (block.gridY == lineIndex) {
          block.removeFromParent();
          return true;
        }
        return false;
      });
      
      // Remove a linha do tabuleiro
      board.removeAt(lineIndex);
      boardColors.removeAt(lineIndex);
      
      // Adiciona nova linha vazia no topo
      board.insert(0, List.filled(GameConstants.columns, 0));
      boardColors.insert(0, List.filled(GameConstants.columns, null));
      
      // Move todos os blocos acima para baixo
      for (final GameBlock block in staticBlocks) {
        if (block.gridY < lineIndex) {
          block.updatePosition(block.gridX, block.gridY + 1);
        }
      }
    }
  }
  
  void reset() {
    // Remove todos os blocos estáticos
    for (final GameBlock block in staticBlocks) {
      block.removeFromParent();
    }
    staticBlocks.clear();
    
    // Reseta o tabuleiro
    board = List.generate(
      GameConstants.rows,
      (_) => List.filled(GameConstants.columns, 0),
    );
    
    boardColors = List.generate(
      GameConstants.rows,
      (_) => List.filled(GameConstants.columns, null),
    );
  }
}

class GridLines extends Component {
  @override
  void render(Canvas canvas) {
    final boardRect = Rect.fromLTWH(
      0, 
      0, 
      GameConstants.columns * GameConstants.cellSize, 
      GameConstants.rows * GameConstants.cellSize
    );
    
    // Fundo do tabuleiro com gradiente sutil
    final backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0a0a0a),
        const Color(0xFF1a1a1a),
        const Color(0xFF0f0f0f),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final backgroundPaint = Paint()
      ..shader = backgroundGradient.createShader(boardRect);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(8)),
      backgroundPaint,
    );
    
    // Borda externa do tabuleiro com margem interna
    final borderRect = Rect.fromLTWH(
      2, 
      2, 
      GameConstants.columns * GameConstants.cellSize - 4, 
      GameConstants.rows * GameConstants.cellSize - 4
    );
    
    final borderPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(borderRect, const Radius.circular(8)),
      borderPaint,
    );
    
    // Grid interno com estilo moderno
    final gridPaint = Paint()
      ..color = const Color(0xFF333333).withValues(alpha: 0.4)
      ..strokeWidth = 0.5;
    
    final accentGridPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.1)
      ..strokeWidth = 0.8;
    
    // Linhas verticais
    for (int col = 1; col < GameConstants.columns; col++) {
      final x = col * GameConstants.cellSize;
      final paint = (col % 5 == 0) ? accentGridPaint : gridPaint;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, GameConstants.rows * GameConstants.cellSize),
        paint,
      );
    }
    
    // Linhas horizontais
    for (int row = 1; row < GameConstants.rows; row++) {
      final y = row * GameConstants.cellSize;
      final paint = (row % 5 == 0) ? accentGridPaint : gridPaint;
      canvas.drawLine(
        Offset(0, y),
        Offset(GameConstants.columns * GameConstants.cellSize, y),
        paint,
      );
    }
    
    // Linhas de destaque a cada 5 células para melhor orientação
    final highlightPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.15)
      ..strokeWidth = 1.2;
    
    // Linha central vertical
    final centerX = (GameConstants.columns / 2).floor() * GameConstants.cellSize;
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, GameConstants.rows * GameConstants.cellSize),
      highlightPaint,
    );
  }
}