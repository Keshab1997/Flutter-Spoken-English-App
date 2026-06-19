import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/ai_service.dart';
import '../../../services/hive_service.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _userName = HiveService.getUserName();
    _addGreeting();
  }

  void _addGreeting() {
    final displayName = _userName.isNotEmpty ? _userName : 'there';
    _messages.add({
      'text': 'Hello $displayName! 👋\n\nI am Keshab, your AI English Teacher. '
          'You can ask me anything about English — grammar, vocabulary, '
          'pronunciation, or just chat with me in English or Bangla. '
          'I am here to help you improve!\n\n'
          'How are you doing today?',
      'isMe': false,
      'time': '12:00 PM',
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = ref.read(authProvider);
    final name = authState.valueOrNull?.name ?? '';
    if (name.isNotEmpty && name != _userName) {
      setState(() => _userName = name);
      HiveService.setUserName(name);
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': 'Just Now',
      });
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    final systemPrompt = _userName.isNotEmpty
        ? 'You are a friendly AI English teacher named Keshab. '
            "Your student's name is $_userName. "
            'Your job is to help the student learn and practice English in a natural, fun way. '
            'The student can ask questions in English or Bangla (Bengali). '
            'IMPORTANT: Always respond in English first, then immediately provide the Bangla translation below. '
            'Format your response like this:\n'
            '[Your English response here]\n\n'
            'বাংলা: [Bangla translation]\n'
            '---\n'
            'When correcting grammar, first show the correction in English, then explain in Bangla. '
            'When introducing new vocabulary, give the English word with meaning and example in English, '
            'then translate the example to Bangla. '
            'Keep responses friendly, concise, and encouraging. '
            'Always address the student by name when possible.'
        : null;

    if (systemPrompt != null) {
      AIService().sendMessageWithSystem(text, systemPrompt: systemPrompt).then((response) {
        if (!mounted) return;
        setState(() {
          _isTyping = false;
          _messages.add({
            'text': response,
            'isMe': false,
            'time': 'Just Now',
          });
        });
        _scrollToBottom();
      });
    } else {
      AIService().sendMessage(text).then((response) {
        if (!mounted) return;
        setState(() {
          _isTyping = false;
          _messages.add({
            'text': response,
            'isMe': false,
            'time': 'Just Now',
          });
        });
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final quickTopics = [
      "Check my grammar",
      "Suggest vocabulary",
      "বাংলায় ইংরেজি শেখা",
      "Let's practice greetings",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI English Teacher',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Online',
                      style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.primary
                          : (isDark ? AppColors.surfaceDark : Colors.grey[100]),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(0),
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(18),
                      ),
                      border: !isMe && isDark
                          ? Border.all(color: AppColors.borderDark, width: 0.5)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'] as String,
                          style: TextStyle(
                            color: isMe ? Colors.white : (isDark ? Colors.white.withOpacity(0.9) : Colors.black87),
                            fontSize: 15,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            msg['time'] as String,
                            style: TextStyle(
                              color: isMe ? Colors.white60 : Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isTyping) ...[
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI is typing...',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Quick prompt chips
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: quickTopics.length,
              itemBuilder: (context, index) {
                final topic = quickTopics[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ActionChip(
                    label: Text(
                      topic,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : Colors.grey[200]!,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () {
                      _messageController.text = topic;
                      _sendMessage();
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Message input bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : Colors.grey[100]!,
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask your teacher anything...',
                      hintStyle: const TextStyle(fontSize: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 22,
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
