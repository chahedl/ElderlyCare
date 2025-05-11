import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logger/logger.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'secrets.dart';
import 'upload_user_voice_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late stt.SpeechToText _speech;
  bool _speechInitialized = false;
  var logger = Logger();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _selectedVoice;

  final List<Map<String, dynamic>> _messages = [];

  final Map<String, String> _languages = {
    'English': 'en-US',
    'French': 'fr-FR',
    'Spanish': 'es-ES',
    'German': 'de-DE',
    'Arabic': 'ar-TN',
  };

  String _selectedLanguage = 'fr-FR';
  late GenerativeModel _generativeModel;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initializeGemini();
    _loadSelectedVoice();
  }

  Future<void> _loadSelectedVoice() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedVoice = prefs.getString('selected_voice');
    });
  }

  void _initializeGemini() {
    final apiKey = OPEN_API_KEY;
    if (apiKey.isEmpty) {
      logger.e('No API_KEY found in secrets.dart');
      return;
    }

    _generativeModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    bool initialized = await _speech.initialize(
      onStatus: (status) => logger.i("Status: $status"),
      onError: (error) => logger.e("Initialization Error: $error"),
    );
    setState(() => _speechInitialized = initialized);
  }

  void _startListening() {
    if (!_speechInitialized) {
      _addMessage("Speech recognition not available.", true);
      return;
    }

    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          String userText = result.recognizedWords;
          _addMessage(userText, true);
          _generateResponse(userText);
        }
      },
      listenFor: const Duration(seconds: 180),
      localeId: _selectedLanguage,
    );
  }

  void _stopListening() => _speech.stop();

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.insert(0, {
        'text': text,
        'isUser': isUser,
        'timestamp': DateTime.now(),
        'audioPath': null,
      });
    });
  }

  Future<void> _generateResponse(String prompt) async {
    final prefs = await SharedPreferences.getInstance();
    final voiceId = prefs.getString('selected_voice');

    if (voiceId == null) {
      _addMessage("Please create a voice first", false);
      return;
    }

    try {
      final content = [Content.text(prompt)];
      final response = await _generativeModel.generateContent(content);
      final aiResponse = response.text ?? "No response generated";

      _addMessage(aiResponse, false);

      // ElevenLabs TTS Request
      final ttsResponse = await http.post(
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId'),
        headers: {
          'xi-api-key': ELEVEN_LABS_API_KEY,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: jsonEncode({
          'text': aiResponse,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75}
        }),
      );

      logger.i('ElevenLabs Status Code: ${ttsResponse.statusCode}');
      logger.i('ElevenLabs Headers: ${ttsResponse.headers}');

      if (ttsResponse.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName =
            'response_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final file = File('${tempDir.path}/$fileName');

        try {
          await file.writeAsBytes(ttsResponse.bodyBytes);
          logger.i('Audio file saved to: ${file.path}');

          if (await file.exists()) {
            logger.i('File exists, attempting playback...');
            setState(() {
              final messageIndex = _messages.indexWhere(
                  (m) => m['text'] == aiResponse && m['audioPath'] == null);
              if (messageIndex != -1) {
                _messages[messageIndex]['audioPath'] = file.path;
              }
            });
            await _audioPlayer.play(DeviceFileSource(file.path));
            logger.i('Playback started successfully');
          } else {
            logger.e('File not found after writing!');
            _addMessage("Audio file creation failed", false);
          }
        } catch (e) {
          logger.e('File write error: $e');
          _addMessage("Audio file creation error", false);
        }
      } else {
        final errorBody = utf8.decode(ttsResponse.bodyBytes);
        logger.e('ElevenLabs Error: $errorBody');
        _addMessage(
            "Audio generation failed: ${ttsResponse.statusCode}", false);
      }
    } catch (e) {
      logger.e("General Error: $e");
      _addMessage("Error generating response", false);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199A8E);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Chat with Loved One',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UploadUserVoiceScreen()),
            ),
            tooltip: 'Create Voice',
          ),
        ],
      ),
      body: Column(
        children: [
          // Language and Voice Selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLanguage,
                        decoration: InputDecoration(
                          labelText: 'Language',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                        items: _languages.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.value,
                                  child: Text(e.key),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedLanguage = v!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _selectedVoice != null
                            ? 'Voice: $_selectedVoice'
                            : 'No voice selected',
                        style: TextStyle(
                          color: _selectedVoice != null
                              ? primaryColor
                              : Colors.red[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Chat Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Chat Messages
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message['isUser'];
                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () async {
                        if (!isUser && message['audioPath'] != null) {
                          final file = File(message['audioPath']);
                          if (await file.exists()) {
                            await _audioPlayer
                                .play(DeviceFileSource(file.path));
                          }
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      message['text'],
                                      style: TextStyle(
                                        color: isUser
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (!isUser &&
                                      message['audioPath'] != null) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.play_circle_outline,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(message['timestamp']),
                                style: TextStyle(
                                  color: isUser
                                      ? Colors.white70
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Microphone Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _speech.isListening ? _stopListening : _startListening,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _speech.isListening ? Icons.mic : Icons.mic_none,
                      key: ValueKey(_speech.isListening),
                      size: 40,
                      color:
                          _speech.isListening ? Colors.red[700] : primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
