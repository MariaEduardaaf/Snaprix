import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../game/tetris_game.dart';
import '../l10n/app_localizations.dart';

class MainMenu extends StatelessWidget {
  final TetrisGame game;

  const MainMenu({Key? key, required this.game}) : super(key: key);
  
  // Detecta se é mobile ou desktop
  bool get isMobile {
    return defaultTargetPlatform == TargetPlatform.android ||
           defaultTargetPlatform == TargetPlatform.iOS;
  }
  
  bool get isDesktop {
    return defaultTargetPlatform == TargetPlatform.windows ||
           defaultTargetPlatform == TargetPlatform.macOS ||
           defaultTargetPlatform == TargetPlatform.linux;
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
                  // Logo animado
                  TweenAnimationBuilder(
                    duration: const Duration(seconds: 2),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: 0.8 + (value * 0.2),
                        child: Opacity(
                          opacity: value,
                          child: Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.gameTitle,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 40 : 56,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00FFFF),
                                  letterSpacing: 4,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 0),
                                      color: const Color(0xFF00FFFF).withValues(alpha: 0.5),
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
                              const SizedBox(height: 8),
                              const SizedBox.shrink(), // Remove subtitle
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Botão Jogar modernizado
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00FFFF),
                          Color(0xFF0099CC),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FFFF).withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        game.overlays.remove('MainMenu');
                        game.startGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 40 : 60,
                          vertical: isSmallScreen ? 15 : 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.playButton,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Slogan elegante
                  Container(
                    constraints: BoxConstraints(maxWidth: isSmallScreen ? 280 : 350),
                    child: Text(
                      'O clássico jogo de quebra-cabeças\nreimaginado para a era digital',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.6,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Características do jogo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureIcon(Icons.speed, 'Rápido', isSmallScreen),
                      SizedBox(width: isSmallScreen ? 25 : 35),
                      _buildFeatureIcon(Icons.touch_app, 'Intuitivo', isSmallScreen),
                      SizedBox(width: isSmallScreen ? 25 : 35),
                      _buildFeatureIcon(Icons.star, 'Clássico', isSmallScreen),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Rodapé
                  Text(
                    'Versão 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white30,
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
  
  // Ícone de característica do jogo
  Widget _buildFeatureIcon(IconData icon, String label, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 45 : 55,
          height: isSmallScreen ? 45 : 55,
          decoration: BoxDecoration(
            color: const Color(0xFF00FFFF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isSmallScreen ? 22 : 27),
            border: Border.all(
              color: const Color(0xFF00FFFF).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF00FFFF),
            size: isSmallScreen ? 22 : 26,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}