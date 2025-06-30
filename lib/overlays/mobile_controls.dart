import 'package:flutter/material.dart';
import '../game/tetris_game.dart';

class MobileControls extends StatelessWidget {
  final TetrisGame game;

  const MobileControls({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Controles de movimento (esquerda)
          Row(
            children: [
              _buildControlButton(
                icon: Icons.arrow_left,
                onPressed: () => game.movePieceLeft(),
                color: Colors.blue,
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlButton(
                    icon: Icons.rotate_right,
                    onPressed: () => game.rotatePiece(),
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 10),
                  _buildControlButton(
                    icon: Icons.arrow_downward,
                    onPressed: () => game.movePieceDown(),
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              _buildControlButton(
                icon: Icons.arrow_right,
                onPressed: () => game.movePieceRight(),
                color: Colors.blue,
              ),
            ],
          ),
          
          // Controles de ação (direita)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControlButton(
                icon: Icons.pause,
                onPressed: () => game.pauseGame(),
                color: Colors.orange,
                size: 50,
              ),
              const SizedBox(height: 10),
              _buildControlButton(
                icon: Icons.keyboard_double_arrow_down,
                onPressed: () => game.hardDrop(),
                color: Colors.red,
                size: 60,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    double size = 50,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Icon(
            icon,
            color: Colors.white,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }
}