import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/map_widget.dart' deferred as map_module;
import '../widgets/weather_widget.dart';
import '../widgets/ai_loading_widget.dart';
import '../providers/trip_planner_provider.dart';
import '../providers/app_state.dart';
import '../providers/mock_data_provider.dart';
import '../services/gemini_service.dart'; // Now uses backend API
import '../utils/share_utils.dart';
import '../utils/image_helper.dart';
import '../utils/responsive.dart';
import '../models/booking.dart';

class AIResultScreen extends StatefulWidget {
  const AIResultScreen({super.key});

  @override
  State<AIResultScreen> createState() => _AIResultScreenState();
}

class _AIResultScreenState extends State<AIResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showChat = false;
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final AIService _aiService = AIService(); // Backend API service
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _messages.add(ChatMessage(
      text: 'Hi! I can help you modify your trip, suggest alternatives, or answer questions about your itinerary. How can I assist you?',
      isBot: true,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripPlannerProvider>();
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your AI-Generated Itinerary',
          style: TextStyle(
            color: const Color(0xFF007BFF),
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(context, Responsive.isMobile(context) ? 16 : 20),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Color(0xFF007BFF)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroSection(context, appState, tripProvider),
                Padding(
                  padding: Responsive.padding(context),
                  child: Responsive.isDesktop(context)
                      ? _buildDesktopLayout(tripProvider)
                      : _buildMobileLayout(tripProvider),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildAIAssistant(),
    );
  }

  Widget _buildAIAssistant() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_showChat) _buildChatBubble(),
        if (_showChat) const SizedBox(height: 12),
        Semantics(
          label: _showChat ? 'Close AI assistant' : 'Open AI assistant',
          button: true,
          child: Tooltip(
            message: _showChat ? 'Close AI Assistant' : 'Open AI Assistant',
            child: FloatingActionButton.extended(
              onPressed: () => setState(() => _showChat = !_showChat),
              backgroundColor: const Color(0xFF007BFF),
              icon: Icon(_showChat ? Icons.close : Icons.smart_toy),
              label: Text(_showChat ? 'Close' : 'AI Assistant'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble() {
    return Container(
      width: 350,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20)],
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
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMessage(message.text, message.isBot),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text('AI is thinking...', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
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
                        onPressed: _isLoading ? null : _sendMessage,
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

  Widget _buildMessage(String text, bool isBot) {
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
          style: TextStyle(color: isBot ? Colors.black : Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isBot: false));
      _messageController.clear();
      _isLoading = true;
    });

    try {
      final appState = context.read<AppState>();
      final tripContext = '''
Destination: ${appState.to ?? 'Jaipur'}
Duration: ${appState.tripDuration} days
Budget: ₹${appState.budget.toInt()}
Themes: ${appState.selectedThemes.join(', ')}
''';

      final response = await _aiService.sendMessage(text, tripContext);
      
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: response, isBot: true));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: 'Sorry, I encountered an error. Please try again.', isBot: true));
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildHeroSection(BuildContext context, AppState appState, TripPlannerProvider tripProvider) {
    final isMobile = Responsive.isMobile(context);
    final height = isMobile ? 350.0 : 300.0;
    final destination = appState.to ?? 'Jaipur';
    final days = appState.tripDuration > 0 ? appState.tripDuration : 5;
    final titleSize = Responsive.fontSize(context, isMobile ? 24 : 36);
    final subtitleSize = Responsive.fontSize(context, isMobile ? 14 : 18);
        
    return Hero(
      tag: 'trip_hero',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Semantics(
                image: true,
                label: '$destination destination hero image',
                child: cachedHeroImage(
                  'https://images.unsplash.com/photo-1477587458883-47145ed94245?w=1200',
                  height: height,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.5)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: Responsive.padding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your $days-Day Trip to $destination',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tailored by AI based on your preferences',
                      style: TextStyle(color: Colors.white, fontSize: subtitleSize),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        WeatherWidget(city: appState.to ?? 'Jaipur'),
                        _ActionButton(
                          icon: Icons.edit,
                          label: isMobile ? 'Edit' : 'Edit Inputs',
                          onPressed: () => _editInputs(context),
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF007BFF),
                        ),
                        _ActionButton(
                          icon: Icons.share,
                          label: 'Share',
                          onPressed: () => _shareItinerary(context),
                        ),
                        _ActionButton(
                          icon: Icons.bookmark_add,
                          label: isMobile ? 'Save' : 'Save Trip',
                          onPressed: () => _saveTrip(context),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        _ActionButton(
                          icon: Icons.check_circle,
                          label: isMobile ? 'Book' : 'Book Trip',
                          onPressed: () => _bookTrip(context),
                          backgroundColor: const Color(0xFF28a745),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(TripPlannerProvider tripProvider) {
    if (tripProvider.isGenerating) {
      return const Center(child: AILoadingWidget());
    }

    if (tripProvider.selectedItinerary == null) {
      return const Center(child: Text('No itinerary available'));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: FutureBuilder(
            future: map_module.loadLibrary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return map_module.MapWidget(waypoints: tripProvider.waypoints);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildItineraryList(tripProvider),
              const SizedBox(height: 20),
              _buildBudgetSummary(tripProvider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(TripPlannerProvider tripProvider) {
    if (tripProvider.isGenerating) {
      return const Center(child: AILoadingWidget());
    }

    if (tripProvider.selectedItinerary == null) {
      return const Center(child: Text('No itinerary available'));
    }

    return Column(
      children: [
        _buildItineraryList(tripProvider),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _showMapBottomSheet(context, tripProvider),
          icon: const Icon(Icons.map),
          label: const Text('View Map'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 20),
        _buildBudgetSummary(tripProvider),
      ],
    );
  }

  void _showMapBottomSheet(BuildContext context, TripPlannerProvider tripProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trip Map',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: map_module.loadLibrary(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return map_module.MapWidget(waypoints: tripProvider.waypoints);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItineraryList(TripPlannerProvider tripProvider) {
    final itinerary = tripProvider.selectedItinerary!['itinerary'] as List;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFE3F2FD),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF007BFF)),
                SizedBox(width: 12),
                Text('Day-by-Day Itinerary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: itinerary.length,
            itemBuilder: (context, index) {
              final day = itinerary[index];
              return _buildDayCard(day);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> day) {
    final activities = day['activities'] as List;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text('Day ${day['day']}: ${day['title']}', style: const TextStyle(fontWeight: FontWeight.bold)),
        children: activities.map<Widget>((activity) {
          return ListTile(
            leading: Icon(_getActivityIcon(activity['type']), color: const Color(0xFF007BFF)),
            title: Text(activity['title']),
            subtitle: Text('${activity['time']} • ${activity['cost']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text('${activity['rating']}'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'hotel': return Icons.hotel;
      case 'restaurant': return Icons.restaurant;
      default: return Icons.place;
    }
  }

  Widget _buildBudgetSummary(TripPlannerProvider tripProvider) {
    final budget = tripProvider.selectedItinerary!['budget_breakdown'] as Map<String, dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Budget Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...budget.entries.where((e) => e.key != 'total').map(
            (e) => _buildBudgetRow(e.key, e.value),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                budget['total'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF007BFF)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _editInputs(BuildContext context) {
    Navigator.pop(context);
  }

  void _shareItinerary(BuildContext context) async {
    try {
      final mockData = context.read<MockDataProvider>();
      final itinerary = mockData.getSelectedItinerary();

      if (itinerary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No itinerary to share'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await shareItinerary(context, itinerary);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveTrip(BuildContext context) async {
    try {
      final mockData = context.read<MockDataProvider>();
      final itinerary = mockData.getSelectedItinerary();

      if (itinerary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No itinerary selected'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create a booking entry for saved trip
      final booking = Booking(
        id: 'SAVED_${DateTime.now().millisecondsSinceEpoch}',
        itineraryId: itinerary.id,
        userName: 'Guest',
        email: 'guest@example.com',
        amount: itinerary.totalCost,
        timestamp: DateTime.now(),
      );

      mockData.saveBooking(booking);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Saved to My Trips'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _bookTrip(BuildContext context) async {
    try {
      final mockData = context.read<MockDataProvider>();
      final itinerary = mockData.getSelectedItinerary();

      if (itinerary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No itinerary selected'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.pushNamed(context, '/booking', arguments: itinerary);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class ChatMessage {
  final String text;
  final bool isBot;

  ChatMessage({required this.text, required this.isBot});
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Tooltip(
        message: label,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}


