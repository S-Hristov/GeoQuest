import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'auth_widgets.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AuthScaffold(
      title: l.createAccount,
      subtitle: l.startAdventure,
      isSignIn: false,
      button: l.createAccount,
      footerLead: l.alreadyHaveAccount,
      footerAction: l.signIn,
      footerRoute: '/sign-in',
    );
  }
}
