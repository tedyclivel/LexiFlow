import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/widgets/premium_button.dart';

class GameOverDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  const GameOverDialog({
    super.key,
    required this.onRetry,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: R.sp(context, 40)),
      child: Container(
        padding: EdgeInsets.all(R.sp(context, 20)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.shade900.withOpacity(0.95),
              const Color(0xFF0F172A).withOpacity(0.98),
            ],
          ),
          borderRadius: BorderRadius.circular(R.sp(context, 28)),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_off_rounded,
              color: Colors.redAccent,
              size: R.sp(context, 48), // Reduced from 64
            ).animate().shake(duration: 500.ms).fadeIn(),
            
            SizedBox(height: R.sp(context, 12)),
            
            Text(
              "TEMPS ÉCOULÉ !",
              textAlign: TextAlign.center,
              style: GoogleFonts.bungee(
                fontSize: R.fs(context, 20), // Reduced from 22
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            
            SizedBox(height: R.sp(context, 6)),
            
            Text(
              "Dommage, essayez encore !",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: R.fs(context, 13), // Reduced from 14
              ),
            ),
            
            SizedBox(height: R.sp(context, 24)), // Reduced from 32
            
            SizedBox(
              height: R.sp(context, 50),
              width: double.infinity,
              child: PremiumButton(
                label: "RÉESSAYER",
                isPrimary: true,
                backgroundColor: Colors.redAccent,
                onPressed: onRetry,
              ),
            ),
            
            SizedBox(height: R.sp(context, 8)),
            
            TextButton(
              onPressed: onMenu,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "RETOUR AU MENU",
                style: GoogleFonts.bungee(
                  color: Colors.white24,
                  fontSize: R.fs(context, 10),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }
}
