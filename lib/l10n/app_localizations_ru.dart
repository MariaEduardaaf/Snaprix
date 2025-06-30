// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get gameTitle => 'Snaprix';

  @override
  String get playButton => '🎮 ИГРАТЬ';

  @override
  String get gameOver => '💀 ИГРА ОКОНЧЕНА';

  @override
  String get statistics => '🏆 СТАТИСТИКА';

  @override
  String get score => '💰 СЧЁТ';

  @override
  String get level => '📊 УРОВЕНЬ';

  @override
  String get lines => '📏 ЛИНИИ';

  @override
  String get playAgain => '🎮 ИГРАТЬ СНОВА';

  @override
  String get mainMenu => '🏠 ГЛАВНОЕ МЕНЮ';

  @override
  String get motivationalMessage => 'Продолжай пробовать! 💪';

  @override
  String get pause => '⏸️ ПАУЗА';

  @override
  String get resume => '▶️ ПРОДОЛЖИТЬ';

  @override
  String get settings => '⚙️ НАСТРОЙКИ';

  @override
  String get paused => 'ПАУЗА';

  @override
  String get continueGame => 'ПРОДОЛЖИТЬ';

  @override
  String get restart => 'ПЕРЕЗАПУСК';

  @override
  String get exitToMenu => 'ВЫЙТИ В МЕНЮ';
}
