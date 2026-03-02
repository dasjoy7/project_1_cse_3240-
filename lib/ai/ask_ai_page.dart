import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ── Theme constants ────────────────────────────────────────────────────────
const _kPrimary     = Color(0xFF4A90D9);
const _kPrimaryDeep = Color(0xFF3574C4);
const _kSurface     = Color(0xFFF7F9FC);
const _kCardWhite   = Color(0xFFFFFFFF);
const _kTextDark    = Color(0xFF1E2A3B);
const _kTextMid     = Color(0xFF5A6A7E);
const _kTextLight   = Color(0xFF8FA0B4);
const _kBorder      = Color(0xFFEAEFF6);
// ───────────────────────────────────────────────────────────────────────────

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
  // ── API key set directly ─────────────────────────────────────────────────
  static const String _apiKey =
      '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';

  final _controller      = TextEditingController();
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

    setState(() {
      _isSending = true;
      _messages.add(ChatMessage(role: 'user', content: text));
      _messages.add(ChatMessage(role: 'assistant', content: ''));
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
      'HTTP-Referer': 'https://matharena.app',
      'X-Title': 'Math Arena',
    });

    final history = _messages
        .where((m) => m.role == 'user' || m.role == 'assistant')
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    req.body = jsonEncode({
      'model': 'google/gemini-2.0-flash-001',
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a helpful math tutor for students. Explain clearly and step by step. '
              'Do not use LaTeX formatting. Use plain text with simple symbols like +, -, *, / and ^. '
              'Keep responses concise and easy to read.',
        },
        ...history,
      ],
      'stream': true,
    });

    try {
      final res = await _client!.send(req);

      if (res.statusCode != 200) {
        final err = await res.stream.bytesToString();
        if (!mounted) return;
        setState(() {
          _messages[assistantIndex].content =
              'Error ${res.statusCode}: $err';
          _isSending = false;
        });
        _scrollToBottom();
        return;
      }

      await _streamSub?.cancel();
      final lines = res.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      _streamSub = lines.listen(
        (line) {
          if (!mounted) return;
          if (!line.startsWith('data: ')) return;
          final data = line.substring(6).trim();
          if (data == '[DONE]') return;

          try {
            final json = jsonDecode(data);
            final delta = json['choices']?[0]?['delta']?['content'];
            if (delta != null) {
              setState(() {
                _messages[assistantIndex].content += delta as String;
              });
              _scrollToBottom();
            }
          } catch (_) {
          }
        },
        onDone: () {
          if (!mounted) return;
          setState(() => _isSending = false);
          _scrollToBottom();
        },
        onError: (e) {
          if (!mounted) return;
          setState(() {
            _messages[assistantIndex].content += '\n\n[Stream error: $e]';
            _isSending = false;
          });
          _scrollToBottom();
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages[assistantIndex].content = 'Error: $e';
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Chat',
            style: TextStyle(fontWeight: FontWeight.w700, color: _kTextDark)),
        content: const Text('Are you sure you want to clear all messages?',
            style: TextStyle(color: _kTextMid)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: _kTextLight)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _messages.clear());
              Navigator.pop(context);
            },
            child: const Text('Clear',
                style: TextStyle(
                    color: Color(0xFFE05555), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _bubble(ChatMessage m) {
    final isUser = m.role == 'user';
    final isEmpty = m.content.isEmpty && !isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isUser ? 48 : 12,
          right: isUser ? 12 : 48,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isUser ? _kPrimary : _kCardWhite,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? _kPrimary.withOpacity(0.18)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isEmpty
            ? _TypingIndicator()
            : Text(
                m.content,
                style: TextStyle(
                  color: isUser ? Colors.white : _kTextDark,
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kPrimaryDeep, _kPrimary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'Math AI Tutor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _kTextDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask me anything about math!\nI\'ll explain it step by step.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _kTextLight, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 28),
          // Suggestion chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              'Solve a quadratic',
              'Explain derivatives',
              'What is integration?',
              'Probability basics',
            ].map((s) => _SuggestionChip(
                  label: s,
                  onTap: () {
                    _controller.text = s;
                    _send();
                  },
                )).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kCardWhite,
        foregroundColor: _kTextDark,
        elevation: 0,
        leading: const BackButton(color: _kTextDark),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kPrimaryDeep, _kPrimary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Tutor',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: _kTextDark,
                  ),
                ),
                Text(
                  'Powered by Gemini',
                  style: TextStyle(fontSize: 10, color: _kTextLight),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_messages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                onPressed: _clearChat,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: _kTextLight),
                tooltip: 'Clear chat',
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: Column(
        children: [
        
          Expanded(
            child: _messages.isEmpty
                ? _emptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _bubble(_messages[i]),
                  ),
          ),

          Container(
            color: _kCardWhite,
            child: Column(
              children: [
                Container(height: 1, color: _kBorder),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: _kSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _kBorder),
                            ),
                            child: TextField(
                              controller: _controller,
                              textInputAction: TextInputAction.newline,
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              minLines: 1,
                              onSubmitted: (_) => _send(),
                              style: const TextStyle(
                                  color: _kTextDark, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Ask a math question...',
                                hintStyle: TextStyle(
                                    color: _kTextLight, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 11),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _isSending ? null : _send,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: _isSending
                                  ? null
                                  : const LinearGradient(
                                      colors: [_kPrimaryDeep, _kPrimary],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              color: _isSending
                                  ? _kBorder
                                  : null,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _isSending
                                  ? []
                                  : [
                                      BoxShadow(
                                        color:
                                            _kPrimary.withOpacity(0.30),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: _isSending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: _kTextLight,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
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


class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..repeat(reverse: true),
    );
    _anims = _controllers.asMap().entries.map((e) {
      Future.delayed(Duration(milliseconds: e.key * 150),
          () { if (mounted) e.value.forward(); });
      return Tween<double>(begin: 0, end: -5).animate(
        CurvedAnimation(parent: e.value, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _anims[i].value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: _kTextLight,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}


class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _kCardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: _kPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}