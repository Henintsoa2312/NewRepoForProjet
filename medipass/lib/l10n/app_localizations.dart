import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @settings_title.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de l\'Application'**
  String get settings_title;

  /// No description provided for @settings_darkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode Sombre'**
  String get settings_darkMode;

  /// No description provided for @settings_rememberSession.
  ///
  /// In fr, this message translates to:
  /// **'Mémoriser ma session'**
  String get settings_rememberSession;

  /// No description provided for @settings_rememberSession_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rester connecté au prochain démarrage'**
  String get settings_rememberSession_subtitle;

  /// No description provided for @settings_notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settings_language;

  /// No description provided for @settings_about.
  ///
  /// In fr, this message translates to:
  /// **'À propos de Medipass'**
  String get settings_about;

  /// No description provided for @settings_logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get settings_logout;

  /// No description provided for @tab_home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get tab_home;

  /// No description provided for @tab_assistances.
  ///
  /// In fr, this message translates to:
  /// **'Assistances'**
  String get tab_assistances;

  /// No description provided for @tab_contact.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get tab_contact;

  /// No description provided for @tab_entertainments.
  ///
  /// In fr, this message translates to:
  /// **'Divertissements'**
  String get tab_entertainments;

  /// No description provided for @tab_settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get tab_settings;

  /// No description provided for @home_welcome_title.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Medipass'**
  String get home_welcome_title;

  /// No description provided for @home_labs_antananarivo.
  ///
  /// In fr, this message translates to:
  /// **'Laboratoires d\'analyses à Antananarivo'**
  String get home_labs_antananarivo;

  /// No description provided for @home_labs_map_button.
  ///
  /// In fr, this message translates to:
  /// **'Map des laboratoires'**
  String get home_labs_map_button;

  /// No description provided for @home_other_labs_madagascar.
  ///
  /// In fr, this message translates to:
  /// **'Autres laboratoires à Madagascar'**
  String get home_other_labs_madagascar;

  /// No description provided for @contact_need_help.
  ///
  /// In fr, this message translates to:
  /// **'Besoin d\'aide ?'**
  String get contact_need_help;

  /// No description provided for @contact_we_are_here.
  ///
  /// In fr, this message translates to:
  /// **'Nous sommes là pour vous aider. Contactez-nous via les moyens ci-dessous ou consultez notre FAQ.'**
  String get contact_we_are_here;

  /// No description provided for @contact_direct.
  ///
  /// In fr, this message translates to:
  /// **'Contact Direct'**
  String get contact_direct;

  /// No description provided for @contact_send_email.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un e-mail'**
  String get contact_send_email;

  /// No description provided for @contact_call_support.
  ///
  /// In fr, this message translates to:
  /// **'Appeler le support'**
  String get contact_call_support;

  /// No description provided for @contact_our_address.
  ///
  /// In fr, this message translates to:
  /// **'Notre adresse'**
  String get contact_our_address;

  /// No description provided for @contact_faq.
  ///
  /// In fr, this message translates to:
  /// **'Foire Aux Questions'**
  String get contact_faq;

  /// No description provided for @assistances_title.
  ///
  /// In fr, this message translates to:
  /// **'Centre d\'Assistance'**
  String get assistances_title;

  /// No description provided for @assistances_faq_title.
  ///
  /// In fr, this message translates to:
  /// **'FAQ - Questions Fréquentes'**
  String get assistances_faq_title;

  /// No description provided for @assistances_faq_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez des réponses rapides à vos questions.'**
  String get assistances_faq_subtitle;

  /// No description provided for @assistances_live_chat_title.
  ///
  /// In fr, this message translates to:
  /// **'Chat en direct'**
  String get assistances_live_chat_title;

  /// No description provided for @assistances_live_chat_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Parlez à un agent de support.'**
  String get assistances_live_chat_subtitle;

  /// No description provided for @assistances_phone_support_title.
  ///
  /// In fr, this message translates to:
  /// **'Support téléphonique'**
  String get assistances_phone_support_title;

  /// No description provided for @assistances_phone_support_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Appelez-nous pour une aide immédiate.'**
  String get assistances_phone_support_subtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
