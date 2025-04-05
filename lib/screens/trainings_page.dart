import 'package:explorelab/core/LocaleManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Trainings extends StatefulWidget {
  final String id;

  Trainings({required this.id});

  @override
  _Trainings createState() => _Trainings();
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

class _Trainings extends State<Trainings> {
  List<TopicModel> topics = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    _fetchDataFromFirestore(widget.id);
  }

  Future<void> _fetchDataFromFirestore(String documentId) async {
    try {
      // Sabit koleksiyon adı "lessons", belgenin id'si ise "documentId"
      final docSnapshot = await FirebaseFirestore.instance
          .collection('lessons') // Koleksiyon adı sabit
          .doc(documentId) // Belge ID'si
          .get();

      // Belgeyi aldıktan sonra, veriyi TopicModel'e dönüştür
      if (docSnapshot.exists) {
        var docData = docSnapshot.data() as Map<String, dynamic>;

        // 'topics' listesini alıyoruz
        List<TopicModel> tempTopics = [];
        for (var topicData in docData['topics']) {
          tempTopics.add(TopicModel.fromMap(topicData));
        }

        setState(() {
          topics = tempTopics; // 'topics' verisini listeye aktar
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
        // Tıklandığında detay sayfasına yönlendireceğiz
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TopicDetailScreen(topic: topic),
          ),
        );
      },
      child: Container(
        width: 90,
        height: 80,
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(color: Colors.green.shade900, blurRadius: 10),
          ],
        ),
        child: Center(
          child: Text(
            topic.title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTopicsList() {
    return topics.isEmpty
        ? Center(child: CircularProgressIndicator()) // Veri yüklenirken göster
        : ListView.builder(
            padding: EdgeInsets.only(bottom: 30),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              var topic = topics[index];
              return _buildTopicCard(topic);
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        title: Text(
          "Kavram Öğretimi",
          style: TextStyle(
              fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 8),
        child: _buildTopicsList(),
      ),
    );
  }
}

class TopicDetailScreen extends StatelessWidget {
  final TopicModel topic;

  TopicDetailScreen({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(topic.image),
            SizedBox(height: 10),
            Text(
              topic.summary,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Açıklama: ${topic.description}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Malzemeler: ${topic.materials.join(', ')}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Adımlar: ${topic.steps.join(', ')}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (await canLaunch(topic.videoLink)) {
                  launch(topic.videoLink);
                } else {
                  print("Bağlantı açılamadı: ${topic.videoLink}");
                }
              },
              child: Text("Video İzle"),
            ),
          ],
        ),
      ),
    );
  }
}
