import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/models/level_model.dart';
import 'package:search_word/data/level_data.dart';
import 'package:search_word/widgets/lexiflow_logo.dart';
import 'package:search_word/widgets/mode_preview_dialog.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/utils/design_system.dart';

class HomeScreen extends StatelessWidget {
  final World world;
  const HomeScreen({super.key, required this.world});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [world.color, const Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                    Text(
                      world.name.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(width: 40), // Balance
                  ],
                ),
              ),

              const SizedBox(height: 40),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mondes ${world.name}",
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      world.description,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).moveY(begin: 20, end: 0),

              const SizedBox(height: 40),

              // Level List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: world.levels.length,
                  itemBuilder: (context, index) {
                    final level = world.levels[index];
                    return _buildLevelCard(context, level, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, Level level, int index) {
    Color modeColor = Colors.indigoAccent;
    IconData modeIcon = Icons.star;

    switch (level.mode) {
      case GameMode.timed:
        modeColor = Colors.orangeAccent;
        modeIcon = Icons.timer_outlined;
        break;
      case GameMode.zen:
        modeColor = Colors.tealAccent;
        modeIcon = Icons.self_improvement;
        break;
      case GameMode.hard:
        modeColor = Colors.deepPurpleAccent;
        modeIcon = Icons.bolt;
        break;
      case GameMode.classic:
        modeColor = Colors.indigoAccent;
        modeIcon = Icons.emoji_events_outlined;
        break;
      case GameMode.blitz:
        modeColor = LexiColors.accentOrange;
        modeIcon = Icons.flash_on;
        break;
      case GameMode.chaos:
        modeColor = Colors.redAccent;
        modeIcon = Icons.cyclone;
        break;
      case GameMode.multiplayer:
        modeColor = Colors.amber;
        modeIcon = Icons.people;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => ModePreviewDialog(level: level),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  // Icon / ID
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [modeColor, modeColor.withOpacity(0.6)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Icon(modeIcon, color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.name,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              level.mode.name.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: modeColor,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "•",
                              style: TextStyle(color: Colors.white.withOpacity(0.3)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${level.words.length} MOTS",
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.4),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (400 + (index * 100)).ms).moveX(begin: 20, end: 0);
  }
}
