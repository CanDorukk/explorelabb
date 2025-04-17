import 'package:explorelab/screens/lessons_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Trainings extends StatefulWidget {
  final String id;

  const Trainings({required this.id, Key? key}) : super(key: key);

  @override
  _TrainingsState createState() => _TrainingsState();
}

class TopicModel {
  final String id;
  final String title;
  final String summary;
  final String image;
  final String description;
  final List<String> materials;
  final List<String> steps;
  final String videoLink;

  TopicModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.image,
    required this.description,
    required this.materials,
    required this.steps,
    required this.videoLink,
  });

  factory TopicModel.fromMap(Map<String, dynamic> data) {
    var materialsList = List<String>.from(data['details']['materials'] ?? []);
    var stepsList = List<String>.from(data['details']['steps'] ?? []);

    return TopicModel(
      id: data['id'] ?? "",
      title: data['title'] ?? "Bilinmeyen Deney",
      summary: data['summary'] ?? "",
      image: data['image'] ?? "",
      description: data['details']['description'] ?? "",
      materials: materialsList,
      steps: stepsList,
      videoLink: data['details']['videoLink'] ?? "",
    );
  }
}

class _TrainingsState extends State<Trainings> {
  List<TopicModel> topics = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    _fetchDataFromFirestore(widget.id);
  }

  Future<void> _fetchDataFromFirestore(String documentId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('lessons')
          .doc(documentId)
          .get();

      if (docSnapshot.exists) {
        var docData = docSnapshot.data() as Map<String, dynamic>;

        List<TopicModel> tempTopics = [];
        for (var topicData in docData['topics']) {
          tempTopics.add(TopicModel.fromMap(topicData));
        }

        setState(() {
          topics = tempTopics;
        });
      } else {
        print("Belge bulunamadı");
      }
    } catch (e) {
      print("Firestore Hatası: $e");
    }
  }

  Widget _buildTopicCard(TopicModel topic) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonsPage(topic: topic),
          ),
        );
      },
      child: Container(
        width: 90,
        height: 80,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(color: Colors.green.shade900, blurRadius: 10),
          ],
        ),
        child: Center(
          child: Text(
            topic.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTopicsList() {
    return topics.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            padding: const EdgeInsets.only(bottom: 30),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              var topic = topics[index];
              return _buildTopicCard(topic);
            },
            separatorBuilder: (context, index) =>
                const SizedBox(height: 8), // Kartlar arası boşluk
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green,
        title: const Text(
          "Kavram Öğretimi",
          style: TextStyle(
              fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        child: _buildTopicsList(),
      ),
    );
  }
}
