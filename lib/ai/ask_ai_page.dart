import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String role;
  String content;

  ChatMessage({required this.role, required this.content});
}

class AskAIPage extends StatefulWidget {
  const AskAIPage({super.key});

  @override
  State<AskAIPage> createState() => _AskAIPageState();
}

class _AskAIPageState extends State<AskAIPage> {
  static const String _apiKey = String.fromEnvironment('OPENROUTER_API_KEY');

  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  http.Client? _client;
  StreamSubscription<String>? _streamSub;

  @override
  void dispose() {
    _streamSub?.cancel();
    _client?.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    if (_apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OPENROUTER_API_KEY set ")),
      );
      return;
    }

    setState(() {
      _isSending = true;
      _messages.add(ChatMessage(role: "user", content: text));
      _messages.add(ChatMessage(role: "assistant", content: "")); // placeholder for streaming
    });
    _controller.clear();
    _scrollToBottom();

    final assistantIndex = _messages.length - 1;

    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    _client ??= http.Client();

    final req = http.Request('POST', url);
    req.headers.addAll({
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    });

    final openAiStyleMessages = _messages
        .where((m) => m.role == "user" || m.role == "assistant")
        .map((m) => {"role": m.role, "content": m.content})
        .toList();

    req.body = jsonEncode({
      "model": "openrouter/aurora-alpha",
      "messages": openAiStyleMessages,
      "stream": true,
    });

    try {
      final res = await _client!.send(req);

      if (res.statusCode != 200) {
        final err = await res.stream.bytesToString();
        if (!mounted) return;
        setState(() {
          _messages[assistantIndex].content = "Error ${res.statusCode}: $err";
          _isSending = false;
        });
        _scrollToBottom();
        return;
      }

      await _streamSub?.cancel();
      final lines = res.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      _streamSub = lines.listen((line) {
        if (!mounted) return;

        if (!line.startsWith('data: ')) return;
        final data = line.substring(6).trim();
        if (data == '[DONE]') return;

        try {
          final json = jsonDecode(data);
          final delta = json['choices']?[0]?['delta']?['content'];
          if (delta != null) {
            // Sanitize content to remove unwanted characters or LaTeX formatting
            String sanitizedContent = _sanitizeContent(delta);
            setState(() {
              _messages[assistantIndex].content += sanitizedContent;
            });
            _scrollToBottom();
          }
        } catch (_) {
          // ignore partial / non-json lines
        }
      }, onDone: () {
        if (!mounted) return;
        setState(() => _isSending = false);
        _scrollToBottom();
      }, onError: (e) {
        if (!mounted) return;
        setState(() {
          _messages[assistantIndex].content += "\n\n[Stream error: $e]";
          _isSending = false;
        });
        _scrollToBottom();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages[assistantIndex].content = "Error: $e";
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  String _sanitizeContent(String content) {
    // Removing unwanted LaTeX-like syntax and cleaning up the content
    content = content.replaceAll(r'(\dfrac', '');  // Example of cleaning LaTeX formatting
    content = content.replaceAll(r'\', '');        // Remove unwanted backslashes
    content = content.replaceAll(r'+', 'plus');    // Replace '+' with 'plus'
    return content;
  }

  Widget _bubble(ChatMessage m) {
    final isUser = m.role == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1E88E5) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          m.content.isEmpty && !isUser ? "..." : m.content,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ask AI"),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _bubble(_messages[i]),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: "Type your message…",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _isSending ? null : _send,
                    icon: _isSending
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.send),
                    color: const Color(0xFF1E88E5),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
