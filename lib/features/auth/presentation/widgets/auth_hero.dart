import 'package:flutter/material.dart';

/// A hero header with a background image and dark gradient overlay.
/// Used on login and register screens for a premium feel.
class AuthHero extends StatelessWidget {
  final double height;

  const AuthHero({super.key, this.height = 260});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: Image.asset(
              'assets/images/wedding_hero.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.15),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Logo centered
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 300,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
