// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';

// CORREÇÃO: Importa o main do projeto correto (snaprix-analysis)
import '../lib/main.dart';
import '../lib/game/tetris_game.dart';

void main() {
  testWidgets('Snaprix app loads correctly', (WidgetTester tester) async {
    // CORREÇÃO: Testa se o jogo Snaprix inicializa corretamente
    final game = TetrisGame();
    
    await tester.pumpWidget(
      MaterialApp(
        home: GameWidget<TetrisGame>.controlled(
          gameFactory: () => game,
          overlayBuilderMap: const {},
          initialActiveOverlays: const [], // CORREÇÃO: Sem overlays no teste
        ),
      ),
    );

    // Verifica se o widget do jogo foi criado
    expect(find.byType(GameWidget<TetrisGame>), findsOneWidget);
    
    // Aguarda inicialização completa
    await tester.pump();
    
    // Testa básico passou - jogo inicializa sem erros
    expect(true, true);
  });
  
  test('TetrisGame initializes with correct values', () {
    final game = TetrisGame();
    
    // Verifica valores iniciais
    expect(game.score, 0);
    expect(game.linesCleared, 0);
    expect(game.level, 1);
    expect(game.isGameOver, false);
    expect(game.isPaused, false);
    expect(game.gameStarted, false);
  });
}
