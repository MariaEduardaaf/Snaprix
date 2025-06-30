// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get gameTitle => 'Snaprix';

  @override
  String get playButton => '🎮 プレイ';

  @override
  String get gameOver => '💀 ゲームオーバー';

  @override
  String get statistics => '🏆 統計';

  @override
  String get score => '💰 スコア';

  @override
  String get level => '📊 レベル';

  @override
  String get lines => '📏 ライン';

  @override
  String get playAgain => '🎮 もう一度プレイ';

  @override
  String get mainMenu => '🏠 メインメニュー';

  @override
  String get motivationalMessage => '頑張って続けよう！💪';

  @override
  String get pause => '⏸️ 一時停止';

  @override
  String get resume => '▶️ 再開';

  @override
  String get settings => '⚙️ 設定';

  @override
  String get paused => '一時停止';

  @override
  String get continueGame => '続ける';

  @override
  String get restart => '再始動';

  @override
  String get exitToMenu => 'メニューに戻る';
}
