import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/screens/profile_screen.dart';
import 'package:search_word/screens/leaderboard_screen.dart';
import 'package:search_word/screens/settings_screen.dart';
import 'package:search_word/widgets/game_background.dart';
import 'package:search_word/widgets/currency_bar.dart';

class ProfileHubScreen extends StatelessWidget {
  const ProfileHubScreen({super.key});

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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
// ... existing button code
                      _HubButton(
                        label: "STATISTIQUES",
                        subtitle: "Tes performances",
                        icon: Icons.analytics_outlined,
                        color: LexiColors.accentTeal,
                        onPressed: () {
                          SoundService.playNavigation();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                        },
                      ),
                      const SizedBox(height: 20),
                      _HubButton(
                        label: "CLASSEMENT",
                        subtitle: "Les meilleurs joueurs",
                        icon: Icons.emoji_events_outlined,
                        color: const Color(0xFFFFD700),
                        onPressed: () {
                          SoundService.playNavigation();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
                        },
                      ),
                      const SizedBox(height: 20),
                      _HubButton(
                        label: "PARAMÈTRES",
                        subtitle: "Son et préférences",
                        icon: Icons.settings_outlined,
                        color: const Color(0xFF64748B),
                        onPressed: () {
                          SoundService.playNavigation();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                        },
                      ),
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
            "PROFIL",
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
      child: Container(
        padding: EdgeInsets.all(R.sp(context, 16)), // Reduced from 20
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(R.sp(context, 24)), // Reduced from 28
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: R.sp(context, 28)), // Reduced from 32
            SizedBox(width: R.sp(context, 16)), // Reduced from 20
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.bungee(fontSize: R.fs(context, 16), color: Colors.white), // Reduced from 18
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white54, fontSize: R.fs(context, 11)), // Reduced from 12
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 24),
          ],
        ),
      ).animate().slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
    );
  }
}
