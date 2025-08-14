import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/tetris_game.dart';
import 'ad_banner.dart';

/// Sistema de Controles Touch PERFEITO para Tetris Mobile
/// Baseado nas melhores práticas da indústria e pesquisa avançada
class AdvancedTouchControls extends StatefulWidget {
  final TetrisGame game;

  const AdvancedTouchControls({Key? key, required this.game}) : super(key: key);

  @override
  State<AdvancedTouchControls> createState() => _AdvancedTouchControlsState();
}

class _AdvancedTouchControlsState extends State<AdvancedTouchControls> {
  // Controle de zones ativas
  String? _activeZone;
  bool _isProcessingGesture = false;
  
  // Controle de velocidade de movimento
  DateTime? _lastMoveTime;
  static const Duration _moveThrottle = Duration(milliseconds: 120); // Atraso entre movimentos
  
  // Configurações de sensibilidade
  static const double _minSwipeDistance = 50.0;
  static const double _minSwipeVelocity = 100.0;
  static const Duration _tapTimeout = Duration(milliseconds: 150);
  static const Duration _longPressThreshold = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _triggerHaptic(HapticType type) {
    switch (type) {
      case HapticType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  void _showFeedback(String zone) {
    // Apenas feedback háptico - SEM visual
    // Zona gravada apenas para referência interna se necessário
    _activeZone = zone;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    
    return Stack(
      children: [
        // ===== ZONA DE CONTROLE TOTAL POR ARRASTAR =====
        Positioned(
          top: safeArea.top,
          left: 0,
          right: 0,
          bottom: 100, // Acima do banner
          child: _FullScreenDragZone(
            onDragMove: (direction) {
              // Controle de velocidade - só executa se passou tempo suficiente
              final now = DateTime.now();
              if (_lastMoveTime == null || now.difference(_lastMoveTime!) > _moveThrottle) {
                _lastMoveTime = now;
                
                if (direction == DragDirection.left) {
                  widget.game.movePieceLeft();
                  _triggerHaptic(HapticType.selection);
                } else if (direction == DragDirection.right) {
                  widget.game.movePieceRight();
                  _triggerHaptic(HapticType.selection);
                } else if (direction == DragDirection.down) {
                  widget.game.movePieceDown();
                  _triggerHaptic(HapticType.selection);
                }
              }
            },
            onTap: () {
              // Tap = rotação
              widget.game.rotatePiece();
              _triggerHaptic(HapticType.light);
            },
            onLongPress: () {
              // Long press = pause
              widget.game.pauseGame();
              _triggerHaptic(HapticType.heavy);
            },
          ),
        ),

        // Pause removido - usar long press na zona central

        // SEM feedback visual - apenas háptico

        // ===== BANNER PUBLICITÁRIO =====
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Center(
                child: AdBannerWidget(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ===== DIREÇÕES DE ARRASTAR =====
enum DragDirection {
  left,
  right,
  down,
  up,
}

// ===== ZONA DE CONTROLE TOTAL POR ARRASTAR =====
class _FullScreenDragZone extends StatelessWidget {
  final Function(DragDirection) onDragMove;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FullScreenDragZone({
    required this.onDragMove,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onPanUpdate: (details) {
        // Sensibilidade AUMENTADA com controle de velocidade
        final minDragDistance = 10.0; // Reduzido de 15.0 para 10.0 (mais sensível)
        final dx = details.delta.dx;
        final dy = details.delta.dy;
        
        // Detecta direção baseada no movimento do dedo
        if (dx.abs() > minDragDistance || dy.abs() > minDragDistance) {
          if (dx.abs() > dy.abs()) {
            // Movimento horizontal predominante
            if (dx > 0) {
              // Arrastar para direita
              onDragMove(DragDirection.right);
            } else {
              // Arrastar para esquerda
              onDragMove(DragDirection.left);
            }
          } else {
            // Movimento vertical predominante
            if (dy > 0) {
              // Arrastar para baixo
              onDragMove(DragDirection.down);
            }
          }
        }
      },
      child: Container(
        color: Colors.transparent, // COMPLETAMENTE INVISÍVEL
        child: SizedBox.expand(), // Ocupa toda a área disponível
      ),
    );
  }
}



// SISTEMA TOUCH PURO - SEM ELEMENTOS VISUAIS

// ===== TIPOS DE HAPTIC FEEDBACK =====
enum HapticType {
  light,
  medium,
  heavy,
  selection,
}