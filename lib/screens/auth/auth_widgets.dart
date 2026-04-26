import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class AuthScaffold extends StatefulWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.button,
    required this.footerLead,
    required this.footerAction,
    required this.footerRoute,
    required this.isSignIn,
    super.key,
  });

  final String title;
  final String subtitle;
  final String button;
  final String footerLead;
  final String footerAction;
  final String footerRoute;
  final bool isSignIn;

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _busy = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _passwordsMatch =>
      widget.isSignIn || _password.text == _confirmPassword.text;

  bool get _canSubmit => !_busy && _passwordsMatch;

  @override
  void initState() {
    super.initState();
    _password.addListener(_onFormChanged);
    _confirmPassword.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!mounted || widget.isSignIn) return;
    setState(() {});
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!widget.isSignIn && !_passwordsMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).authPasswordMismatch),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    final state = context.read<AppState>();
    final ok = widget.isSignIn
        ? await state.signInWithEmail(_email.text, _password.text)
        : await state.signUpWithEmail(
            name: _name.text,
            email: _email.text,
            password: _password.text,
          );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).authFailed)),
    );
  }

  @override
  Widget build(BuildContext context) => MobileFrame(
    backgroundColor: AppColors.primary,
    child: Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.purpleGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(32, 54, 32, 28),
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 14),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 52),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 22,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (!widget.isSignIn) ...[
                      AuthField(
                        controller: _name,
                        hint: AppLocalizations.of(context).authFullNameHint,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 20),
                    ],
                    AuthField(
                      controller: _email,
                      hint: AppLocalizations.of(context).authEmailHint,
                      icon: Icons.mail_outline,
                    ),
                    const SizedBox(height: 20),
                    AuthField(
                      controller: _password,
                      hint: AppLocalizations.of(context).authPasswordHint,
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      onToggleObscure: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    if (!widget.isSignIn) ...[
                      const SizedBox(height: 20),
                      AuthField(
                        controller: _confirmPassword,
                        hint:
                            '${AppLocalizations.of(context).confirm} '
                            '${AppLocalizations.of(context).authPasswordHint}',
                        icon: Icons.lock_outline,
                        obscure: _obscureConfirmPassword,
                        onToggleObscure: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (widget.isSignIn)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            AppLocalizations.of(context).forgotPassword,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    SizedBox(height: widget.isSignIn ? 6 : 0),
                    WhiteAuthButton(
                      label: widget.button,
                      enabled: _canSubmit,
                      loading: _busy,
                      onTap: _submit,
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.white24)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            AppLocalizations.of(context).or,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .5),
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.white24)),
                      ],
                    ),
                    const SizedBox(height: 28),
                    WhiteAuthButton(
                      label: AppLocalizations.of(context).google,
                      googleIcon: true,
                      loading: _busy,
                      onTap: () async {
                        if (_busy) return;
                        setState(() => _busy = true);
                        final ok = await context
                            .read<AppState>()
                            .signInWithGoogle();
                        if (!mounted) return;
                        setState(() => _busy = false);
                        if (ok) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          widget.footerLead,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            widget.footerRoute,
                          ),
                          child: Text(
                            widget.footerAction,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              Text(
                AppLocalizations.of(context).authTerms,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .45),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class AuthField extends StatelessWidget {
  const AuthField({
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.onToggleObscure,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.white54),
      suffixIcon: onToggleObscure != null
          ? IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white38,
              ),
              onPressed: onToggleObscure,
            )
          : null,
      hintStyle: const TextStyle(color: Colors.white54),
      fillColor: Colors.white.withValues(alpha: .16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .18)),
      ),
    ),
  );
}

class WhiteAuthButton extends StatelessWidget {
  const WhiteAuthButton({
    required this.label,
    required this.onTap,
    this.googleIcon = false,
    this.loading = false,
    this.enabled = true,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final bool googleIcon;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    width: double.infinity,
    child: FilledButton(
      onPressed: loading || !enabled ? null : onTap,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (googleIcon) ...[
                    const GoogleMark(size: 20),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
    ),
  );
}

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _GoogleMarkPainter());
}

class _GoogleMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .18;
    final rect = Offset.zero & size;
    void arc(Color color, double start, double sweep) {
      canvas.drawArc(
        rect.deflate(stroke / 2),
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    arc(const Color(0xFF4285F4), -.15, 1.55);
    arc(const Color(0xFF34A853), 1.25, 1.35);
    arc(const Color(0xFFFBBC05), 2.55, .95);
    arc(const Color(0xFFEA4335), 3.45, 1.45);
    final y = size.height * .52;
    canvas.drawLine(
      Offset(size.width * .52, y),
      Offset(size.width * .92, y),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
