import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State createState() => ChatScreenState();
}

class ColorData {
  final String color;

  ColorData({required this.color});

  factory ColorData.fromJson(Map<String, dynamic> json) {
    return ColorData(color: json['color']);
  }
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];
  List<Color> cellColors = [];




  @override
  void initState() {
    super.initState();
    loadColors(); // Appeler la fonction pour charger les couleurs depuis le JSON
  }

  void loadColors() {
    // Charger les données JSON depuis votre fichier ou une source distante
    String jsonContent =
        '[{"color":"FF0000FF"},{"color":"4CAF50FF"},{"color":"0000FF"},{"color":"FFFF00"},{"color":"FFA500"},{"color":"800080"}]';
    List<ColorData> colorDataList = (json.decode(jsonContent) as List<dynamic>)
        .map((data) => ColorData.fromJson(data))
        .toList();

    // Convertir les couleurs hexadécimales en objets Color
    cellColors = colorDataList
        .map((colorData) => Color(int.parse("0x${colorData.color}")))
        .toList();
    // Mettre à jour l'état pour déclencher le redessinement du widget
    setState(() {});
  }

  void _sendMessage(String message) async {
    // Replace 'YOUR_CHATGPT_API_ENDPOINT' with the actual ChatGPT API endpoint
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer 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',
      },
      body:
          '{"model":"gpt-3.5-turbo","messages": [{"role": "user", "content": "$message"}]}',
    );

    if (response.statusCode == 200) {
      setState(() {
        _messages.add(message);
        _messages.add(response.body);
        // _messages.add(response.body[4][1][1]);
      });
      _textController.clear();
    } else {
      print('Failed to send message. Error code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Color> cellColors = [
      Color(0xFFFF0000),
      Colors.green,
      Colors.yellow,
      Colors.blue,
      Colors.orange,
      Colors.purple,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ColorGPT'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: 2 * 3, // 2 rows * 3 columns
              itemBuilder: (context, index) {
                // Personnalisez le contenu de chaque cellule ici
                return GridTile(
                  child: Container(
                    color: cellColors[index % cellColors.length],
                    // Cette formule permet de faire une boucle sur les couleurs
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Demander un thème',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      _sendMessage(_textController.text);
                    }
                  },
                  child: Builder(builder: (context) {
                    return const Text('Send');
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
