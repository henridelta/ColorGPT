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
    loadColors('base'); // Appeler la fonction pour charger les couleurs depuis le JSON
  }

  void loadColors(String theme) {
    // Charger les données JSON depuis votre fichier ou une source distante
    String jsonContent = '';

    // Choisir le thème en fonction du paramètre
    if (theme == 'Noel') {
      jsonContent =
      '[{"color":"FFFF2222"},{"color":"FF006400"},{"color":"FFFFD700"},{"color":"FFFFEB3B"},{"color":"FFFF69B4"},{"color":"FF87CEEB"}]';
    } else if (theme == 'Halloween') {
      jsonContent =
      '[{"color":"FF000000"},{"color":"FFFF5722"},{"color":"FFC62828"},{"color":"FFFFEB3B"},{"color":"FF2196F3"},{"color":"FF9C27B0"}]';
    } else if (theme == 'base') {
      jsonContent =
      '[{"color":"FFFF0000"},{"color":"FF4CAF50"},{"color":"FFFF9800"},{"color":"FFFFEB3B"},{"color":"FF2196F3"},{"color":"FF9C27B0"}]';
    }

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
            '!!! API KEY !!!',
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      loadColors('Noel'); // Charger le thème "Noël"
                    },
                    child: Builder(builder: (context) {
                      return const Text('Noël');
                    }),
                  ),
                ),
                SizedBox(width: 8.0), // Espace entre les boutons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      loadColors('Halloween'); // Charger le thème "Noël"
                    },
                    child: Builder(builder: (context) {
                      return const Text('Halloween');
                    }),
                  ),
                ),
              ],
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
