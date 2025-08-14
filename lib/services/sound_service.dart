import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';

/// Serviço de sons sintéticos para Tetris
/// Gera sons procedurais sem necessidade de arquivos de áudio
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  static bool _soundEnabled = true;
  static double _volume = 0.7;

  /// Ativa/desativa sons
  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Define volume (0.0 a 1.0)
  static void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  /// Toca som de movimento da peça
  static Future<void> playMove() async {
    if (!_soundEnabled) return;
    
    try {
      // Som sutil de movimento - freq baixa e rápida
      await _playTone(220, 80); // A3, 80ms
      HapticFeedback.lightImpact();
    } catch (e) {
      print('Erro som movimento: $e');
    }
  }

  /// Toca som de rotação da peça
  static Future<void> playRotate() async {
    if (!_soundEnabled) return;
    
    try {
      // Som de rotação - duas notas rápidas
      await _playTone(330, 60); // E4, 60ms
      await Future.delayed(const Duration(milliseconds: 20));
      await _playTone(440, 60); // A4, 60ms
      HapticFeedback.selectionClick();
    } catch (e) {
      print('Erro som rotação: $e');
    }
  }

  /// Toca som de queda da peça
  static Future<void> playDrop() async {
    if (!_soundEnabled) return;
    
    try {
      // Som de queda - freq descendente
      await _playSweep(440, 220, 150); // A4 para A3, 150ms
      HapticFeedback.mediumImpact();
    } catch (e) {
      print('Erro som queda: $e');
    }
  }

  /// Toca som de linha completa
  static Future<void> playLineClear() async {
    if (!_soundEnabled) return;
    
    try {
      // Som épico de linha - arpejo ascendente
      await _playTone(330, 80);  // E4
      await Future.delayed(const Duration(milliseconds: 30));
      await _playTone(415, 80);  // G#4
      await Future.delayed(const Duration(milliseconds: 30));
      await _playTone(523, 80);  // C5
      await Future.delayed(const Duration(milliseconds: 30));
      await _playTone(659, 120); // E5 - mais longo
      
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.lightImpact();
      });
    } catch (e) {
      print('Erro som linha: $e');
    }
  }

  /// Toca som de game over
  static Future<void> playGameOver() async {
    if (!_soundEnabled) return;
    
    try {
      // Som dramático de game over - sequência descendente
      await _playTone(523, 200); // C5
      await Future.delayed(const Duration(milliseconds: 50));
      await _playTone(466, 200); // A#4
      await Future.delayed(const Duration(milliseconds: 50));
      await _playTone(392, 200); // G4
      await Future.delayed(const Duration(milliseconds: 50));
      await _playTone(330, 400); // E4 - longo e dramático
      
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.heavyImpact();
      });
    } catch (e) {
      print('Erro som game over: $e');
    }
  }

  /// Toca som de hold/guardar peça
  static Future<void> playHold() async {
    if (!_soundEnabled) return;
    
    try {
      // Som suave de hold - acorde
      await _playTone(294, 100); // D4
      await _playTone(370, 100); // F#4 (simultâneo)
      HapticFeedback.selectionClick();
    } catch (e) {
      print('Erro som hold: $e');
    }
  }

  /// Toca som de nível up
  static Future<void> playLevelUp() async {
    if (!_soundEnabled) return;
    
    try {
      // Som de conquista - arpejo maior
      await _playTone(523, 100); // C5
      await Future.delayed(const Duration(milliseconds: 20));
      await _playTone(659, 100); // E5
      await Future.delayed(const Duration(milliseconds: 20));
      await _playTone(784, 100); // G5
      await Future.delayed(const Duration(milliseconds: 20));
      await _playTone(1047, 200); // C6 - oitava
      
      HapticFeedback.mediumImpact();
    } catch (e) {
      print('Erro som level up: $e');
    }
  }

  /// Toca um tom puro por determinada duração
  static Future<void> _playTone(double frequency, int durationMs) async {
    // Por limitações do Flutter web e mobile, vamos usar SystemSound
    // Em uma implementação real, você usaria um gerador de áudio customizado
    
    // Mapeia frequências para SystemSounds disponíveis
    if (frequency < 250) {
      SystemSound.play(SystemSoundType.click);
    } else if (frequency < 400) {
      SystemSound.play(SystemSoundType.click);
    } else {
      SystemSound.play(SystemSoundType.click);
    }
    
    await Future.delayed(Duration(milliseconds: durationMs));
  }

  /// Toca um sweep de frequência (glissando)
  static Future<void> _playSweep(double startFreq, double endFreq, int durationMs) async {
    // Simula sweep com múltiplos tons
    const steps = 5;
    final stepDuration = durationMs ~/ steps;
    final freqStep = (endFreq - startFreq) / steps;
    
    for (int i = 0; i < steps; i++) {
      final freq = startFreq + (freqStep * i);
      await _playTone(freq, stepDuration);
    }
  }

  /// Sistema de música ambiente (opcional)
  static Future<void> startBackgroundMusic() async {
    if (!_soundEnabled) return;
    
    try {
      // Música ambiente minimalista - loop de acordes suaves
      _playAmbientLoop();
    } catch (e) {
      print('Erro música ambiente: $e');
    }
  }

  static Future<void> _playAmbientLoop() async {
    // Loop infinito de música ambiente sutil
    while (_soundEnabled) {
      // Acorde Am (ambiente melancólico)
      await _playTone(220, 1000); // A3
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // Acorde C (mais alegre)
      await _playTone(262, 1000); // C4
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // Acorde G (resolução)
      await _playTone(196, 1000); // G3
      await Future.delayed(const Duration(milliseconds: 4000));
    }
  }

  static void stopBackgroundMusic() {
    // Para a música ambiente
    _soundEnabled = false;
    Future.delayed(const Duration(milliseconds: 100), () {
      _soundEnabled = true; // Reativa apenas efeitos
    });
  }
}

/// Extensão para facilitar uso no jogo
extension TetrisSounds on Object {
  void playMoveSound() => SoundService.playMove();
  void playRotateSound() => SoundService.playRotate();
  void playDropSound() => SoundService.playDrop();
  void playLineClearSound() => SoundService.playLineClear();
  void playGameOverSound() => SoundService.playGameOver();
  void playHoldSound() => SoundService.playHold();
  void playLevelUpSound() => SoundService.playLevelUp();
}