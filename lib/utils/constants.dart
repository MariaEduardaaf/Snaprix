import 'package:flutter/material.dart';

class GameConstants {
  // Tamanho do tabuleiro em células
  static const int columns = 10;
  static const int rows = 20;
  static double cellSize = 30.0; // Será atualizado dinamicamente
  
  // Velocidades do jogo
  static const double baseDropInterval = 1.0; // segundos
  static const double fastDropMultiplier = 0.1;
  
  // Pontuação
  static const int pointsPerLine = 100;
  static const int pointsPerLevel = 1000;
  
  // Cores das peças
  static const Map<String, Color> pieceColors = {
    'I': Colors.cyan,
    'O': Colors.yellow,
    'T': Colors.purple,
    'S': Colors.green,
    'Z': Colors.red,
    'J': Colors.blue,
    'L': Colors.orange,
  };
  
  // Formas das peças (rotações)
  static const Map<String, List<List<List<int>>>> pieceShapes = {
    'I': [
      [
        [1, 1, 1, 1]
      ],
      [
        [1],
        [1],
        [1],
        [1]
      ]
    ],
    'O': [
      [
        [1, 1],
        [1, 1]
      ]
    ],
    'T': [
      [
        [0, 1, 0],
        [1, 1, 1]
      ],
      [
        [1, 0],
        [1, 1],
        [1, 0]
      ],
      [
        [1, 1, 1],
        [0, 1, 0]
      ],
      [
        [0, 1],
        [1, 1],
        [0, 1]
      ]
    ],
    'S': [
      [
        [0, 1, 1],
        [1, 1, 0]
      ],
      [
        [1, 0],
        [1, 1],
        [0, 1]
      ]
    ],
    'Z': [
      [
        [1, 1, 0],
        [0, 1, 1]
      ],
      [
        [0, 1],
        [1, 1],
        [1, 0]
      ]
    ],
    'J': [
      [
        [1, 0, 0],
        [1, 1, 1]
      ],
      [
        [1, 1],
        [1, 0],
        [1, 0]
      ],
      [
        [1, 1, 1],
        [0, 0, 1]
      ],
      [
        [0, 1],
        [0, 1],
        [1, 1]
      ]
    ],
    'L': [
      [
        [0, 0, 1],
        [1, 1, 1]
      ],
      [
        [1, 0],
        [1, 0],
        [1, 1]
      ],
      [
        [1, 1, 1],
        [1, 0, 0]
      ],
      [
        [1, 1],
        [0, 1],
        [0, 1]
      ]
    ],
  };
  
  // Nomes dos arquivos de som
  static const String moveSound = 'move.mp3';
  static const String rotateSound = 'rotate.mp3';
  static const String lineClearSound = 'line_clear.mp3';
  static const String gameOverSound = 'game_over.mp3';
}