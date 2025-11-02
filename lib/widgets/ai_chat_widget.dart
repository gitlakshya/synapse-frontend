import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import 'login_button_widget.dart';

class AIChatButton extends StatefulWidget {
  final bool showLabel;
  const AIChatButton({super.key, this.showLabel = true});

  @override
  State<AIChatButton> createState() => _AIChatButtonState();
}

class _AIChatButtonState extends State<AIChatButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Added login check for AI Chat button to open login modal when user not logged in
  void _handleChatOpen(BuildContext context) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
      if (!authProvider.isAuthenticated) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => LoginModal(
            onLoginSuccess: () {
              Navigator.of(dialogContext).pop();
              chatProvider.toggleChat();
            },
          ),
        );
      } else {
        chatProvider.toggleChat();
      }
    } catch (e) {
      debugPrint('Error opening AI chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open AI chat. Please try again.'),
          backgroundColor: Color(0xFFDC3545),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showLabel) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007BFF).withOpacity(0.3 + (_pulseController.value * 0.3)),
                  blurRadius: 8 + (_pulseController.value * 8),
                  spreadRadius: 2 + (_pulseController.value * 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.smart_toy),
              onPressed: () => _handleChatOpen(context),
              tooltip: 'AI Assistant',
              color: const Color(0xFF007BFF),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                side: BorderSide(
                  color: const Color(0xFF007BFF).withOpacity(0.5 + (_pulseController.value * 0.5)),
                  width: 2,
                ),
              ),
            ),
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return InkWell(
          onTap: () => _handleChatOpen(context),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: const Color(0xFF007BFF).withOpacity(0.5 + (_pulseController.value * 0.5)),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007BFF).withOpacity(0.3 + (_pulseController.value * 0.3)),
                  blurRadius: 8 + (_pulseController.value * 8),
                  spreadRadius: 2 + (_pulseController.value * 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smart_toy, color: const Color(0xFF007BFF)),
                const SizedBox(width: 8),
                Text(
                  'AI Assist',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AIChatWindow extends StatefulWidget {
  final VoidCallback onClose;

  const AIChatWindow({super.key, required this.onClose});

  @override
  State<AIChatWindow> createState() => _AIChatWindowState();
}

class _AIChatWindowState extends State<AIChatWindow> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  final ChatService _chatService = ChatService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
    
    // Welcome message
    _messages.add({
      'sender': 'ai',
      'message': 'Hi! I\'m your AI travel assistant. How can I help you plan your perfect trip?',
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add({'sender': 'user', 'message': userMessage});
    });

    _scrollToBottom();

    // Get AI response from service
    try {
      final response = await _chatService.sendMessage(userMessage);
      if (mounted) {
        setState(() {
          _messages.add({'sender': 'ai', 'message': response});
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'sender': 'ai', 'message': 'Sorry, I encountered an error. Please try again.'});
        });
      }
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
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 380,
          height: 500,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF007BFF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Travel Assistant',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Online',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message['sender'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color(0xFF007BFF)
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          message['message']!,
                          style: TextStyle(
                            color: isUser
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask me anything...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      color: const Color(0xFF007BFF),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
