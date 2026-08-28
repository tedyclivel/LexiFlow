import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/widgets/coin_animation.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/widgets/premium_button.dart';

class SuccessDialog extends StatefulWidget {
  final int score;
  final String timeUsed;
  final int wordsFound;
  final int totalWords;
  final int speedBonus;
  final bool isNewWorldUnlocked;
  final VoidCallback onNext;
  final VoidCallback onMenu;

  const SuccessDialog({
    super.key,
    required this.score,
    required this.timeUsed,
    required this.wordsFound,
    required this.totalWords,
    required this.speedBonus,
    this.isNewWorldUnlocked = false,
    required this.onNext,
    required this.onMenu,
  });

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> {
  bool _isOpened = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        SoundService.playVictory();
        setState(() => _isOpened = true);
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) SoundService.playReward();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Trigger particles and coins
    Future.microtask(() {
      if (context.mounted) {
        final center = MediaQuery.of(context).size.center(Offset.zero);
        CoinAnimationManager.show(
          context: context,
          startOffset: center,
          coinCount: (widget.score ~/ 10).clamp(5, 20),
        );
      }
    });

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              LexiColors.primaryBlue.withOpacity(0.95),
              const Color(0xFF0F172A).withOpacity(0.98),
            ],
          ),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: LexiColors.accentTeal.withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: LexiColors.accentTeal.withOpacity(0.2),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              "NIVEAU RÉUSSI !",
              textAlign: TextAlign.center,
              style: GoogleFonts.bungee(
                fontSize: R.fs(context, 26),
                color: LexiColors.accentTeal,
                letterSpacing: 2,
              ),
            ).animate().shimmer(duration: 2.seconds).scale(duration: 400.ms, curve: Curves.easeOutBack),
            
            if (widget.isNewWorldUnlocked)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: LexiColors.accentOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: LexiColors.accentOrange),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: LexiColors.accentOrange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "NOUVEAU MONDE DÉBLOQUÉ !",
                        style: LexiTextStyles.label(color: LexiColors.accentOrange, fontSize: 12),
                      ),
                    ],
                  ),
                ).animate().shimmer(duration: 1.seconds).fadeIn(),
              ),
            
            const SizedBox(height: 32),
            
            // Score Display
            Column(
              children: [
                Text(
                  "SCORE TOTAL",
                  style: GoogleFonts.bungee(
                    fontSize: 14,
                    color: Colors.white54,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${widget.score}",
                  style: GoogleFonts.bungee(
                    fontSize: R.fs(context, 64),
                    color: Colors.white,
                    height: 1,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Stats Grid
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem("TEMPS", widget.timeUsed, Icons.timer_outlined, LexiColors.accentTeal),
                  _buildStatItem("MOTS", "${widget.wordsFound}", Icons.grid_view_rounded, Colors.cyan),
                  _buildStatItem("BONUS", "+${widget.speedBonus}", Icons.stars_rounded, Colors.amber),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 40),
            
            // Actions
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded, size: 28),
                label: Text(
                  "CONTINUER",
                  style: GoogleFonts.bungee(fontSize: R.fs(context, 20), letterSpacing: 1),
                ),
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LexiColors.accentTeal,
                  foregroundColor: LexiColors.primaryBlue,
                  elevation: 8,
                  shadowColor: LexiColors.accentTeal.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 12),
            
            TextButton(
              onPressed: widget.onMenu,
              child: Text(
                "RETOUR AU MENU",
                style: GoogleFonts.bungee(
                  color: Colors.white24,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: R.fs(context, 10),
            fontWeight: FontWeight.w800,
            color: Colors.white38,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
