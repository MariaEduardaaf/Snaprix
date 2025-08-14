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
        // ===== ZONA DE MOVIMENTO ESQUERDA =====
        Positioned(
          top: safeArea.top,
          left: 0,
          width: screenSize.width * 0.25,
          height: screenSize.height * 0.75,
          child: _MovementZone(
            direction: MovementDirection.left,
            onMove: () {
              widget.game.movePieceLeft();
              _triggerHaptic(HapticType.selection);
              _showFeedback('move_left');
            },
            onContinuousMove: () {
              // Movimento contínuo para swipe longo
              widget.game.movePieceLeft();
            },
          ),
        ),

        // ===== ZONA DE MOVIMENTO DIREITA =====
        Positioned(
          top: safeArea.top,
          right: 0,
          width: screenSize.width * 0.25,
          height: screenSize.height * 0.75,
          child: _MovementZone(
            direction: MovementDirection.right,
            onMove: () {
              widget.game.movePieceRight();
              _triggerHaptic(HapticType.selection);
              _showFeedback('move_right');
            },
            onContinuousMove: () {
              widget.game.movePieceRight();
            },
          ),
        ),

        // ===== ZONA CENTRAL (Rotação e Pause) =====
        Positioned(
          top: safeArea.top,
          left: screenSize.width * 0.25,
          right: screenSize.width * 0.25,
          height: screenSize.height * 0.65,
          child: _CentralGhostZone(
            onTap: () {
              // Tap no centro = rotação
              widget.game.rotatePiece();
              _triggerHaptic(HapticType.light);
              _showFeedback('rotation');
            },
            onDoubleTab: () {
              // Double tap = rotação 180°
              widget.game.rotatePiece();
              widget.game.rotatePiece();
              _triggerHaptic(HapticType.medium);
              _showFeedback('rotation');
            },
            onLongPress: () {
              // Long press = pausa
              widget.game.pauseGame();
              _triggerHaptic(HapticType.heavy);
            },
          ),
        ),

        // ===== ZONA DE SOFT DROP (Base Centro) =====
        Positioned(
          bottom: 100, // Acima do banner
          left: screenSize.width * 0.25,
          right: screenSize.width * 0.25,
          height: screenSize.height * 0.1,
          child: _SoftDropZone(
            onSoftDrop: () {
              widget.game.movePieceDown();
              _triggerHaptic(HapticType.selection);
              _showFeedback('drop');
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

// ===== ZONA DE SOFT DROP (BASE CENTRO) =====
class _SoftDropZone extends StatelessWidget {
  final VoidCallback onSoftDrop;

  const _SoftDropZone({
    required this.onSoftDrop,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSoftDrop,
      child: Container(
        color: Colors.transparent, // COMPLETAMENTE INVISÍVEL
      ),
    );
  }
}

// ===== ZONA DE MOVIMENTO =====
enum MovementDirection { left, right }

class _MovementZone extends StatelessWidget {
  final MovementDirection direction;
  final VoidCallback onMove;
  final VoidCallback onContinuousMove;

  const _MovementZone({
    required this.direction,
    required this.onMove,
    required this.onContinuousMove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onMove,
      onPanUpdate: (details) {
        // Movimento contínuo durante o swipe
        final velocity = direction == MovementDirection.left 
            ? -details.delta.dx 
            : details.delta.dx;
        if (velocity > 0) {
          onContinuousMove();
        }
      },
      child: Container(
        color: Colors.transparent, // COMPLETAMENTE INVISÍVEL
      ),
    );
  }
}


// ===== ZONA CENTRAL FANTASMA =====
class _CentralGhostZone extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onDoubleTab;
  final VoidCallback onLongPress;

  const _CentralGhostZone({
    required this.onTap,
    required this.onDoubleTab,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTab,
      onLongPress: onLongPress,
      child: Container(
        color: Colors.transparent, // COMPLETAMENTE INVISÍVEL
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