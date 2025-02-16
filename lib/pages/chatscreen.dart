import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logger/logger.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  late FlutterTts _flutterTts;

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
    _initTts();
  }

  void _initTts() {
    _flutterTts = FlutterTts();

    _flutterTts.setStartHandler(() => logger.i("TTS Started"));
    _flutterTts.setCompletionHandler(() => logger.i("TTS Completed"));
    _flutterTts.setErrorHandler((msg) => logger.e("TTS Error: $msg"));

    _setTtsLanguage(_selectedLanguage);
  }

  Future<void> _setTtsLanguage(String languageCode) async {
    try {
      if (await _flutterTts.isLanguageAvailable(languageCode)) {
        await _flutterTts.setLanguage(languageCode);
        logger.i("TTS Language set to $languageCode");
      } else {
        logger.w("Language $languageCode not available, falling back to en-US");
        await _flutterTts.setLanguage("en-US");
      }
    } catch (e) {
      logger.e("Error setting TTS language: $e");
    }
  }

  void _initializeGemini() {
    final apiKey = OPEN_API_KEY;
    if (apiKey.isEmpty) {
      logger.e('No API_KEY found in secrets.dart');
      return;
    }

    _generativeModel = GenerativeModel(
      model: 'gemini-pro',
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
        final aiResponse = response.text!;
        _addMessage(aiResponse, false);
        await _speak(aiResponse);
      } else {
        _addMessage('No response received', false);
      }
    } catch (e) {
      logger.e("Error generating AI response: $e");
      _addMessage("Error generating response", false);
    }
  }

  Future<void> _speak(String text) async {
    try {
      // Stop speech before starting new
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      logger.e("Error in TTS: $e");
      _addMessage("Error speaking response", false);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
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
              onChanged: (v) async {
                setState(() => _selectedLanguage = v!);
                await _setTtsLanguage(v!);
              },
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
                  child: GestureDetector(
                    onTap: () =>
                        !message['isUser'] ? _speak(message['text']) : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
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
                          color:
                              message['isUser'] ? Colors.white : Colors.black,
                        ),
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
