import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
  ];

  /// The title of the game
  ///
  /// In en, this message translates to:
  /// **'Snaprix'**
  String get gameTitle;

  /// Button to start playing the game
  ///
  /// In en, this message translates to:
  /// **'🎮 PLAY'**
  String get playButton;

  /// Game over title
  ///
  /// In en, this message translates to:
  /// **'💀 GAME OVER'**
  String get gameOver;

  /// Statistics section title
  ///
  /// In en, this message translates to:
  /// **'🏆 STATISTICS'**
  String get statistics;

  /// Player's score label
  ///
  /// In en, this message translates to:
  /// **'💰 SCORE'**
  String get score;

  /// Player's level label
  ///
  /// In en, this message translates to:
  /// **'📊 LEVEL'**
  String get level;

  /// Lines cleared label
  ///
  /// In en, this message translates to:
  /// **'📏 LINES'**
  String get lines;

  /// Button to play again
  ///
  /// In en, this message translates to:
  /// **'🎮 PLAY AGAIN'**
  String get playAgain;

  /// Button to return to main menu
  ///
  /// In en, this message translates to:
  /// **'🏠 MAIN MENU'**
  String get mainMenu;

  /// Motivational message shown on game over
  ///
  /// In en, this message translates to:
  /// **'Keep trying! 💪'**
  String get motivationalMessage;

  /// Pause button text
  ///
  /// In en, this message translates to:
  /// **'⏸️ PAUSE'**
  String get pause;

  /// Resume button text
  ///
  /// In en, this message translates to:
  /// **'▶️ RESUME'**
  String get resume;

  /// Settings button text
  ///
  /// In en, this message translates to:
  /// **'⚙️ SETTINGS'**
  String get settings;

  /// Paused game title
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueGame;

  /// Restart button text
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// Exit to menu button text
  ///
  /// In en, this message translates to:
  /// **'Exit to Menu'**
  String get exitToMenu;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'ja',
    'pt',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
