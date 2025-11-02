import 'package:flutter/material.dart';

class AIAssistantWidget extends StatefulWidget {
  const AIAssistantWidget({super.key});

  @override
  State<AIAssistantWidget> createState() => _AIAssistantWidgetState();
}

class _AIAssistantWidgetState extends State<AIAssistantWidget> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      right: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isOpen) _buildChatBubble(),
          const SizedBox(height: 12),
          Semantics(
            label: _isOpen ? 'Close AI assistant' : 'Open AI assistant',
            button: true,
            hint: _isOpen ? 'Close chat window' : 'Get help from AI travel assistant',
            child: Tooltip(
              message: _isOpen ? 'Close AI Assistant' : 'Open AI Assistant',
              child: FloatingActionButton.extended(
                onPressed: () => setState(() => _isOpen = !_isOpen),
                backgroundColor: const Color(0xFF007BFF),
                icon: Icon(_isOpen ? Icons.close : Icons.smart_toy),
                label: Text(_isOpen ? 'Close' : 'AI Assistant'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble() {
    return Container(
      width: 350,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF007BFF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'AI Travel Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMessage(
                  'Hi! I can tweak your trip for more nightlife or adventure options. Want to adjust your plan?',
                  isBot: true,
                ),
                const SizedBox(height: 12),
                _buildMessage('Can you add more food experiences?', isBot: false),
                const SizedBox(height: 12),
                _buildMessage(
                  'Absolutely! I\'ve added 3 more authentic Rajasthani food experiences to your itinerary. Check Day 2 and Day 4!',
                  isBot: true,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Message to AI assistant',
                    textField: true,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: 'Send message',
                  button: true,
                  child: Tooltip(
                    message: 'Send message',
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF007BFF),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI chat coming soon'))),
                      ),
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

  Widget _buildMessage(String text, {required bool isBot}) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isBot ? Colors.grey.shade200 : const Color(0xFF007BFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isBot ? Colors.black : Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
