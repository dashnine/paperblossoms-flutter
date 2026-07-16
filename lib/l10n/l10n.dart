import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// Shorthand for the generated localizations lookup.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
