import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' as root_bundle;
import 'dart:convert';

Future<void> uploadWords() async {
  final firestore = FirebaseFirestore.instance;

  final String jsonString =
      await root_bundle.rootBundle.loadString('assets/lang/en.json');

  final Map<String, dynamic> data = jsonDecode(jsonString);

  await firestore.collection('languages').doc('en').set(data);

  print('Veri Firestore\'a yüklendi!');
}
