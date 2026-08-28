import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search_word/screens/world_selection_screen.dart';
import 'package:search_word/screens/multiplayer_lobby_screen.dart';
import 'package:search_word/widgets/daily_challenge_panel.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:search_word/widgets/game_background.dart';
import 'package:search_word/widgets/currency_bar.dart';

class PlayHubScreen extends StatefulWidget {
  const PlayHubScreen({super.key});

  @override
  State<PlayHubScreen> createState() => _PlayHubScreenState();
}

class _PlayHubScreenState extends State<PlayHubScreen> {
  @override
  void initState() {
    super.initState();
    SoundService.startHubAmbient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    children: [
                      _HubButton(
// ... rest of the file
                        label: "SOLO",
                        subtitle: "Parcourez les mondes",
                        icon: Icons.map_outlined,
                        color: LexiColors.accentTeal,
                        onPressed: () {
                          SoundService.playNavigation();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const WorldSelectionScreen()));
                        },
                      ),
                      const SizedBox(height: 20),
                      _HubButton(
                        label: "MULTIJOUEUR",
                        subtitle: "Défiez vos amis",
                        icon: Icons.people_outline,
                        color: LexiColors.primaryBlue,
                        onPressed: () {
                          SoundService.playNavigation();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MultiplayerLobbyScreen()));
                        },
                      ),
                      const SizedBox(height: 40),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 20),
                      Text(
                        "DÉFIS QUOTIDIENS",
                        style: GoogleFonts.bungee(color: Colors.white54, fontSize: R.fs(context, 14)),
                      ),
                      const SizedBox(height: 16),
                      const DailyChallengePanel(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          const CurrencyBar(),
          const Spacer(),
          Text(
            "JOUER",
            style: GoogleFonts.bungee(fontSize: R.fs(context, 20), color: Colors.white, letterSpacing: 2),
          ),
        ],
      ),
    );
  }
}

class _HubButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _HubButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(R.sp(context, 16)), // Reduced from 24
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(R.sp(context, 28)), // Reduced from 32
              border: Border.all(color: color.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, spreadRadius: -5),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(R.sp(context, 12)), // Reduced from 16
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(R.sp(context, 16)), // Reduced from 20
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.3), blurRadius: 8),
                    ],
                  ),
                  child: Icon(icon, color: color, size: R.sp(context, 28)), // Reduced from 36
                ),
                SizedBox(width: R.sp(context, 20)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.bungee(fontSize: R.fs(context, 18), color: Colors.white), // Reduced from 22
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.white60, fontSize: R.fs(context, 11)), // Reduced from 13
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
              ],
            ),
          ),
          // Decorative background icon (Cartoon style)
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.1,
              child: Transform.rotate(
                angle: -0.2,
                child: Icon(icon, size: 100, color: Colors.white),
              ),
            ),
          ),
        ],
      ).animate().slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
    );
  }
}
