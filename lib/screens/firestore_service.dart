import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTopicCount(String docId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('lessons').doc(docId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> topics = data['topics'] ?? [];
        return topics.length;
      }
      return 0;
    } catch (e) {
      print("Hata: $e");
      return 0;
    }
  }
}
