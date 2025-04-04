import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocalManager extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  Map<String, String> _localizedStrings = {};

  Locale get currentLocale => _currentLocale;

  String translate(String key) {
    return _localizedStrings[key] ?? key; // Eğer kelime yoksa key'i döndür
  }

  LocalManager() {
    _loadLocale();
  }

  Future<void> changeLocale(Locale locale) async {
    _currentLocale = locale;
    await _saveLocale(locale.languageCode);
    await _loadLanguageFromFirestore(); // Firestore’dan yeni dili yükle
    notifyListeners();
  }

  Future<void> _loadLanguageFromFirestore() async {
    try {
      print(
          "Firestore'dan dil verisi çekiliyor: ${_currentLocale.languageCode}");

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('languages')
          .doc(_currentLocale.languageCode) // 'en' veya 'tr'
          .get();

      if (snapshot.exists) {
        _localizedStrings = Map<String, String>.from(snapshot.data() as Map);
        print(
            "Firestore'dan çekilen veriler: $_localizedStrings"); // Debug için
      } else {
        _localizedStrings = {};
        print("Firestore'da ${_currentLocale.languageCode} bulunamadı.");
      }

      notifyListeners();
    } catch (e) {
      print('Dil verileri yüklenirken hata oluştu: $e');
    }
  }

  Future<void> _saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('languageCode') ?? 'en';
    _currentLocale = Locale(savedLanguageCode);
    await _loadLanguageFromFirestore();
    notifyListeners();
  }
}
