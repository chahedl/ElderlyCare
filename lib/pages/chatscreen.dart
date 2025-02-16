import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logger/logger.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'secrets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late stt.SpeechToText _speech;
  bool _speechInitialized = false;
  var logger = Logger();

  // Store messages with role information
  final List<Map<String, dynamic>> _messages = [];

  final Map<String, String> _languages = {
    'English': 'en_US',
    'French': 'fr_FR',
    'Spanish': 'es_ES',
    'German': 'de_DE',
    'Arabic': 'ar_TN',
  };

  String _selectedLanguage = 'fr_FR';
  late GenerativeModel _generativeModel;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initializeGemini();
  }

  void _initializeGemini() {
    // Get API key from Google AI Studio
    final apiKey = OPEN_API_KEY;
    if (apiKey.isEmpty) {
      logger.e('No API_KEY found in secrets.dart');
      return;
    }

    // Initialize with correct model (gemini-1.5-flash is not publicly available yet)
    _generativeModel = GenerativeModel(
      model: 'gemini-pro', // Use available public model
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
      _messages.insert(
          0, {'text': text, 'isUser': isUser, 'timestamp': DateTime.now()});
    });
  }

  Future<void> _generateResponse(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _generativeModel.generateContent(content);

      if (response.text != null) {
        _addMessage(response.text!, false);
      } else {
        _addMessage('No response received', false);
      }
    } catch (e) {
      logger.e("Error generating AI response: $e");
      _addMessage("Error generating response", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Vocal")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              items: _languages.entries
                  .map((e) => DropdownMenuItem(
                        value: e.value,
                        child: Text(e.key),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedLanguage = v!),
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['isUser']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message['isUser']
                          ? const Color(0xFF199A8E)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: message['isUser'] ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: IconButton(
              icon: Icon(
                _speech.isListening ? Icons.mic : Icons.mic_none,
                size: 50,
                color: _speech.isListening ? Colors.red : Colors.blue,
              ),
              onPressed: _speech.isListening ? _stopListening : _startListening,
            ),
          ),
        ],
      ),
    );
  }
}
