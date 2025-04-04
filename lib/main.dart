import 'package:explorelab/core/LocaleManager.dart';
import 'package:explorelab/core/ThemeManager.dart';
import 'package:explorelab/dataUpload/json_upload.dart';
import 'package:explorelab/models/authentication_model.dart';
import 'package:explorelab/onboarding/onboard.dart';
import 'package:explorelab/onboarding/splash_screen.dart';
import 'package:explorelab/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());

  //await uploadWords();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => LocalManager()),
        ChangeNotifierProvider(
            create: (_) =>
                AuthenticationModel()), // AuthenticationModel'ı burada sağlıyoruz
      ],
      child: Consumer2<ThemeManager, LocalManager>(
        builder: (context, themeManager, localManager, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Explore Lab',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeManager.themeMode,
            locale: localManager.currentLocale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('tr'),
            ],
            home: SplashScreen(), // Uygulama başlangıcında SplashScreen göster
          );
        },
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthenticationModel>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return HomePage(); // Kullanıcı giriş yaptı
        } else {
          return OnboardingScreen(); // Kullanıcı giriş yapmadı
        }
      },
    );
  }
}
