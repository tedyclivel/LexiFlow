import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/utils/design_system.dart';

class LexiFlowTextLogo extends StatelessWidget {
  final double fontSize;
  const LexiFlowTextLogo({super.key, this.fontSize = 48});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            // Bottom shadow/offset layer
            Text(
              "LexiFlow",
              style: GoogleFonts.bungee(
                fontSize: fontSize,
                color: Colors.black38,
                letterSpacing: 2,
              ),
            ).animate().move(begin: const Offset(4, 4), end: const Offset(4, 4)),
            
            // Middle highlight layer
            Text(
              "LexiFlow",
              style: GoogleFonts.bungee(
                fontSize: fontSize,
                color: LexiColors.accentOrange,
                shadows: [
                  const Shadow(color: Colors.white, blurRadius: 10, offset: Offset(-2, -2)),
                ],
              ),
            ),
            
            // Top gradient layer
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Colors.white70],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: Text(
                "LexiFlow",
                style: GoogleFonts.bungee(
                  fontSize: fontSize,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 4,
          width: fontSize * 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                LexiColors.accentOrange,
                LexiColors.accentTeal,
                LexiColors.accentPurple,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ).animate(onPlay: (controller) => controller.repeat())
         .shimmer(duration: 2.seconds, color: Colors.white)
         .scale(duration: 1.seconds, begin: const Offset(0.8, 1), end: const Offset(1.2, 1)),
      ],
    ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms);
  }
}
