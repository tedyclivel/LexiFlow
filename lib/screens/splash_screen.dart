import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:search_word/providers/profile_provider.dart';
import 'package:search_word/screens/auth_screen.dart';
import 'package:search_word/screens/main_menu_screen.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/widgets/lexiflow_logo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_word/utils/firebase_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _status = "Initialisation...";
  double _progress = 0.0;
  bool _hasError = false;
  bool _navigationStarted = false;

  @override
  void initState() {
    super.initState();
    _startInitProcess();
  }

  Future<void> _startInitProcess() async {
    try {
      // Firebase is optional for displaying the app. This is important on
      // platforms where no FirebaseOptions are bundled yet.
      if (!firebaseReady) {
        _navigateTo(const AuthScreen());
        return;
      }

      // 1. Check Connectivity
      setState(() {
        _status = "Vérification de la connexion...";
        _progress = 0.2;
      });
      final connectivityResult = await Connectivity().checkConnectivity();
      bool hasInternet = connectivityResult.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet,
      );

      if (!hasInternet) {
        throw Exception("Pas de connexion internet");
      }

      await Future.delayed(const Duration(seconds: 1)); // Aesthetic pause

      // 2. Check Auth State
      setState(() {
        _status = "Authentification...";
        _progress = 0.5;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        setState(() {
          _status = "Chargement du profil...";
          _progress = 0.8;
        });
        await ref.read(profileProvider.notifier).syncWithFirestore();

        setState(() => _progress = 1.0);
        await Future.delayed(const Duration(milliseconds: 500));

        _navigateTo(const MainMenuScreen());
      } else {
        setState(() => _progress = 1.0);
        await Future.delayed(const Duration(milliseconds: 500));

        _navigateTo(const AuthScreen());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "Erreur : ${e.toString()}";
          _hasError = true;
        });
      }
    }
  }

  void _navigateTo(Widget screen) {
    if (!mounted || _navigationStarted) return;
    _navigationStarted = true;

    // initState and async callbacks can run while Navigator is completing its
    // first route transition. Queue the replacement until that frame ends.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LexiColors.backgroundGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LexiFlowLogo(size: R.sp(context, 150))
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(delay: 200.ms, curve: Curves.easeOutBack),

            SizedBox(height: R.sp(context, 60)),

            if (!_hasError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation(
                          LexiColors.accentTeal,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: LexiTextStyles.label(color: Colors.white70),
                    ).animate(key: ValueKey(_status)).fadeIn(),
                  ],
                ),
              )
            else
              Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Oups ! Quelque chose a mal tourné.",
                    style: LexiTextStyles.button(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _status = "Réessai...";
                        _progress = 0.0;
                      });
                      _startInitProcess();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LexiColors.accentTeal,
                      foregroundColor: LexiColors.primaryBlue,
                    ),
                    child: const Text("RÉESSAYER"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
