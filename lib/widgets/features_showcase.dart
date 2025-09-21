import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/camera_service.dart';
import '../services/integration_service.dart';
import '../services/collaboration_service.dart';
import '../services/personalization_service.dart';
import '../services/ar_service.dart';
import '../services/analytics_service.dart';
import '../services/gamification_service.dart';
import '../services/community_service.dart';
import '../services/smart_features_service.dart';

class FeaturesShowcase extends StatefulWidget {
  const FeaturesShowcase({super.key});

  @override
  State<FeaturesShowcase> createState() => _FeaturesShowcaseState();
}

class _FeaturesShowcaseState extends State<FeaturesShowcase> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1722),
      appBar: AppBar(
        title: const Text('Advanced Features', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0E1620),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.deepOrangeAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI & ML'),
            Tab(icon: Icon(Icons.people), text: 'Social'),
            Tab(icon: Icon(Icons.camera_alt), text: 'AR & Camera'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.integration_instructions), text: 'Integrations'),
            Tab(icon: Icon(Icons.accessibility), text: 'Accessibility'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAIMLTab(),
          _buildSocialTab(),
          _buildARCameraTab(),
          _buildAnalyticsTab(),
          _buildIntegrationsTab(),
          _buildAccessibilityTab(),
        ],
      ),
    );
  }

  Widget _buildAIMLTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFeatureCard(
            'AI Personalization Engine',
            'Machine learning powered recommendations based on user behavior and preferences',
            Icons.psychology,
            Colors.purple,
            () => _showPersonalizationDemo(),
          ),
          _buildFeatureCard(
            'Smart Packing Assistant',
            'AI-generated packing lists based on weather, activities, and destination culture',
            Icons.luggage,
            Colors.green,
            () => _showPackingDemo(),
          ),
          _buildFeatureCard(
            'Predictive Analytics',
            'Price predictions, crowd density forecasts, and optimal booking timing',
            Icons.trending_up,
            Colors.blue,
            () => _showPredictiveDemo(),
          ),
          _buildFeatureCard(
            'Carbon Footprint Tracker',
            'Real-time carbon impact calculation with offset recommendations',
            Icons.eco,
            Colors.green,
            () => _showCarbonDemo(),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFeatureCard(
            'Real-time Collaboration',
            'Plan trips together with live sync, chat, and shared decision making',
            Icons.group_work,
            Colors.blue,
            () => _showCollaborationDemo(),
          ),
          _buildFeatureCard(
            'Travel Community Hub',
            'Connect with travelers, share stories, and get local insights',
            Icons.people,
            Colors.indigo,
            () => _showCommunityDemo(),
          ),
          _buildFeatureCard(
            'Mentor Matching',
            'Connect with experienced travelers for personalized guidance',
            Icons.school,
            Colors.orange,
            () => _showMentorDemo(),
          ),
          _buildFeatureCard(
            'Gamification & Rewards',
            'Earn points, unlock achievements, and compete with fellow travelers',
            Icons.emoji_events,
            Colors.amber,
            () => _showGamificationDemo(),
          ),
        ],
      ),
    );
  }

  Widget _buildARCameraTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFeatureCard(
            'AR Navigation',
            'Augmented reality directions and landmark recognition',
            Icons.view_in_ar,
            Colors.purple,
            () => _showARDemo(),
          ),
          _buildFeatureCard(
            'Visual Search',
            'Camera-based landmark identification and information lookup',
            Icons.camera_alt,
            Colors.teal,
            () => _showVisualSearchDemo(),
          ),
          _buildFeatureCard(
            'Real-time Translation',
            'Instant translation of signs, menus, and text using camera',
            Icons.translate,
            Colors.green,
            () => _showTranslationDemo(),
          ),
          _buildFeatureCard(
            'QR Code Sharing',
            'Share itineraries and contact information via QR codes',
            Icons.qr_code,
            Colors.blue,
            () => _showQRCodeDemo(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFeatureCard(
            'Travel Pattern Analysis',
            'Insights into your travel habits, preferences, and spending patterns',
            Icons.insights,
            Colors.blue,
            () => _showTravelAnalyticsDemo(),
          ),
          _buildFeatureCard(
            'Budget Optimization',
            'AI-powered budget analysis with savings recommendations',
            Icons.savings,
            Colors.green,
            () => _showBudgetAnalyticsDemo(),
          ),
          _buildFeatureCard(
            'Price Monitoring',
            'Dynamic price alerts and optimal booking time predictions',
            Icons.price_change,
            Colors.orange,
            () => _showPriceMonitoringDemo(),
          ),
          _buildFeatureCard(
            'Health & Safety Scores',
            'Real-time safety ratings and health recommendations for destinations',
            Icons.health_and_safety,
            Colors.red,
            () => _showSafetyDemo(),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFeatureCard(
            'Calendar Integration',
            'Seamless sync with Google Calendar and Outlook',
            Icons.calendar_month,
            Colors.blue,
            () => _showCalendarDemo(),
          ),
          _buildFeatureCard(
            'Ride-sharing Integration',
            'Direct booking with Uber, Ola, and local transport services',
            Icons.directions_car,
            Colors.green,
            () => _showRideDemo(),
          ),
          _buildFeatureCard(
            'Food Delivery Integration',
            'Order meals directly to your hotel or location',
            Icons.restaurant,
            Colors.orange,
            () => _showFoodDemo(),
          ),
          _buildFeatureCard(
            'Multi-Currency Support',
            'Real-time currency conversion and price comparisons',
            Icons.currency_exchange,
            Colors.purple,
            () => _showCurrencyDemo(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFeatureCard(
            'Screen Reader Optimization',
            'Enhanced accessibility for visually impaired users',
            Icons.accessibility,
            Colors.blue,
            () => _showAccessibilityDemo(),
          ),
          _buildFeatureCard(
            'Disability-Friendly Options',
            'Curated recommendations for accessible venues and activities',
            Icons.accessible,
            Colors.green,
            () => _showDisabilityFriendlyDemo(),
          ),
          _buildFeatureCard(
            'Cultural Sensitivity Alerts',
            'Local customs, etiquette, and cultural guidance',
            Icons.public,
            Colors.orange,
            () => _showCulturalDemo(),
          ),
          _buildFeatureCard(
            'Emergency Support System',
            '24/7 emergency assistance with location sharing',
            Icons.emergency,
            Colors.red,
            () => _showEmergencyDemo(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      color: const Color(0xFF0E1620),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  // Demo methods for each feature
  void _showPersonalizationDemo() {
    _showDemoDialog(
      'AI Personalization Engine',
      'This feature analyzes your travel history, preferences, and behavior to provide personalized recommendations. It learns from your choices and continuously improves suggestions.',
      Icons.psychology,
      Colors.purple,
    );
  }

  void _showPackingDemo() {
    _showDemoDialog(
      'Smart Packing Assistant',
      'AI generates customized packing lists based on:\n• Weather forecast\n• Planned activities\n• Trip duration\n• Destination culture\n• Personal preferences',
      Icons.luggage,
      Colors.green,
    );
  }

  void _showPredictiveDemo() {
    _showDemoDialog(
      'Predictive Analytics',
      'Advanced algorithms predict:\n• Flight price trends\n• Hotel availability\n• Crowd density at attractions\n• Optimal booking times\n• Weather patterns',
      Icons.trending_up,
      Colors.blue,
    );
  }

  void _showCarbonDemo() {
    _showDemoDialog(
      'Carbon Footprint Tracker',
      'Real-time calculation of your travel impact:\n• Transport emissions\n• Accommodation footprint\n• Activity carbon cost\n• Offset recommendations\n• Eco-friendly alternatives',
      Icons.eco,
      Colors.green,
    );
  }

  void _showCollaborationDemo() {
    _showDemoDialog(
      'Real-time Collaboration',
      'Plan trips together with:\n• Live itinerary sync\n• Group chat integration\n• Shared decision making\n• Expense splitting\n• Role-based permissions',
      Icons.group_work,
      Colors.blue,
    );
  }

  void _showCommunityDemo() {
    _showDemoDialog(
      'Travel Community Hub',
      'Connect with fellow travelers:\n• Share travel stories\n• Live travel updates\n• Local recommendations\n• Photo sharing\n• Travel tips exchange',
      Icons.people,
      Colors.indigo,
    );
  }

  void _showMentorDemo() {
    _showDemoDialog(
      'Mentor Matching',
      'Get guidance from experienced travelers:\n• Destination experts\n• Budget travel specialists\n• Solo travel mentors\n• Family travel advisors\n• Adventure guides',
      Icons.school,
      Colors.orange,
    );
  }

  void _showGamificationDemo() {
    _showDemoDialog(
      'Gamification & Rewards',
      'Earn rewards for traveling:\n• Points for bookings\n• Achievement badges\n• Travel streaks\n• Leaderboards\n• Exclusive perks',
      Icons.emoji_events,
      Colors.amber,
    );
  }

  void _showARDemo() {
    _showDemoDialog(
      'AR Navigation',
      'Augmented reality features:\n• AR directions overlay\n• Landmark recognition\n• Distance measurements\n• Points of interest\n• Interactive navigation',
      Icons.view_in_ar,
      Colors.purple,
    );
  }

  void _showVisualSearchDemo() {
    _showDemoDialog(
      'Visual Search',
      'Camera-powered search:\n• Landmark identification\n• Historical information\n• Nearby attractions\n• Opening hours\n• Ticket prices',
      Icons.camera_alt,
      Colors.teal,
    );
  }

  void _showTranslationDemo() {
    _showDemoDialog(
      'Real-time Translation',
      'Instant translation using camera:\n• Menu translation\n• Sign translation\n• Text recognition\n• Voice translation\n• Offline support',
      Icons.translate,
      Colors.green,
    );
  }

  void _showQRCodeDemo() {
    _showDemoDialog(
      'QR Code Sharing',
      'Easy sharing with QR codes:\n• Itinerary sharing\n• Contact exchange\n• Location sharing\n• Quick connections\n• Universal compatibility',
      Icons.qr_code,
      Colors.blue,
    );
  }

  void _showTravelAnalyticsDemo() {
    _showDemoDialog(
      'Travel Pattern Analysis',
      'Comprehensive travel insights:\n• Spending patterns\n• Destination preferences\n• Travel frequency\n• Seasonal trends\n• Optimization suggestions',
      Icons.insights,
      Colors.blue,
    );
  }

  void _showBudgetAnalyticsDemo() {
    _showDemoDialog(
      'Budget Optimization',
      'Smart budget management:\n• Spending breakdown\n• Savings opportunities\n• Price comparisons\n• Budget alerts\n• Cost predictions',
      Icons.savings,
      Colors.green,
    );
  }

  void _showPriceMonitoringDemo() {
    _showDemoDialog(
      'Price Monitoring',
      'Dynamic price tracking:\n• Price drop alerts\n• Booking recommendations\n• Market trends\n• Seasonal pricing\n• Best time to book',
      Icons.price_change,
      Colors.orange,
    );
  }

  void _showSafetyDemo() {
    _showDemoDialog(
      'Health & Safety Scores',
      'Real-time safety information:\n• Destination safety ratings\n• Health advisories\n• Emergency contacts\n• Travel insurance\n• Risk assessments',
      Icons.health_and_safety,
      Colors.red,
    );
  }

  void _showCalendarDemo() {
    _showDemoDialog(
      'Calendar Integration',
      'Seamless calendar sync:\n• Auto-add travel dates\n• Flight reminders\n• Activity scheduling\n• Meeting conflicts\n• Time zone adjustments',
      Icons.calendar_month,
      Colors.blue,
    );
  }

  void _showRideDemo() {
    _showDemoDialog(
      'Ride-sharing Integration',
      'Direct transport booking:\n• Uber integration\n• Ola booking\n• Local taxi services\n• Public transport\n• Route optimization',
      Icons.directions_car,
      Colors.green,
    );
  }

  void _showFoodDemo() {
    _showDemoDialog(
      'Food Delivery Integration',
      'Order food anywhere:\n• Hotel delivery\n• Local restaurants\n• Dietary preferences\n• Real-time tracking\n• Payment integration',
      Icons.restaurant,
      Colors.orange,
    );
  }

  void _showCurrencyDemo() {
    _showDemoDialog(
      'Multi-Currency Support',
      'Global currency features:\n• Real-time conversion\n• Price comparisons\n• Exchange rate alerts\n• Local payment methods\n• Budget tracking',
      Icons.currency_exchange,
      Colors.purple,
    );
  }

  void _showAccessibilityDemo() {
    _showDemoDialog(
      'Screen Reader Optimization',
      'Enhanced accessibility:\n• Voice navigation\n• Screen reader support\n• High contrast mode\n• Large text options\n• Gesture controls',
      Icons.accessibility,
      Colors.blue,
    );
  }

  void _showDisabilityFriendlyDemo() {
    _showDemoDialog(
      'Disability-Friendly Options',
      'Accessible travel planning:\n• Wheelchair accessible venues\n• Accessible transport\n• Special assistance\n• Accessible accommodations\n• Support services',
      Icons.accessible,
      Colors.green,
    );
  }

  void _showCulturalDemo() {
    _showDemoDialog(
      'Cultural Sensitivity Alerts',
      'Cultural guidance:\n• Local customs\n• Dress codes\n• Etiquette tips\n• Religious considerations\n• Language basics',
      Icons.public,
      Colors.orange,
    );
  }

  void _showEmergencyDemo() {
    _showDemoDialog(
      'Emergency Support System',
      '24/7 emergency assistance:\n• Emergency contacts\n• Location sharing\n• Medical assistance\n• Embassy information\n• Insurance claims',
      Icons.emergency,
      Colors.red,
    );
  }

  void _showDemoDialog(String title, String content, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0E1620),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.deepOrangeAccent)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title feature activated!'),
                  backgroundColor: color,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: const Text('Try Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}