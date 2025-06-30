import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'block.dart' as tetris_block;
import '../utils/constants.dart';

enum TetrominoType { I, O, T, L, J, S, Z }

class Tetromino extends PositionComponent {
  TetrominoType type;
  List<tetris_block.Block> blocks = [];
  int rotationIndex = 0; // qual rotação atual (0,1,2,3)
  
  Tetromino(this.type) {
    // definir cor e formato com base no tipo
    Color color;
    List<List<int>> shape;
    
    switch(type) {
      case TetrominoType.I:
        color = Colors.cyan;
        shape = [
          [1,1,1,1]
        ];
        break;
      case TetrominoType.O:
        color = Colors.yellow;
        shape = [
          [1,1],
          [1,1]
        ];
        break;
      case TetrominoType.T:
        color = Colors.purple;
        shape = [
          [0,1,0],
          [1,1,1]
        ];
        break;
      case TetrominoType.L:
        color = Colors.orange;
        shape = [
          [1,0,0],
          [1,1,1]
        ];
        break;
      case TetrominoType.J:
        color = Colors.blue;
        shape = [
          [0,0,1],
          [1,1,1]
        ];
        break;
      case TetrominoType.S:
        color = Colors.green;
        shape = [
          [0,1,1],
          [1,1,0]
        ];
        break;
      case TetrominoType.Z:
        color = Colors.red;
        shape = [
          [1,1,0],
          [0,1,1]
        ];
        break;
    }
    
    // Cria blocos conforme a matriz shape definida
    for (int r = 0; r < shape.length; r++) {
      for (int c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 1) {
          // Adiciona um bloco na posição relativa (c, r)
          var block = tetris_block.Block(color, size: GameConstants.cellSize);
          block.position = Vector2(c * GameConstants.cellSize, r * GameConstants.cellSize);
          add(block);
          blocks.add(block);
        }
      }
    }
    
    // Define tamanho do componente Tetromino baseado no shape
    size = Vector2(shape[0].length * GameConstants.cellSize, shape.length * GameConstants.cellSize);
    anchor = Anchor.topLeft;
  }
  
  // Construtor para criação aleatória
  static Tetromino createRandom() {
    final types = TetrominoType.values;
    final random = Random();
    return Tetromino(types[random.nextInt(types.length)]);
  }
  
  // Rotaciona a peça 90 graus (horário)
  void rotate() {
    // Para simplificar, aplicamos rotação via matriz: transposição + reversão (equivale a 90 graus)
    // Obter coordenadas atuais dos blocos relativas à posição da peça
    final coords = blocks.map((tetris_block.Block b) {
      // posição relativa em células
      int col = (b.position.x / GameConstants.cellSize).round();
      int row = (b.position.y / GameConstants.cellSize).round();
      return Point<int>(col, row);
    }).toList();
    
    // Determinar dimensões do shape atual
    int maxX = coords.map((p) => p.x).reduce((a, b) => a > b ? a : b);
    int maxY = coords.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    
    // Cria nova lista de coordenadas rotacionadas
    List<Point<int>> newCoords = coords.map((p) {
      // Fórmula rotação 90°: (x, y) -> (y, maxX - x)
      int newX = p.y;
      int newY = maxX - p.x;
      return Point(newX, newY);
    }).toList();
    
    // Reposiciona blocos de acordo com newCoords
    for (int i = 0; i < blocks.length; i++) {
      blocks[i].position = Vector2(
        newCoords[i].x * GameConstants.cellSize, 
        newCoords[i].y * GameConstants.cellSize
      );
    }
    
    // Atualiza tamanho do Tetromino após rotação
    int newWidth = newCoords.map((p) => p.x).reduce((a, b) => a > b ? a : b) + 1;
    int newHeight = newCoords.map((p) => p.y).reduce((a, b) => a > b ? a : b) + 1;
    size = Vector2(newWidth * GameConstants.cellSize, newHeight * GameConstants.cellSize);
    
    rotationIndex = (rotationIndex + 1) % 4;
  }
  
  // Rotação reversa para desfazer movimento inválido
  void rotateBack() {
    // Aplica 3 rotações para equivaler a uma rotação anti-horária
    for (int i = 0; i < 3; i++) {
      rotate();
    }
    rotationIndex = (rotationIndex - 1) % 4;
    if (rotationIndex < 0) rotationIndex = 3;
  }
  
  // Método para obter posições dos blocos no grid global
  List<Vector2> getBlockPositions() {
    return blocks.map<Vector2>((tetris_block.Block block) {
      return Vector2(
        (position.x + block.position.x) / GameConstants.cellSize,
        (position.y + block.position.y) / GameConstants.cellSize,
      );
    }).toList();
  }
  
  // Métodos de movimento
  void moveLeft() {
    position.x -= GameConstants.cellSize;
  }
  
  void moveRight() {
    position.x += GameConstants.cellSize;
  }
  
  void moveDown() {
    position.y += GameConstants.cellSize;
  }
  
  // Setters para posição em coordenadas de grid
  void setGridPosition(int gridX, int gridY) {
    position = Vector2(
      gridX * GameConstants.cellSize,
      gridY * GameConstants.cellSize,
    );
  }
  
  int get gridX => (position.x / GameConstants.cellSize).round();
  int get gridY => (position.y / GameConstants.cellSize).round();
}