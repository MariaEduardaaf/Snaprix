import 'package:flutter/material.dart';
import '../game/tetris_game.dart';
import '../l10n/app_localizations.dart';

class GameOverMenu extends StatelessWidget {
  final TetrisGame game;

  const GameOverMenu({Key? key, required this.game}) : super(key: key);

  String _formatScore(int score) {
    if (score < 1000) return score.toString();
    if (score < 1000000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return '${(score / 1000000).toStringAsFixed(1)}M';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400 || screenHeight < 600;
    
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF000814),
              const Color(0xFF001D3D),
              const Color(0xFF003566),
              const Color(0xFF001122),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título Game Over animado
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1500),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: 0.5 + (value * 0.5),
                        child: Opacity(
                          opacity: value,
                          child: Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.gameOver,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 32 : 42,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF4444),
                                  letterSpacing: 3,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 0),
                                      color: const Color(0xFFFF4444).withValues(alpha: 0.5),
                                      blurRadius: 20,
                                    ),
                                    Shadow(
                                      offset: const Offset(3, 3),
                                      color: Colors.black.withValues(alpha: 0.8),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Container de estatísticas
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00FFFF).withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FFFF).withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.statistics,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00FFFF),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Pontuação principal
                        _buildStatRow(
                          AppLocalizations.of(context)!.score,
                          _formatScore(game.score),
                          const Color(0xFFFFD700),
                          isSmallScreen,
                          isMain: true,
                        ),
                        const SizedBox(height: 15),
                        
                        // Estatísticas secundárias
                        _buildStatRow(
                          AppLocalizations.of(context)!.level,
                          '${game.level}',
                          const Color(0xFFFF8C00),
                          isSmallScreen,
                        ),
                        const SizedBox(height: 10),
                        
                        _buildStatRow(
                          AppLocalizations.of(context)!.lines,
                          '${game.linesCleared}',
                          const Color(0xFF32CD32),
                          isSmallScreen,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Botões modernizados
                  Column(
                    children: [
                      // Botão Jogar Novamente
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF00FF88),
                              Color(0xFF00CC66),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF88).withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            game.overlays.remove('GameOver');
                            game.startGame();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 15 : 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.playAgain,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Botão Menu
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF00FFFF).withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            game.overlays.remove('GameOver');
                            game.overlays.add('MainMenu');
                            game.resetGame();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.mainMenu,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00FFFF),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Mensagem motivacional
                  Text(
                    AppLocalizations.of(context)!.motivationalMessage,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white60,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, Color color, bool isSmallScreen, {bool isMain = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? (isMain ? 16 : 14) : (isMain ? 20 : 16),
            fontWeight: isMain ? FontWeight.bold : FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? (isMain ? 20 : 16) : (isMain ? 28 : 20),
            fontWeight: FontWeight.bold,
            color: color,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}