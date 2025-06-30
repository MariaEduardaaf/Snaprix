# Arquitetura do Tetris Game

## Estrutura de Pastas

### 📁 `game/`
Contém a classe principal do jogo e lógica central
- `tetris_game.dart` - Classe principal que estende FlameGame

### 📁 `components/`
Componentes reutilizáveis do jogo usando o Flame Component System (FCS)
- `block.dart` - Componente GameBlock para blocos individuais
- `tetromino.dart` - Componente para as peças do Tetris (I, O, T, S, Z, J, L)
- `game_board.dart` - Gerencia o tabuleiro e colisões
- `hud.dart` - Interface do usuário (pontuação, nível, etc.)

### 📁 `overlays/`
Widgets Flutter que são sobrepostos ao jogo
- `main_menu.dart` - Menu principal
- `pause_menu.dart` - Menu de pausa
- `game_over_menu.dart` - Menu de fim de jogo

### 📁 `utils/`
Utilitários e constantes do jogo
- `constants.dart` - Todas as constantes do jogo (tamanhos, cores, formas das peças, etc.)

## Componentes Principais

### TetrisGame (FlameGame)
- Gerencia o loop principal do jogo
- Controla estado (started, paused, gameOver)
- Coordena componentes
- Implementa lógica de pontuação e níveis

### GameBoard (Component)
- Matriz 10x20 para representar o tabuleiro
- Detecção de colisões
- Limpeza de linhas completas
- Gerenciamento de blocos estáticos

### Tetromino (Component)
- Representa uma peça do Tetris
- Contém múltiplas rotações
- Métodos para movimento e rotação
- Criação aleatória de peças

### GameBlock (RectangleComponent)
- Bloco individual com posição no grid
- Renderização com bordas
- Componente visual básico

## Fluxo do Jogo

1. **Inicialização**: `onLoad()` carrega componentes e recursos
2. **Loop Principal**: `update(dt)` controla queda das peças
3. **Controles**: `KeyboardControllerComponent` processa entrada do teclado
4. **Estados**: Menus gerenciam transições entre estados do jogo

## Constantes Configuráveis

- Tamanho do grid: 10x20 células
- Tamanho de cada célula: 30px
- Velocidade inicial: 1 segundo por queda
- Pontuação: 100 pontos por linha × nível
- Progressão de nível: a cada 10 linhas

## Áudio

Suporte completo a efeitos sonoros:
- Movimento das peças
- Rotação
- Limpeza de linhas  
- Game over

Arquivos devem estar em `assets/audio/` no formato MP3.