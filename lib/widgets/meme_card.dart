import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MemeCard extends StatefulWidget {
  final String imageAsset;
  final String audioUrl; // Changed to audioUrl
  final String title;
  final AnimationController animationController;
  final Animation<double> translateAnimation;
  final Animation<double> rotationAnimation;

  const MemeCard({
    Key? key,
    required this.imageAsset,
    required this.audioUrl, // Changed to audioUrl
    required this.title,
    required this.animationController,
    required this.translateAnimation,
    required this.rotationAnimation,
  }) : super(key: key);

  @override
  _MemeCardState createState() => _MemeCardState();
}

class _MemeCardState extends State<MemeCard> {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose the audio player
    super.dispose();
  }

  void _playAudio() async {
    try {
      await _audioPlayer.setSourceUrl(widget.audioUrl); // Play audio from URL
      await _audioPlayer.resume(); // Start playing
    } catch (e) {
      print("Error playing audio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to play audio. Please try again later.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..translate(0.0, widget.translateAnimation.value)
            ..rotateY(widget.rotationAnimation.value),
          alignment: Alignment.center,
          child: Card(
            margin: EdgeInsets.all(8),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  height: 350,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(widget.imageAsset),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _playAudio, // Play audio on button press
                        child: Text("Play Audio"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
