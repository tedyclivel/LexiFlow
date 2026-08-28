import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search_word/providers/profile_provider.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/screens/main_menu_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:search_word/utils/firebase_state.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _pseudoController = TextEditingController();

  String _selectedAvatar =
      'https://api.dicebear.com/7.x/avataaars/png?seed=Lexi';
  final List<String> _avatarSeeds = [
    'Lexi',
    'Flow',
    'Zoe',
    'Max',
    'Luna',
    'Neo',
    'Spark',
    'Blitz',
  ];

  bool _isLoading = false;
  int _step = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 1 && _pseudoController.text.trim().isEmpty) {
      _showError("Choisis un pseudo !");
      return;
    }
    setState(() => _step = _step < 2 ? _step + 1 : 2);
  }

  Future<void> _playAsGuest() async {
    if (!firebaseReady) {
      final pseudo = _pseudoController.text.trim();
      if (pseudo.isEmpty) {
        _showError("Entre un pseudo pour commencer !");
        return;
      }
      ref
          .read(profileProvider.notifier)
          .createLocalProfile(pseudo, _selectedAvatar);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      }
      return;
    }
    final pseudo = _pseudoController.text.trim();
    if (pseudo.isEmpty) {
      _showError("Entre un pseudo pour commencer !");
      return;
    }
    setState(() => _isLoading = true);
    SoundService.playClick();
    try {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      if (cred.user == null) throw Exception("Erreur d'authentification");
      await ref
          .read(profileProvider.notifier)
          .createProfile(pseudo, _selectedAvatar);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError("Erreur: ${e.message}");
    } catch (e) {
      _showError("Erreur: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LexiColors.backgroundGradient,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: R.sp(context, 28),
                vertical: R.sp(context, 20),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Logo / Title
                  Column(
                    children: [
                      Text(
                        "LEXIFLOW",
                        style: GoogleFonts.bungee(
                          fontSize: R.fs(context, 38),
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ).animate().fadeIn(duration: 600.ms).scale(),
                      const SizedBox(height: 4),
                      Text(
                        "Défie tes limites de vocabulaire",
                        textAlign: TextAlign.center,
                        style: LexiTextStyles.label(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // ── Avatar Picker ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "1. CHOISIS TON PERSONNAGE",
                          style: GoogleFonts.bungee(
                            color: Colors.white,
                            fontSize: R.fs(context, 13),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        CircleAvatar(
                              radius: R.sp(context, 38),
                              backgroundColor: LexiColors.accentTeal
                                  .withOpacity(0.2),
                              backgroundImage: NetworkImage(_selectedAvatar),
                            )
                            .animate(key: ValueKey(_selectedAvatar))
                            .scale(duration: 350.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: R.sp(context, 48),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _avatarSeeds.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final seed = _avatarSeeds[i];
                              final url =
                                  'https://api.dicebear.com/7.x/avataaars/png?seed=$seed';
                              final selected = _selectedAvatar == url;
                              return GestureDetector(
                                onTap: () {
                                  SoundService.playLetterSelect();
                                  setState(() => _selectedAvatar = url);
                                },
                                child: Container(
                                  width: R.sp(context, 48),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? LexiColors.accentTeal
                                          : Colors.transparent,
                                      width: 2.5,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(url),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: 24),

                  if (_step >= 1) ...[
                    _field(
                      context,
                      _pseudoController,
                      "Pseudo",
                      Icons.person_rounded,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (_step < 2)
                    SizedBox(
                      width: double.infinity,
                      height: R.sp(context, 54),
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _nextStep,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text(
                          _step == 0 ? "CONTINUER" : "VALIDER LE PSEUDO",
                          style: GoogleFonts.bungee(
                            fontSize: R.fs(context, 14),
                            letterSpacing: 1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LexiColors.accentTeal,
                          foregroundColor: LexiColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 6,
                        ),
                      ),
                    ).animate().slideY(begin: 0.5, duration: 500.ms),
                  if (_step == 2)
                    SizedBox(
                      width: double.infinity,
                      height: R.sp(context, 54),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: LexiColors.accentTeal,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: _playAsGuest,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(
                                "JOUER MAINTENANT",
                                style: GoogleFonts.bungee(
                                  fontSize: R.fs(context, 15),
                                  letterSpacing: 1,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LexiColors.accentTeal,
                                foregroundColor: LexiColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 6,
                              ),
                            ),
                    ).animate().slideY(begin: 0.5, duration: 500.ms),

                  const SizedBox(height: 40),
                  Text(
                    "v1.2.0 · LexiFlow Studio",
                    style: GoogleFonts.outfit(
                      color: Colors.white12,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context,
    TextEditingController ctrl,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: Colors.white, fontSize: R.fs(context, 15)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          icon,
          color: LexiColors.accentTeal,
          size: R.sp(context, 20),
        ),
      ),
    );
  }
}
