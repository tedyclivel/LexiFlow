import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search_word/screens/blitz_mode_screen.dart';
import 'package:search_word/screens/game_screen.dart';
import 'package:search_word/screens/shop_screen.dart';
import 'package:search_word/screens/world_selection_screen.dart';
import 'package:search_word/models/level_model.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:search_word/widgets/currency_bar.dart';
import 'package:search_word/widgets/game_background.dart';
import 'package:search_word/widgets/lexiflow_text_logo.dart';

class ExplorerHubScreen extends StatefulWidget {
  const ExplorerHubScreen({super.key});

  @override
  State<ExplorerHubScreen> createState() => _ExplorerHubScreenState();
}

class _ExplorerHubScreenState extends State<ExplorerHubScreen> {
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      Center(child: LexiFlowTextLogo(fontSize: R.fs(context, 40))),
                      SizedBox(height: R.sp(context, 32)),
                      _HubButton(
                        label: "BLITZ",
                        subtitle: "Rapide et intense",
                        icon: Icons.bolt,
                        color: LexiColors.accentOrange,
                        onPressed: () {
                          SoundService.playNavigation();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BlitzModeScreen()));
                        },
                      ),
                      const SizedBox(height: 20),
                      _HubButton(
                        label: "CHAOS",
                        subtitle: "Grille dynamique",
                        icon: Icons.cyclone,
                        color: LexiColors.accentPurple,
                        imagePath: 'assets/images/chaos_mode_banner_1771433655574.png', // Fallback to icon if asset missing
                        onPressed: () {
                          SoundService.playNavigation();
                          final chaosLevel = Level(
                            id: 888,
                            name: "CHAOS TOTAL",
                            rows: 10,
                            cols: 10,
                            words: ["CHAOS", "DYNAMIQUE", "VORTEX", "FLUX", "AGITATION", "MELANGE"],
                            timeLimit: 180,
                            mode: GameMode.chaos,
                            worldId: 888,
                            worldName: "Chaos",
                          );
                          Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(level: chaosLevel)));
                        },
                      ),
                      const SizedBox(height: 20),
                      _HubButton(
                        label: "BOUTIQUE",
                        subtitle: "Customise ton jeu",
                        icon: Icons.shopping_bag_outlined,
                        color: const Color(0xFFFF6B00),
                        onPressed: () {
                          SoundService.playNavigation();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
                        },
                      ),
                      const SizedBox(height: 20),
                      _HubButton(
                        label: "SPÉCIAUX",
                        subtitle: "Nouveaux horizons",
                        icon: Icons.auto_awesome_outlined,
                        color: LexiColors.accentTeal,
                        onPressed: () {
                          SoundService.playNavigation();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const WorldSelectionScreen()));
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
            "EXPLORER",
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
  final String? imagePath;

  const _HubButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Stack(
          children: [
            // Background Image/Illustration
            Positioned.fill(
              child: imagePath != null 
                ? Opacity(
                    opacity: 0.3,
                    child: Image.asset(
                      imagePath!, 
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(icon, size: 80, color: color.withOpacity(0.1)),
                      ),
                    ),
                  )
                : Center(
                    child: Opacity(
                      opacity: 0.05,
                      child: Icon(icon, size: 100, color: color),
                    ),
                  ),
            ),
            
            // Subtle Gradient Overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(R.sp(context, 16)), // Reduced from 20
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(R.sp(context, 12)), // Reduced from 12
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.3), blurRadius: 10),
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
                        style: GoogleFonts.bungee(
                          fontSize: R.fs(context, 18), // Reduced from 22
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: R.fs(context, 11), // Reduced from 13
                        ),
                      ),
                    ],
                    ),
                  ),
                  Icon(Icons.play_circle_fill_rounded, color: color, size: R.sp(context, 30)),
                ],
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
    );
  }
}
