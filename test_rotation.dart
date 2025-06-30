// Arquivo de teste para demonstrar o sistema de rotação matemática

import 'dart:math';

void main() {
  print('=== TESTE DO SISTEMA DE ROTAÇÃO MATEMÁTICA ===\n');
  
  // Teste com peça T
  print('Testando rotação da peça T:');
  List<Point<int>> tPiece = [
    Point(1, 0), // Centro do T
    Point(0, 1), Point(1, 1), Point(2, 1) // Base do T
  ];
  
  print('Posição inicial: $tPiece');
  
  // Simula 4 rotações
  List<Point<int>> current = tPiece;
  for (int rotation = 1; rotation <= 4; rotation++) {
    current = rotatePiece(current);
    print('Rotação $rotation: $current');
  }
  
  print('\n=== TESTE DAS 7 PEÇAS DO TETRIS ===\n');
  
  // Todas as 7 peças iniciais
  Map<String, List<Point<int>>> pieces = {
    'I': [Point(0, 0), Point(1, 0), Point(2, 0), Point(3, 0)],
    'O': [Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)],
    'T': [Point(1, 0), Point(0, 1), Point(1, 1), Point(2, 1)],
    'L': [Point(0, 0), Point(0, 1), Point(0, 2), Point(1, 2)],
    'J': [Point(1, 0), Point(1, 1), Point(1, 2), Point(0, 2)],
    'S': [Point(1, 0), Point(2, 0), Point(0, 1), Point(1, 1)],
    'Z': [Point(0, 0), Point(1, 0), Point(1, 1), Point(2, 1)],
  };
  
  pieces.forEach((name, shape) {
    print('Peça $name:');
    print('  Inicial: $shape');
    List<Point<int>> rotated = rotatePiece(shape);
    print('  1 rotação: $rotated');
    print('');
  });
}

List<Point<int>> rotatePiece(List<Point<int>> coords) {
  // Determinar dimensões do shape atual
  int maxX = coords.map((p) => p.x).reduce((a, b) => a > b ? a : b);
  int maxY = coords.map((p) => p.y).reduce((a, b) => a > b ? a : b);
  
  // Aplica rotação 90°: (x, y) -> (y, maxX - x)
  return coords.map((p) {
    int newX = p.y;
    int newY = maxX - p.x;
    return Point(newX, newY);
  }).toList();
}