import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:search_word/screens/splash_screen.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/providers/profile_provider.dart';
import 'package:search_word/utils/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:search_word/utils/firebase_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is configured natively on Android. On platforms without a
  // generated FirebaseOptions file (for example Web/Desktop), initialization
  // can fail; that must not prevent Flutter from rendering its first frame.
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    debugPrint('[Firebase] Initialization skipped: $e');
  }

  await SoundService.init();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const LexiFlowApp(),
    ),
  );
}

class LexiFlowApp extends ConsumerStatefulWidget {
  const LexiFlowApp({super.key});

  @override
  ConsumerState<LexiFlowApp> createState() => _LexiFlowAppState();
}

class _LexiFlowAppState extends ConsumerState<LexiFlowApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setOnline(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setOnline(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setOnline(true);
    } else {
      _setOnline(false);
    }
  }

  Future<void> _setOnline(bool isOnline) async {
    if (!firebaseReady) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirestoreService.updateOnlineStatus(uid, isOnline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LexiFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
          secondary: Colors.teal,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      home: const SplashScreen(),
    );
  }
}
