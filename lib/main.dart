import 'package:flutter/material.dart';

import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:flutter/services.dart';

void main() {
  runApp(const GrammarCheckerApp());
}

class GrammarCheckerApp extends StatefulWidget {
  const GrammarCheckerApp({super.key});

  @override
  State<GrammarCheckerApp> createState() => _GrammarCheckerAppState();
}

class _GrammarCheckerAppState extends State<GrammarCheckerApp> {
  final TextEditingController _textController = TextEditingController();
  String correctedText = "";
  bool isLoading = false;
  String? errorMessage;

  Future<void> checkGrammar(String text) async {
    const apiKey = 'AIzaSyCyos1qis6TVcEoQkW92AVaNwRecNAGntY';
    
    setState(() {
      isLoading = true;
      errorMessage = null;
      correctedText = "";
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
      );

      final prompt = '''
Act as a professional grammar checker and translator. Please:
1. If the text is not in English, translate it to English
2. Check and fix any grammar mistakes
3. Explain the corrections or translation changes made
4. Format the response clearly with Original, Corrected, and Explanation sections

Text to check: $text
''';
      
      final response = await model.generateContent([Content.text(prompt)]);
      
      setState(() {
        correctedText = response.text ?? "No correction needed.";
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _textController.text = data!.text!;
      });
    }
  }

  Widget _buildOutputCard() {
    if (correctedText.isEmpty) return const SizedBox.shrink();

    final parts = correctedText.split('\n');
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analysis Result',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Divider(height: 24),
            ...parts.map((part) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    part,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.spellcheck, size: 28),
              SizedBox(width: 12),
              Text(
                "AI Grammar Checker",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextField(
                                controller: _textController,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Enter your text here...",
                                  filled: true,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                bottom: 16.0,
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: _pasteFromClipboard,
                                    icon: const Icon(Icons.paste),
                                    tooltip: 'Paste from clipboard',
                                  ),
                                  const Spacer(),
                                  FilledButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            if (_textController.text.isNotEmpty) {
                                              checkGrammar(_textController.text);
                                            }
                                          },
                                    icon: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.check),
                                    label: const Text("Check Grammar"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (errorMessage != null)
                        Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          margin: const EdgeInsets.only(top: 24),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                      _buildOutputCard(),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text(
                'Made with ❤️ by Ruki',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
