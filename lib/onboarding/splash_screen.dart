import 'package:explorelab/core/LocaleManager.dart';
import 'package:explorelab/core/ThemeManager.dart';
import 'package:explorelab/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> _opacityAnimation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initializeApp();

    // Animasyon kontrolcüsünü oluştur
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Opaklık animasyonunu tanımla
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // Animasyonu başlat
    _controller.forward();
  }

  Future<void> _initializeApp() async {
    // Firebase'i başlat
    await Firebase.initializeApp();

    // Firestore ayarlarını yap (isteğe bağlı)
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // 3 saniye bekle (splash screen'in gösterilme süresi)
    await Future.delayed(const Duration(seconds: 3));

    // AuthCheck'e yönlendir
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthCheck()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context);
    final themeManager = Provider.of<ThemeManager>(context);
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    // Get the text color based on the current theme
    Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(15.0), // Yuvarlaklık derecesi
                    child: Image.asset(
                      'assets/icons/ic_launcher.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ExploreLab',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Text(
                '© Semahattin Can Doruk 2025',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.7),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
