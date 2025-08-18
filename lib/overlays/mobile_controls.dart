import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/tetris_game.dart';

class MobileControls extends StatefulWidget {
  final TetrisGame game;

  const MobileControls({Key? key, required this.game}) : super(key: key);

  @override
  State<MobileControls> createState() => _MobileControlsState();
}

class _MobileControlsState extends State<MobileControls> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Controles mínimos - Esquerda
        Positioned(
          bottom: 100, // Desceu um pouco para melhor alcance
          left: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rotação única
              _buildCompactButton(
                icon: Icons.refresh,
                color: Colors.purple,
                size: 48,
                onPressed: () => widget.game.rotatePiece(),
              ),
              const SizedBox(height: 10),
              // Movimento horizontal
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCompactButton(
                    icon: Icons.keyboard_arrow_left,
                    color: Colors.blue,
                    size: 48,
                    onPressed: () => widget.game.movePieceLeft(),
                  ),
                  const SizedBox(width: 10),
                  _buildCompactButton(
                    icon: Icons.keyboard_arrow_right,
                    color: Colors.blue,
                    size: 48,
                    onPressed: () => widget.game.movePieceRight(),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Controles mínimos - Direita
        Positioned(
          bottom: 100, // Desceu um pouco para melhor alcance
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCompactButton(
                icon: Icons.vertical_align_bottom,
                color: Colors.red,
                size: 48,
                onPressed: () => widget.game.hardDrop(),
              ),
              const SizedBox(height: 10),
              _buildCompactButton(
                icon: Icons.keyboard_arrow_down,
                color: Colors.green,
                size: 48,
                onPressed: () => widget.game.movePieceDown(),
              ),
            ],
          ),
        ),
        
        // Pause compacto
        Positioned(
          top: 50,
          right: 15,
          child: _buildCompactButton(
            icon: Icons.pause,
            color: Colors.grey,
            size: 40,
            onPressed: () => widget.game.pauseGame(),
          ),
        ),
        
      ],
    );
  }

  // Botão compacto e minimalista
  Widget _buildCompactButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    double size = 48,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size * 0.3),
          onTap: () {
            onPressed();
            HapticFeedback.lightImpact();
          },
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: size * 0.55,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}