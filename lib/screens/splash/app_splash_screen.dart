import 'package:flutter/material.dart';

class AppSplashScreen extends StatelessWidget {
  const AppSplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5B63F2), Color(0xFF7D57F3)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: const [
            Spacer(flex: 3),
            _LogoCard(),
            SizedBox(height: 28),
            Text(
              'GeoQuest',
              style: TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Explore Bulgaria',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 34 * .5,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 44),
            _Dots(),
            Spacer(flex: 4),
          ],
        ),
      ),
    ),
  );
}

class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) => Container(
    width: 168,
    height: 168,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .20),
      borderRadius: BorderRadius.circular(38),
      boxShadow: const [
        BoxShadow(
          color: Color(0x30000000),
          blurRadius: 20,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Image.asset('assets/app_logo.png', fit: BoxFit.cover),
      ),
    ),
  );
}

class _Dots extends StatelessWidget {
  const _Dots();

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _Dot(active: true),
      SizedBox(width: 8),
      _Dot(active: false),
      SizedBox(width: 8),
      _Dot(active: false),
    ],
  );
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      color: active ? Colors.white : Colors.white70,
      shape: BoxShape.circle,
    ),
  );
}
