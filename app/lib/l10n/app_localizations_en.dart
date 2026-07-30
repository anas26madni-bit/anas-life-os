// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Anas Life OS';

  @override
  String get startingTitle => 'Preparing your private workspace';

  @override
  String get startingMessage => 'Checking the secure offline foundation.';

  @override
  String get foundationReadyTitle => 'Foundation ready';

  @override
  String get foundationReadyMessage =>
      'Anas Life OS is ready for its next approved sprint. No personal data or product features are active yet.';

  @override
  String get foundationErrorTitle => 'Secure foundation unavailable';

  @override
  String get foundationErrorMessage =>
      'The local encrypted database engine could not be verified. No data was created. Retry after checking the installation.';

  @override
  String get retry => 'Retry';
}
