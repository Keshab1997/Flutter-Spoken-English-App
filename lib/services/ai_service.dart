import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  String? _apiKey;
  String _provider = 'gemini'; // 'gemini' or 'openai'

  void setApiKey(String key) {
    _apiKey = key;
  }

  void setProvider(String provider) {
    _provider = provider;
  }

  Future<String> sendMessage(String message) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return _getLocalResponse(message);
    }

    try {
      if (_provider == 'gemini') {
        return await _callGemini(message);
      } else {
        return await _callOpenAI(message);
      }
    } catch (_) {
      return _getLocalResponse(message);
    }
  }

  Future<String> _callGemini(String message) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{'parts': [{'text': 'You are an English teacher. Correct the user\'s English, suggest improvements, and respond helpfully. User: $message'}]}]
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'I couldn\'t process that.';
    }
    return _getLocalResponse(message);
  }

  Future<String> _callOpenAI(String message) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are an English teacher. Correct grammar mistakes, suggest vocabulary improvements, and help the user practice English.'},
          {'role': 'user', 'content': message},
        ],
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices']?[0]?['message']?['content'] ?? _getLocalResponse(message);
    }
    return _getLocalResponse(message);
  }

  String _getLocalResponse(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('hello') || lower.contains('hi')) {
      return "Hello! Great to hear from you. Let's start practicing English. Would you like to check grammar or talk about a topic?";
    } else if (lower.contains('grammar') || lower.contains('mistake')) {
      return "Write any sentence, and I will highlight grammar mistakes or suggest more natural alternatives!";
    } else if (lower.contains('vocabulary') || lower.contains('word')) {
      return "Learning new words daily is key! Try using new words in sentences. What word would you like to learn about?";
    } else if (lower.contains('fluency') || lower.contains('speak')) {
      return "To build fluency, try speaking out loud for 5 minutes every day. Use simple, correct sentences. Would you like to practice now?";
    } else if (lower.contains('how are you')) {
      return "I am doing great! How is your English learning journey going? Have you practiced today?";
    }
    return "That's interesting! Keep practicing. Try to use complete sentences. How can I help you improve your English today?";
  }
}
