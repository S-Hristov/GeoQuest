import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'auth_widgets.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AuthScaffold(
      title: l.welcomeBack,
      subtitle: l.continueJourney,
      isSignIn: true,
      button: l.signIn,
      footerLead: l.dontHaveAccount,
      footerAction: l.signUp,
      footerRoute: '/sign-up',
    );
  }
}
