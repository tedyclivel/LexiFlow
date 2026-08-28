import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search_word/models/level_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/screens/game_screen.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/widgets/premium_button.dart';
import 'package:search_word/utils/sound_service.dart';

class ModePreviewDialog extends StatelessWidget {
  final Level level;

  const ModePreviewDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    String description = "";
    IconData icon = Icons.play_arrow;
    Color color = Colors.indigo;

    switch (level.mode) {
      case GameMode.classic:
        description = "Le mode standard. Trouvez tous les mots cachés horizontalement, verticalement ou en diagonale.";
        icon = Icons.emoji_events_outlined;
        color = Colors.indigo;
        break;
      case GameMode.timed:
        description = "Course contre la montre ! Trouvez tous les mots avant la fin du temps imparti.";
        icon = Icons.timer_outlined;
        color = Colors.orange;
        break;
      case GameMode.zen:
        description = "Pas de stress. Prenez tout votre temps pour explorer la grille à votre rythme.";
        icon = Icons.self_improvement;
        color = Colors.teal;
        break;
      case GameMode.hard:
        description = "Le défi ultime ! Les mots peuvent être inversés et placés dans toutes les directions.";
        icon = Icons.bolt;
        color = Colors.deepPurple;
        break;
      case GameMode.blitz:
        description = "Mode rapide ! Enchaînez les grilles le plus vite possible avant que le temps ne s'écoule.";
        icon = Icons.flash_on;
        color = LexiColors.accentOrange;
        break;
      case GameMode.chaos:
        description = "Préparez-vous au chaos ! Les lettres bougent et se mélangent périodiquement.";
        icon = Icons.cyclone; 
        color = Colors.redAccent;
        break;
      case GameMode.multiplayer:
        description = "Défiez vos amis ou des joueurs en ligne dans des duels épiques !";
        icon = Icons.people;
        color = Colors.amber;
        break;
    }

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
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative Glow Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: Icon(icon, size: 56, color: color),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack).shimmer(delay: 1.seconds, duration: 1500.ms),
            
            const SizedBox(height: 24),
            
            Text(
              level.mode.name.toUpperCase(),
              style: GoogleFonts.bungee(
                fontSize: 14,
                color: color,
                letterSpacing: 2.5,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              level.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.bungee(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Stats Row in a stylized container
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem(Icons.grid_4x4, "${level.rows}x${level.cols}", "GRILLE"),
                  _buildInfoItem(Icons.format_list_bulleted, "${level.words.length}", "MOTS"),
                  if (level.mode != GameMode.zen)
                    _buildInfoItem(Icons.timer_outlined, "${level.timeLimit}s", "CHRONO"),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Launch Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: Text(
                  "COMMENCER",
                  style: GoogleFonts.bungee(fontSize: 18, letterSpacing: 1),
                ),
                onPressed: () {
                  SoundService.playNavigation();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GameScreen(level: level)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: color.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.white38),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.bungee(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.white38,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
