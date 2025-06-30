import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../components/tetromino.dart';
import '../components/game_board.dart';
import '../components/hud.dart';
import '../utils/constants.dart';

class TetrisGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  // Tamanho do tabuleiro em células (colunas x linhas)
  static const int columns = 10;
  static const int rows = 20;
  late double cellSize; // Será calculado dinamicamente
  
  // Matriz representando o tabuleiro (grade). 0 = vazio, 1 = ocupado.
  late List<List<int>> board;
  
  // Peça atual em queda
  Tetromino? currentPiece;
  
  // Pontuação e nível
  int score = 0;
  int linesCleared = 0;
  int level = 1;
  
  // Velocidade de queda (intervalo em segundos entre descidas automáticas)
  double dropInterval = 1.0; // começa com 1 segundo por nível 1
  
  // Controle interno de tempo para queda
  double _dropTimer = 0.0;
  
  // Flags de estado
  bool isGameOver = false;
  bool isPaused = false;
  bool gameStarted = false;
  
  // Componentes de interface
  late GameBoard gameBoard;
  late HudComponent hud;
  
  // Controles por gestos - removido código não utilizado
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Calcula o tamanho da célula baseado no tamanho da tela
    _calculateCellSize();
    
    // Inicializa a matriz do tabuleiro vazia
    board = List.generate(rows, (_) => List.filled(columns, 0));
    
    // Inicializa o sistema de áudio
    await initializeAudio();
    
    // Inicializa componentes de interface
    gameBoard = GameBoard();
    hud = HudComponent();
    
    // Centraliza o tabuleiro na tela, deixando espaço para o HUD superior
    final boardWidth = columns * cellSize;
    final boardHeight = rows * cellSize;
    final hudHeight = size.y * 0.15; // Espaço para o HUD na parte superior
    gameBoard.position = Vector2(
      (size.x - boardWidth) / 2,
      hudHeight + (size.y - boardHeight - hudHeight) / 2,
    );
    
    add(gameBoard);
    add(hud);
    add(KeyboardControllerComponent());
    
    // Adiciona componente de arrastar que cobre toda a tela
    final dragController = DragControllerComponent()
      ..size = size
      ..position = Vector2.zero();
    add(dragController);
  }
  
  void _calculateCellSize() {
    // Calcula o tamanho da célula baseado na tela disponível
    final screenWidth = size.x;
    final screenHeight = size.y;
    
    // Reserva espaço para HUD (aproximadamente 120px)
    final availableHeight = screenHeight - 120;
    final availableWidth = screenWidth * 0.8; // 80% da largura para o jogo
    
    // Calcula baseado nas dimensões do tabuleiro
    final cellSizeByWidth = availableWidth / columns;
    final cellSizeByHeight = availableHeight / rows;
    
    // Usa o menor para manter proporção
    cellSize = min(cellSizeByWidth, cellSizeByHeight);
    cellSize = max(cellSize, 20.0); // Tamanho mínimo
    
    // Atualiza constante global
    GameConstants.cellSize = cellSize;
  }
  
  // Inicializa o sistema de áudio completo
  Future<void> initializeAudio() async {
    try {
      // Sistema de áudio desabilitado temporariamente para evitar erros
      // até que os arquivos de som sejam adicionados
      print('Sistema de áudio desabilitado (arquivos não encontrados)');
    } catch (e) {
      print('Erro ao carregar sons: $e');
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (isGameOver || !gameStarted || isPaused) return;
    
    _dropTimer += dt;
    // Queda automática conforme intervalo
    if (_dropTimer >= dropInterval) {
      _dropTimer = 0;
      if (currentPiece != null) {
        // Tenta mover para baixo
        if (!isCollision(currentPiece!, dx: 0, dy: 1)) {
          currentPiece!.position.y += cellSize;  // move 1 célula para baixo
        } else {
          // Colidiu ao tentar descer -> fixa a peça no lugar
          playSound('drop.mp3');
          lockPiece(currentPiece!);
          clearLines();       // verifica e limpa linhas cheias
          spawnNewPiece();    // gera próxima peça
        }
      }
    }
  }
  
  // Função para iniciar ou reiniciar o jogo
  void startGame() {
    print('🎮 [SNAPRIX] Iniciando jogo...');
    gameStarted = true;
    isPaused = false;
    isGameOver = false;
    score = 0;
    linesCleared = 0;
    level = 1;
    dropInterval = 1.0;
    _dropTimer = 0.0;
    
    // Limpa todos os overlays primeiro
    overlays.clear();
    print('📱 [SNAPRIX] Overlays limpos');
    
    // Resetar estado
    board = List.generate(rows, (_) => List.filled(columns, 0));
    gameBoard.reset();
    print('🎯 [SNAPRIX] Tabuleiro resetado');
    
    // Remover componentes existentes (peças antigas, etc)
    if (currentPiece != null) {
      currentPiece!.removeFromParent();
      currentPiece = null;
    }
    
    // Não adiciona mais controles móveis - usando gestos
    print('👆 [SNAPRIX] Controles por gestos ativados');
    
    // Inicia música de fundo
    startBackgroundMusic();
    
    // Retoma o engine caso estivesse pausado
    resumeEngine();
    print('▶️ [SNAPRIX] Engine retomado');
    
    // Criar a primeira peça
    spawnNewPiece();
    print('🧩 [SNAPRIX] Jogo iniciado com sucesso!');
  }
  
  void pauseGame() {
    if (!gameStarted || isGameOver) return;
    isPaused = true;
    pauseBackgroundMusic();
    pauseEngine(); // pausa o loop do jogo
    overlays.add('PauseMenu');
  }
  
  void resumeGame() {
    isPaused = false;
    overlays.remove('PauseMenu');
    resumeBackgroundMusic();
    resumeEngine(); // retoma o loop do jogo
  }
  
  void resetGame() {
    gameStarted = false;
    isPaused = false;
    isGameOver = false;
    score = 0;
    linesCleared = 0;
    level = 1;
    
    board = List.generate(rows, (_) => List.filled(columns, 0));
    gameBoard.reset();
    
    if (currentPiece != null) {
      currentPiece!.removeFromParent();
      currentPiece = null;
    }
    
    // Limpa overlays se necessário
    
    // Para a música de fundo
    stopBackgroundMusic();
  }
  
  // Gera uma nova peça no topo do tabuleiro
  void spawnNewPiece() {
    // Seleciona aleatoriamente um tipo de Tetromino
    final types = TetrominoType.values;
    TetrominoType newType = types[Random().nextInt(types.length)];
    Tetromino piece = Tetromino(newType);
    print('🧩 [SNAPRIX] Nova peça criada: ${newType.name}');
    
    // Posição inicial: centro do topo, considerando offset do tabuleiro
    piece.position.x = gameBoard.position.x + (columns / 2 - 1) * cellSize;
    piece.position.y = gameBoard.position.y;
    add(piece);
    currentPiece = piece;
    print('📍 [SNAPRIX] Peça posicionada em (${piece.position.x.toInt()}, ${piece.position.y.toInt()})');
    
    // Verifica colisão imediata (se o topo já está ocupado -> Game Over)
    if (isCollision(piece, dx: 0, dy: 0)) {
      // Não consegue colocar nova peça, fim de jogo
      print('💀 [SNAPRIX] Colisão imediata - Game Over!');
      gameOver();
    }
  }
  
  // Verifica colisão se a peça `piece` se mover por dx,dy células
  bool isCollision(Tetromino piece, {int dx = 0, int dy = 0}) {
    // Para cada bloco da peça, calcule sua posição prevista no grid do tabuleiro
    for (var block in piece.blocks) {
      // posição atual em células considerando offset do tabuleiro:
      int col = ((piece.position.x + block.position.x - gameBoard.position.x) / cellSize).round() + dx;
      int row = ((piece.position.y + block.position.y - gameBoard.position.y) / cellSize).round() + dy;
      
      // Checar limites do tabuleiro
      if (col < 0 || col >= columns || row < 0 || row >= rows) {
        return true; // saiu dos limites -> colisão
      }
      
      // Checar se colide com bloco fixo existente
      if (row >= 0 && board[row][col] == 1) {
        return true;
      }
    }
    return false;
  }
  
  // "Congela" a peça atual no tabuleiro (adiciona seus blocos à matriz fixa)
  void lockPiece(Tetromino piece) {
    for (var block in piece.blocks) {
      int col = ((piece.position.x + block.position.x - gameBoard.position.x) / cellSize).round();
      int row = ((piece.position.y + block.position.y - gameBoard.position.y) / cellSize).round();
      
      if (row >= 0 && row < rows && col >= 0 && col < columns) {
        board[row][col] = 1;
        
        // Adiciona bloco visual ao tabuleiro
        Color pieceColor = GameConstants.pieceColors[piece.type.name]!;
        gameBoard.placePiece([Vector2(col.toDouble(), row.toDouble())], pieceColor);
      }
    }
    
    // Remover a peça atual do game (os blocos ficam representados só na matriz agora)
    piece.removeFromParent();
    currentPiece = null;
  }
  
  void clearLines() {
    int linesRemoved = 0;
    // Percorre de baixo para cima (pois remover de baixo facilita gravidade das de cima)
    for (int r = rows - 1; r >= 0; r--) {
      if (board[r].every((cell) => cell == 1)) {
        // Linha completa
        linesRemoved++;
        print('🎯 [SNAPRIX] Linha $r completa!');
        // Toca som de linha completa
        playSound('line_clear.mp3');
        
        // Remove a linha r da matriz
        board.removeAt(r);
        // Insere uma linha vazia no topo da matriz
        board.insert(0, List.filled(columns, 0));
        
        // Atualiza o tabuleiro visual
        gameBoard.clearLines([r]);
        
        r++; // Reprocessa a mesma linha (devido à remoção)
      }
    }
    
    if (linesRemoved > 0) {
      // Atualiza pontuação de acordo com número de linhas de uma vez
      // Exemplo de pontuação: 100 * (2^(linesRemoved-1)) * level
      // 1 linha: 100, 2 linhas: 200, 3: 400, 4: 800 (estas multiplicadas pelo nível atual)
      int pointsEarned = (100 * (1 << (linesRemoved - 1))) * level;
      score += pointsEarned;
      linesCleared += linesRemoved;
      print('💰 [SNAPRIX] $linesRemoved linha(s) removida(s)! +$pointsEarned pontos (Total: $score)');
      
      // Verifica aumento de nível a cada 10 linhas, por exemplo
      if (linesCleared >= level * 10) {
        level++;
        // aumenta a velocidade (diminui intervalo de queda, nunca abaixo de certo limite)
        dropInterval = max(0.1, dropInterval * 0.8); // por ex., aumenta 20% a velocidade
        print('⬆️ [SNAPRIX] Level up! Nível $level (Velocidade: ${dropInterval.toStringAsFixed(2)}s)');
      }
    }
  }
  
  void gameOver() {
    isGameOver = true;
    gameStarted = false;
    playSound('game_over.mp3');
    stopBackgroundMusic();
    pauseEngine();  // pausa o loop do jogo
    // Ativa overlay de Game Over para mostrar mensagem e opções
    overlays.add('GameOver');
  }
  
  // Controles do jogador
  void movePieceLeft() {
    print('🔍 [SNAPRIX] movePieceLeft called - currentPiece: $currentPiece, gameStarted: $gameStarted, isPaused: $isPaused, isGameOver: $isGameOver');
    
    if (currentPiece != null && !isGameOver && gameStarted && !isPaused) {
      print('🔍 [SNAPRIX] Checking collision for left movement...');
      if (!isCollision(currentPiece!, dx: -1, dy: 0)) {
        final oldPos = currentPiece!.position.x;
        currentPiece!.position.x -= cellSize;
        playSound('move.mp3');
        print('⬅️ [SNAPRIX] Peça movida para esquerda: $oldPos -> ${currentPiece!.position.x}');
      } else {
        print('🚫 [SNAPRIX] Movimento esquerda bloqueado por colisão');
      }
    } else {
      print('❌ [SNAPRIX] movePieceLeft - condições não atendidas');
    }
  }
  
  void movePieceRight() {
    print('🔍 [SNAPRIX] movePieceRight called - currentPiece: $currentPiece, gameStarted: $gameStarted, isPaused: $isPaused, isGameOver: $isGameOver');
    
    if (currentPiece != null && !isGameOver && gameStarted && !isPaused) {
      print('🔍 [SNAPRIX] Checking collision for right movement...');
      if (!isCollision(currentPiece!, dx: 1, dy: 0)) {
        final oldPos = currentPiece!.position.x;
        currentPiece!.position.x += cellSize;
        playSound('move.mp3');
        print('➡️ [SNAPRIX] Peça movida para direita: $oldPos -> ${currentPiece!.position.x}');
      } else {
        print('🚫 [SNAPRIX] Movimento direita bloqueado por colisão');
      }
    } else {
      print('❌ [SNAPRIX] movePieceRight - condições não atendidas');
    }
  }
  
  void movePieceDown() {
    if (currentPiece != null && !isGameOver && gameStarted && !isPaused) {
      if (!isCollision(currentPiece!, dx: 0, dy: 1)) {
        currentPiece!.position.y += cellSize;
        playSound('move.mp3');
        print('⬇️ [SNAPRIX] Peça movida para baixo');
      }
    }
  }
  
  void rotatePiece() {
    if (currentPiece != null && !isGameOver && gameStarted && !isPaused) {
      currentPiece!.rotate();
      // se após rotar colidir, desfaz rotação
      if (isCollision(currentPiece!, dx: 0, dy: 0)) {
        // desfazer rotação (3 rotações = rotação anti-horária)
        currentPiece!.rotate();
        currentPiece!.rotate();
        currentPiece!.rotate();
        print('🚫 [SNAPRIX] Rotação bloqueada por colisão');
      } else {
        playSound('rotate.mp3');
        print('🔄 [SNAPRIX] Peça rotacionada');
      }
    }
  }
  
  void hardDrop() {
    if (currentPiece != null && !isGameOver && gameStarted && !isPaused) {
      // "hard drop" - derruba direto até colidir
      while (currentPiece != null && !isCollision(currentPiece!, dx: 0, dy: 1)) {
        currentPiece!.position.y += cellSize;
      }
      // quando colidir, efetua travamento imediato
      playSound('drop.mp3');
      if (currentPiece != null) {
        lockPiece(currentPiece!);
        clearLines();
        spawnNewPiece();
      }
    }
  }
  
  void playSound(String soundName) {
    // Som desabilitado temporariamente
    // try {
    //   FlameAudio.play(soundName);
    // } catch (e) {
    //   print('Som $soundName não encontrado: $e');
    // }
  }
  
  // Controles de música de fundo
  void startBackgroundMusic() {
    // Música desabilitada temporariamente
    // try {
    //   FlameAudio.bgm.play('bgm.mp3');
    //   print('Música de fundo iniciada');
    // } catch (e) {
    //   print('Erro ao iniciar música de fundo: $e');
    // }
  }
  
  void pauseBackgroundMusic() {
    // try {
    //   FlameAudio.bgm.pause();
    // } catch (e) {
    //   print('Erro ao pausar música de fundo: $e');
    // }
  }
  
  void resumeBackgroundMusic() {
    // try {
    //   FlameAudio.bgm.resume();
    // } catch (e) {
    //   print('Erro ao retomar música de fundo: $e');
    // }
  }
  
  void stopBackgroundMusic() {
    // try {
    //   FlameAudio.bgm.stop();
    // } catch (e) {
    //   print('Erro ao parar música de fundo: $e');
    // }
  }
  

  // Limpa recursos de áudio ao fechar o jogo
  @override
  void onRemove() {
    FlameAudio.bgm.dispose();
    super.onRemove();
  }
}

// Componente para capturar eventos de teclado
class KeyboardControllerComponent extends Component 
    with HasGameReference<TetrisGame>, KeyboardHandler {
  
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      
      if (key == LogicalKeyboardKey.escape) {
        if (game.gameStarted && !game.isPaused) {
          game.pauseGame();
        }
        return true;
      }
      
      if (game.currentPiece != null && !game.isGameOver && game.gameStarted && !game.isPaused) {
        if (key == LogicalKeyboardKey.arrowLeft) {
          game.movePieceLeft();
          return true;
        } else if (key == LogicalKeyboardKey.arrowRight) {
          game.movePieceRight();
          return true;
        } else if (key == LogicalKeyboardKey.arrowDown) {
          game.movePieceDown();
          return true;
        } else if (key == LogicalKeyboardKey.arrowUp) {
          game.rotatePiece();
          return true;
        } else if (key == LogicalKeyboardKey.space) {
          game.hardDrop();
          return true;
        }
      }
    }
    return false;
  }
}

// Sistema de Detecção da Direção REAL do Movimento
class DragControllerComponent extends RectangleComponent with HasGameReference<TetrisGame>, TapCallbacks, DragCallbacks {
  Vector2? _startPos;
  Vector2? _dragStartPos;
  double _startTime = 0;
  bool _wasDrag = false;
  
  @override
  Future<void> onLoad() async {
    paint = Paint()..color = const Color(0x00000000);
    print('🎮 [SNAPRIX] REAL Movement Direction Controller loaded');
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    if (!game.gameStarted || game.isPaused || game.isGameOver) return false;
    
    _startPos = event.canvasPosition;
    _startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _wasDrag = false;
    
    print('👆 [SNAPRIX] Touch Down: ${event.canvasPosition}');
    return true;
  }
  
  @override
  bool onTapUp(TapUpEvent event) {
    if (!game.gameStarted || game.isPaused || game.isGameOver || _startPos == null || _wasDrag) return false;
    
    final duration = DateTime.now().millisecondsSinceEpoch / 1000.0 - _startTime;
    final endPos = event.canvasPosition;
    
    // DETECÇÃO REAL DA DIREÇÃO DO MOVIMENTO
    final deltaX = endPos.x - _startPos!.x;
    final deltaY = endPos.y - _startPos!.y;
    final distance = sqrt(deltaX * deltaX + deltaY * deltaY);
    
    print('👆 [SNAPRIX] Touch Up: start=$_startPos, end=$endPos');
    print('👆 [SNAPRIX] Real Movement Analysis: deltaX=${deltaX.toStringAsFixed(1)}, deltaY=${deltaY.toStringAsFixed(1)}, distance=${distance.toStringAsFixed(1)}, duration=${duration.toStringAsFixed(2)}s');
    
    // DETECÇÃO BASEADA NO MOVIMENTO REAL DO DEDO - MAIS SENSÍVEL
    if (distance > 8) { // Reduzido de 15 para 8 pixels - muito mais sensível
      if (deltaX.abs() > deltaY.abs()) {
        // Movimento horizontal predominante
        if (deltaX > 0) {
          // MOVIMENTO REAL PARA DIREITA (deltaX positivo)
          game.movePieceRight();
          print('➡️ [SNAPRIX] REAL Movement RIGHT detected! Finger moved ${deltaX.toStringAsFixed(1)}px to the right');
        } else {
          // MOVIMENTO REAL PARA ESQUERDA (deltaX negativo)
          game.movePieceLeft();
          print('⬅️ [SNAPRIX] REAL Movement LEFT detected! Finger moved ${deltaX.abs().toStringAsFixed(1)}px to the left');
        }
      } else {
        // Movimento vertical predominante
        if (deltaY > 0) {
          // Movimento para baixo
          game.movePieceDown();
          print('⬇️ [SNAPRIX] REAL Movement DOWN detected! Finger moved ${deltaY.toStringAsFixed(1)}px down');
        }
      }
    }
    // Se não houve movimento significativo, é um tap
    else if (distance < 8) { // Ajustado para 8 pixels também
      if (duration < 0.2) { // Reduzido de 0.3 para 0.2s - tap mais rápido
        game.rotatePiece();
        print('🔄 [SNAPRIX] Tap Rotate! (no significant movement)');
      } else if (duration > 0.4) { // Reduzido de 0.5 para 0.4s - long press mais rápido
        game.hardDrop();
        print('🔽 [SNAPRIX] Long Press Hard Drop! (no significant movement)');
      }
    }
    
    _startPos = null;
    return true;
  }
  
  @override
  bool onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!game.gameStarted || game.isPaused || game.isGameOver) return false;
    
    _dragStartPos = event.canvasPosition;
    _startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _wasDrag = true;
    
    print('🖱️ [SNAPRIX] Drag Start: ${event.canvasPosition}');
    return true;
  }
  
  @override
  bool onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!game.gameStarted || game.isPaused || game.isGameOver || _dragStartPos == null) return false;
    
    print('🖱️ [SNAPRIX] Drag End: analyzing movement from drag...');
    
    // Para drags, não temos acesso à posição final no Flame
    // Mas podemos usar uma heurística temporal mais inteligente
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final dragDuration = currentTime - _startTime;
    
    // Se foi um drag rápido horizontal, executa movimento baseado na análise de timing - MAIS SENSÍVEL
    if (dragDuration > 0.03 && dragDuration < 0.6) { // Reduzido mínimo de 0.05 para 0.03s, aumentado máximo para 0.6s
      // Usar a posição inicial do drag como referência
      final startX = _dragStartPos!.x;
      final screenWidth = game.size.x;
      final centerX = screenWidth / 2;
      
      // Se está muito próximo do centro, rotaciona - zona central menor
      if ((startX - centerX).abs() < screenWidth * 0.12) { // Reduzido de 0.15 para 0.12 - zona central menor
        game.rotatePiece();
        print('🔄 [SNAPRIX] Center drag - Rotate!');
      }
      // Se está mais para as laterais, move baseado na posição
      else if (startX < centerX) {
        game.movePieceLeft();
        print('⬅️ [SNAPRIX] Left area drag - Move Left!');
      } else {
        game.movePieceRight();
        print('➡️ [SNAPRIX] Right area drag - Move Right!');
      }
    }
    
    _dragStartPos = null;
    _wasDrag = false;
    return true;
  }
}