import 'package:explorelab/screens/trainings_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonsScreen extends StatelessWidget {
  final TopicModel topic;
  LessonsScreen({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (topic.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(topic.image),
              ),
            SizedBox(height: 20),
            Text(topic.summary,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text("📌 Açıklama",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(topic.description),
            SizedBox(height: 12),
            if (topic.materials.isNotEmpty) ...[
              Text("🧪 Malzemeler",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...topic.materials.map((e) => Text("- $e")).toList(),
              SizedBox(height: 12),
            ],
            if (topic.steps.isNotEmpty) ...[
              Text("🧭 Adımlar",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...topic.steps
                  .asMap()
                  .entries
                  .map((e) => Text("${e.key + 1}. ${e.value}"))
                  .toList(),
              SizedBox(height: 12),
            ],
            if (topic.videoLink.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(topic.videoLink);
                  if (await canLaunchUrl(uri)) {
                    launchUrl(uri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Video bağlantısı açılamadı."),
                    ));
                  }
                },
                icon: Icon(Icons.play_arrow),
                label: Text("Videoyu İzle"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
