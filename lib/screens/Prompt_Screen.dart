import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:soundofmeme/services/api_services.dart'; // Ensure this import is correct

class PromptScreen extends StatefulWidget {
  static const routeName = 'Prompt';
  const PromptScreen({Key? key}) : super(key: key);

  @override
  _PromptScreenState createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  final TextEditingController promptController = TextEditingController();
  final SunoApi sunoApi = SunoApi( );

  List<AudioInfo> audioList = [];
  bool isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> generateAudio() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final result = await sunoApi.generate(promptController.text);
      if (!mounted) return;
      setState(() {
        audioList = result;
      });
    } catch (e) {
      print('Failed to generate audio: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _playAudio(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print('Failed to play audio: $e');
    }
  }

  @override
  void dispose() {
    promptController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create SoundOfMeme 😂'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.deepPurple,
              child: Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : audioList.isNotEmpty
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Audio generated:'),
                    ...audioList.map(
                          (audio) => ListTile(
                        title: Text(audio.title ?? 'No Title'),
                        subtitle: Text(audio.audioUrl ?? 'No URL'),
                        trailing: IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () async {
                            print(audio.id);
                            if (audio.audioUrl != null && audio.audioUrl!.isNotEmpty) {
                              _playAudio(audio.audioUrl!);
                            } else {
                              print('No valid audio URL');
                            }
                          },
                        ),
                      ),
                    ).toList(),
                  ],
                )
                    : Text('Enter a prompt and generate audio!'),
              ),
            ),
          ),
          Container(
            height: 250,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter Your Prompt',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: promptController,
                  cursorColor: Colors.deepPurple,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                    ),
                    onPressed: generateAudio,
                    icon: Icon(Icons.play_arrow),
                    label: Text("Generate"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
