import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  late final String apiKey;
  late final String emotinal;

  ApiService(String gptapikey) {
    apiKey = gptapikey;
  }

  Future<String> generateEmoji(String prompt) async {
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 50,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      print("Error generating emoji: ${response.body}");
      throw Exception('Failed to generate emoji');
    }
  }
}
