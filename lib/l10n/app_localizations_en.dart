// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get gameTitle => 'Snaprix';

  @override
  String get playButton => '🎮 PLAY';

  @override
  String get gameOver => '💀 GAME OVER';

  @override
  String get statistics => '🏆 STATISTICS';

  @override
  String get score => '💰 SCORE';

  @override
  String get level => '📊 LEVEL';

  @override
  String get lines => '📏 LINES';

  @override
  String get playAgain => '🎮 PLAY AGAIN';

  @override
  String get mainMenu => '🏠 MAIN MENU';

  @override
  String get motivationalMessage => 'Keep trying! 💪';

  @override
  String get pause => '⏸️ PAUSE';

  @override
  String get resume => '▶️ RESUME';

  @override
  String get settings => '⚙️ SETTINGS';

  @override
  String get paused => 'Paused';

  @override
  String get continueGame => 'Continue';

  @override
  String get restart => 'Restart';

  @override
  String get exitToMenu => 'Exit to Menu';
}
