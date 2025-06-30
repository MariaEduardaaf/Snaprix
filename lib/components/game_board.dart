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
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1.0;
    
    // Linhas verticais
    for (int col = 0; col <= GameConstants.columns; col++) {
      final x = col * GameConstants.cellSize;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, GameConstants.rows * GameConstants.cellSize),
        paint,
      );
    }
    
    // Linhas horizontais
    for (int row = 0; row <= GameConstants.rows; row++) {
      final y = row * GameConstants.cellSize;
      canvas.drawLine(
        Offset(0, y),
        Offset(GameConstants.columns * GameConstants.cellSize, y),
        paint,
      );
    }
  }
}