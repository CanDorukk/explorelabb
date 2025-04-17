import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 'topics' koleksiyonunun snapshot'larını dinliyoruz
  Stream<int> getTopicCountStream(String docId) {
    return _firestore
        .collection('lessons')
        .doc(docId)
        .snapshots()
        .map((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return (data['topics'] as List? ?? []).length;
      }
      return 0;
    });
  }
}
