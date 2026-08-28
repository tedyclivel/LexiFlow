import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_word/data/level_data.dart';
import 'package:search_word/screens/home_screen.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/providers/profile_provider.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/widgets/premium_button.dart';

import 'package:search_word/widgets/game_background.dart';
import 'package:search_word/widgets/lexiflow_text_logo.dart';
import 'package:search_word/widgets/world_theme_image.dart';

class WorldSelectionScreen extends ConsumerStatefulWidget {
  const WorldSelectionScreen({super.key});

  @override
  ConsumerState<WorldSelectionScreen> createState() => _WorldSelectionScreenState();
}

class _WorldSelectionScreenState extends ConsumerState<WorldSelectionScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.sp(context, 20), vertical: R.sp(context, 16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PremiumIconButton(
                      icon: Icons.arrow_back_ios_new,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      size: 48,
                      onPressed: () => Navigator.pop(context),
                      isBackButton: true,
                    ),
                    LexiFlowTextLogo(fontSize: R.fs(context, 24)),
                    const SizedBox(width: 48), // Balance
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.sp(context, 32)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Explorez",
                      style: LexiTextStyles.heading(
                        fontSize: R.fs(context, 36),
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Choisissez votre voyage thématique.",
                      style: LexiTextStyles.body(
                        fontSize: 16,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).moveY(begin: 20, end: 0),

              const SizedBox(height: 40),

              // World Carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: LevelData.worlds.length,
                  itemBuilder: (context, index) {
                    final world = LevelData.worlds[index];
                    return _buildWorldCard(world, index == _currentPage);
                  },
                ),
              ),

              const SizedBox(height: 40),
              
              // Page Indicators
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(LevelData.worlds.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
              
              SizedBox(height: R.sp(context, 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorldCard(World world, bool isActive) {
    final profile = ref.watch(profileProvider);
    final isLocked = profile == null || !profile.unlockedWorldIds.contains(world.id);

    return AnimatedScale(
      scale: isActive ? 1.0 : 0.85,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      child: GestureDetector(
        onTap: () {
          if (isLocked) {
            SoundService.playError();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Monde verrouillé ! Terminez le monde précédent pour débloquer.",
                    style: LexiTextStyles.body(color: Colors.white)),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(24),
              ),
            );
          } else {
            SoundService.playClick();
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => HomeScreen(world: world)));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: world.color,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: world.color.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Stack(
              children: [
                Positioned.fill(
                  child: WorldThemeImage(
                    worldId: world.id,
                    width: 600,
                    height: 800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        world.color.withOpacity(0.5),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                "VERROUILLÉ",
                                style: LexiTextStyles.label(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${world.levels.length} NIVEAUX",
                            style: LexiTextStyles.label(
                              fontSize: 10,
                              color: LexiColors.accentTeal,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        world.name.toUpperCase(),
                        style: LexiTextStyles.heading(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        world.description,
                        style: LexiTextStyles.body(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!isLocked)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward_rounded,
                              color: world.color, size: 24),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
