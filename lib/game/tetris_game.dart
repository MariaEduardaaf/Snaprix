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
import '../services/sound_service.dart';

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
  double dropInterval = 0.8; // começa um pouco mais rápido (era 1.0s)
  
  // Controle interno de tempo para queda
  double _dropTimer = 0.0;
  
  // Flags de estado
  bool isGameOver = false;
  bool isPaused = false;
  bool gameStarted = false;
  
  // Sistema HOLD
  Tetromino? heldPiece;
  bool canHold = true;
  
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
    
    // Adiciona fundo animado do jogo
    add(AnimatedBackground());
    
    // Inicializa o sistema de áudio
    await initializeAudio();
    
    // Inicializa componentes de interface
    gameBoard = GameBoard();
    hud = HudComponent();
    
    // Separação clara entre HUD e tabuleiro - LAYOUT REVOLUCIONÁRIO
    final boardWidth = columns * cellSize;
    final boardHeight = rows * cellSize;
    final safeAreaTop = 50.0; // Mesmo valor usado no HUD
    final hudHeight = 60.0; // HUD COMPACTO - só título SNAPRIX
    final hudTotalHeight = safeAreaTop + hudHeight; // Altura total ocupada pelo HUD: 110px
    final separationMargin = 25.0; // Margem MENOR - stats agora estão no topo
    final controlsMargin = 150.0; // MARGEM REDUZIDA para mais espaço do tabuleiro
    final horizontalMargin = 3.0; // Margem SUPER MÍNIMA nas laterais para MAXIMIZAR tabuleiro
    
    // Tabuleiro começa DEPOIS do HUD + margem de separação  
    final boardStartY = hudTotalHeight + separationMargin; // 110 + 25 = 135px do topo
    final availableGameHeight = size.y - boardStartY - controlsMargin;
    final verticalOffset = boardStartY + (availableGameHeight - boardHeight) / 2;
    
    // CENTRALIZAÇÃO HORIZONTAL - stats no topo liberam as laterais
    final horizontalOffset = (size.x - boardWidth) / 2;
    
    gameBoard.position = Vector2(
      horizontalOffset,
      verticalOffset,
    );
    
    print('🎯 [SNAPRIX] LAYOUT FINAL - Tabuleiro centralizado: ${gameBoard.position}, tamanho: ${boardWidth.toInt()}x${boardHeight.toInt()}');
    print('📱 [SNAPRIX] Stats no topo: 0-${hudTotalHeight.toInt()}px | Tabuleiro: ${boardStartY.toInt()}px+ | Banner+Controles: ${controlsMargin.toInt()}px');
    print('🔥 [SNAPRIX] TABULEIRO GIGANTE - Células de ${cellSize.toStringAsFixed(1)}px = Área total: ${(boardWidth * boardHeight).toInt()}px²');
    
    add(gameBoard);
    add(hud);
    add(KeyboardControllerComponent());
    
    // Sistema de controles touch avançado implementado via overlays
    // Não precisa mais do DragController antigo
  }
  
  void _calculateCellSize() {
    // LAYOUT REVOLUCIONÁRIO - Calcula célula para máxima área de jogo
    final screenWidth = size.x;
    final screenHeight = size.y;
    
    // LAYOUT CENTRADO: Stats no topo + tabuleiro centralizado
    final hudSpace = 60 + 50 + 30; // HUD (60) + SafeArea (50) + separação (30) = 140px - REDUZIDO
    final controlsSpace = 160; // REDUZIDO espaço para controles + banner
    final horizontalMargin = 5; // Margem SUPER MÍNIMA para maximizar tabuleiro
    final safetyMargin = 10; // Margem mínima REDUZIDA
    
    final availableHeight = screenHeight - hudSpace - controlsSpace - safetyMargin;
    final availableWidth = screenWidth - (horizontalMargin * 2); // Margens simétricas
    
    // Calcula baseado nas dimensões do tabuleiro
    final cellSizeByWidth = availableWidth / columns;
    final cellSizeByHeight = availableHeight / rows;
    
    // Usa o menor para manter proporção mas MAXIMIZA o espaço
    cellSize = min(cellSizeByWidth, cellSizeByHeight);
    
    // Tamanho mínimo um pouco menor
    cellSize = max(cellSize, 32.0);
    
    // Tamanho máximo reduzido para ficar mais compacto
    cellSize = min(cellSize, 48.0);
    
    print('🎯 [SNAPRIX] LAYOUT REVOLUCIONÁRIO - Célula: ${cellSize.toStringAsFixed(1)}px');
    print('📱 [SNAPRIX] Tela: ${screenWidth.toInt()}x${screenHeight.toInt()}');
    print('🏗️ [SNAPRIX] Tabuleiro: ${(cellSize * columns).toInt()}x${(cellSize * rows).toInt()}');
    print('📊 [SNAPRIX] Aproveitamento: ${((cellSize * columns * cellSize * rows) / (screenWidth * screenHeight) * 100).toStringAsFixed(1)}%');
    
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
    dropInterval = 0.8;
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
    
    // Adicionar controles touch avançados
    overlays.add('AdvancedTouchControls');
    print('🎮 [SNAPRIX] Controles touch AVANÇADOS ativados');
    
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
    overlays.remove('AdvancedTouchControls');
    overlays.add('PauseMenu');
  }
  
  void resumeGame() {
    isPaused = false;
    overlays.remove('PauseMenu');
    overlays.add('AdvancedTouchControls');
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
    
    // Limpa overlays
    overlays.remove('PauseMenu');
    overlays.remove('GameOver');
    overlays.remove('AdvancedTouchControls');
    
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
    
    // Resetar possibilidade de usar hold para a nova peça
    canHold = true;
    
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
        SoundService.playLevelUp(); // Toca som de level up
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
    // Remove controles e ativa overlay de Game Over
    overlays.remove('AdvancedTouchControls');
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
  
  void softDrop() {
    if (currentPiece != null && !isGameOver && gameStarted && !isPaused) {
      // Acelera a queda por algumas unidades
      for (int i = 0; i < 3; i++) {
        if (!isCollision(currentPiece!, dx: 0, dy: 1)) {
          currentPiece!.position.y += cellSize;
        } else {
          break;
        }
      }
      playSound('move.mp3');
    }
  }
  
  void rotatePieceCounterClockwise() {
    if (currentPiece != null && !isGameOver && gameStarted && !isPaused) {
      // Rotação anti-horária = 3 rotações horárias
      for (int i = 0; i < 3; i++) {
        currentPiece!.rotate();
      }
      // se após rotar colidir, desfaz rotação
      if (isCollision(currentPiece!, dx: 0, dy: 0)) {
        // desfazer rotação (1 rotação horária)
        currentPiece!.rotate();
        print('🚫 [SNAPRIX] Rotação anti-horária bloqueada por colisão');
      } else {
        playSound('rotate.mp3');
        print('🔄 [SNAPRIX] Peça rotacionada anti-horária');
      }
    }
  }
  
  void holdPiece() {
    if (currentPiece != null && canHold && !isGameOver && gameStarted && !isPaused) {
      if (heldPiece == null) {
        // Primeira vez usando hold
        heldPiece = currentPiece;
        heldPiece!.removeFromParent();
        currentPiece = null;
        spawnNewPiece();
      } else {
        // Troca a peça atual pela que está em hold
        Tetromino temp = currentPiece!;
        temp.removeFromParent();
        
        currentPiece = heldPiece;
        currentPiece!.position.x = gameBoard.position.x + (columns / 2 - 1) * cellSize;
        currentPiece!.position.y = gameBoard.position.y;
        add(currentPiece!);
        
        heldPiece = temp;
      }
      
      canHold = false; // Só pode usar hold uma vez por peça
      playSound('hold.mp3');
      print('📦 [SNAPRIX] Peça colocada em hold');
    }
  }
  
  void playSound(String soundName) {
    try {
      // Sistema de efeitos sonoros reais usando SoundService
      switch (soundName) {
        case 'move.mp3':
          SoundService.playMove();
          break;
        case 'rotate.mp3':
          SoundService.playRotate();
          break;
        case 'drop.mp3':
          SoundService.playDrop();
          break;
        case 'line_clear.mp3':
          SoundService.playLineClear();
          break;
        case 'game_over.mp3':
          SoundService.playGameOver();
          break;
        case 'hold.mp3':
          SoundService.playHold();
          break;
      }
      print('🔊 [SNAPRIX] Som: $soundName (efeitos sonoros procedurais)');
    } catch (e) {
      print('Som $soundName erro: $e');
    }
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

// SISTEMA ANTIGO DE CONTROLES REMOVIDO
// Agora usamos apenas AdvancedTouchControls via overlays

// Fundo animado do jogo
class AnimatedBackground extends Component with HasGameReference<TetrisGame> {
  final List<BackgroundParticle> particles = [];
  final Random _random = Random();
  
  @override
  Future<void> onLoad() async {
    // Cria partículas para o fundo
    for (int i = 0; i < 30; i++) {
      particles.add(BackgroundParticle(
        position: Vector2(
          _random.nextDouble() * game.size.x,
          _random.nextDouble() * game.size.y,
        ),
        velocity: Vector2(
          (_random.nextDouble() - 0.5) * 20,
          (_random.nextDouble() - 0.5) * 20,
        ),
        size: _random.nextDouble() * 3 + 1,
        color: Color.fromARGB(
          (_random.nextInt(50) + 20),
          _random.nextInt(100) + 50,
          _random.nextInt(150) + 100,
          _random.nextInt(200) + 55,
        ),
      ));
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    for (final particle in particles) {
      particle.update(dt, game.size);
    }
  }
  
  @override
  void render(Canvas canvas) {
    // Fundo base com gradiente
    final backgroundRect = Rect.fromLTWH(0, 0, game.size.x, game.size.y);
    final backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF000814),
        const Color(0xFF001D3D),
        const Color(0xFF003566),
        const Color(0xFF001122),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    
    final backgroundPaint = Paint()
      ..shader = backgroundGradient.createShader(backgroundRect);
    
    canvas.drawRect(backgroundRect, backgroundPaint);
    
    // Renderiza partículas
    for (final particle in particles) {
      particle.render(canvas);
    }
  }
}

// Partícula para o fundo animado
class BackgroundParticle {
  Vector2 position;
  Vector2 velocity;
  double size;
  Color color;
  double alpha = 1.0;
  double rotation = 0.0;
  
  BackgroundParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
  });
  
  void update(double dt, Vector2 screenSize) {
    position += velocity * dt;
    rotation += dt;
    
    // Envelhecimento da partícula
    alpha = (alpha - dt * 0.1).clamp(0.0, 1.0);
    
    // Reposiciona se sair da tela
    if (position.x < -size || position.x > screenSize.x + size ||
        position.y < -size || position.y > screenSize.y + size) {
      final random = Random();
      position = Vector2(
        random.nextDouble() * screenSize.x,
        random.nextDouble() * screenSize.y,
      );
      alpha = 1.0;
    }
  }
  
  void render(Canvas canvas) {
    if (alpha <= 0) return;
    
    final paint = Paint()
      ..color = color.withValues(alpha: alpha * 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
    
    canvas.save();
    canvas.translate(position.x, position.y);
    canvas.rotate(rotation);
    
    // Desenha partícula como um pequeno diamante
    final path = Path()
      ..moveTo(0, -size)
      ..lineTo(size, 0)
      ..lineTo(0, size)
      ..lineTo(-size, 0)
      ..close();
    
    canvas.drawPath(path, paint);
    canvas.restore();
  }
}