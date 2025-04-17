import 'package:explorelab/screens/trainings_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class LessonsPage extends StatefulWidget {
  final TopicModel topic;

  const LessonsPage({required this.topic, Key? key}) : super(key: key);

  @override
  _LessonsPage createState() => _LessonsPage();
}

class _LessonsPage extends State<LessonsPage> {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.topic.videoLink) ?? "";
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: true,
        hideControls: false,
        enableCaption: false,
      ),
    );

    _controller.addListener(_fullScreenListener);
  }

  void _fullScreenListener() {
    if (_controller.value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = _controller.value.isFullScreen;
      });
      _toggleFullScreen(_controller.value.isFullScreen);
    }
  }

  void _toggleFullScreen(bool isFullScreen) {
    if (isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_fullScreenListener);
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        onReady: () {
          debugPrint("Player is ready.");
        },
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: _isFullScreen
              ? null
              : AppBar(
                  title: Text(widget.topic.title),
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    height: 2,
                  ),
                  backgroundColor: Colors.transparent,
                ),
          body: _isFullScreen
              ? Container(
                  color: Colors.black,
                  child: Center(
                    child: player,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Center(
                        child: Image.network(
                          widget.topic.image,
                          width: MediaQuery.of(context).size.width * 0.8,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.topic.summary,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: Colors.amber[800]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                                children: [
                                  const TextSpan(
                                    text: "Ne öğreneceğiz? ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: widget.topic.description,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.science, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          const Text(
                            "Gerekli Malzemeler",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(widget.topic.materials.length,
                            (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 16),
                                Icon(Icons.circle,
                                    size: 8, color: Colors.redAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(widget.topic.materials[index])),
                              ],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.auto_fix_high, color: Colors.teal),
                          const SizedBox(width: 8),
                          const Text(
                            "Nasıl yapılır?",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            List.generate(widget.topic.steps.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 16),
                                Text("${index + 1}. ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Expanded(
                                    child: Text(widget.topic.steps[index])),
                              ],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        height: MediaQuery.of(context).size.width * 9 / 16,
                        width: MediaQuery.of(context).size.width,
                        child: player,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
