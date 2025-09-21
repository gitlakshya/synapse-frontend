import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/animated_hero_section.dart';
import '../widgets/micro_interactions.dart';
import '../widgets/page_transitions.dart';
import '../widgets/advanced_animations.dart';

class AnimationShowcaseScreen extends StatefulWidget {
  const AnimationShowcaseScreen({super.key});

  @override
  State<AnimationShowcaseScreen> createState() => _AnimationShowcaseScreenState();
}

class _AnimationShowcaseScreenState extends State<AnimationShowcaseScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchText = '';
  double _budgetValue = 50000;
  bool _isMorphingExpanded = false;
  int _selectedShowcaseIndex = 0;

  final List<String> _showcaseTabs = [
    'Hero & Search',
    'Micro-Interactions',
    'Page Transitions',
    'Interactive Maps',
    'Advanced Effects',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _showcaseTabs.length,
      vsync: this,
    );
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHeroShowcase(),
                  _buildMicroInteractionsShowcase(),
                  _buildPageTransitionsShowcase(),
                  _buildInteractiveShowcase(),
                  _buildAdvancedEffectsShowcase(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepOrangeAccent.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Animation Showcase',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Interactive UI Components & Animations',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.deepOrangeAccent, size: 16),
                SizedBox(width: 4),
                Text(
                  'Premium',
                  style: TextStyle(
                    color: Colors.deepOrangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.3);
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: Colors.deepOrangeAccent,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        tabs: _showcaseTabs.map((tab) => Tab(text: tab)).toList(),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3);
  }

  Widget _buildHeroShowcase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hero Section with Morphing Search',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedHeroSection(
            destination: _searchText,
            onDestinationChanged: (value) => setState(() => _searchText = value),
            onPlanTrip: () {
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Trip planning started!'),
                  backgroundColor: Colors.deepOrangeAccent,
                ),
              );
            },
            height: 400,
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(
            'Features Demonstrated',
            [
              '• Morphing search bar with focus animations',
              '• Interactive destination cards with hover effects',
              '• Parallax background movement',
              '• Animated trust badges with counters',
              '• Glassmorphism effects with backdrop blur',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMicroInteractionsShowcase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Micro-Interactions & Feedback',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Animated Buttons
          const Text('Animated Buttons', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AnimatedButton(
                text: 'Bounce Effect',
                icon: Icons.touch_app,
                animationType: AnimationType.bounce,
                onPressed: () => _showFeedback('Bounce animation triggered!'),
              ),
              AnimatedButton(
                text: 'Spring Effect',
                icon: Icons.gesture,
                animationType: AnimationType.spring,
                backgroundColor: Colors.blue,
                onPressed: () => _showFeedback('Spring animation triggered!'),
              ),
              AnimatedButton(
                text: 'Ripple Effect',
                icon: Icons.waves,
                animationType: AnimationType.ripple,
                backgroundColor: Colors.purple,
                onPressed: () => _showFeedback('Ripple animation triggered!'),
              ),
              AnimatedButton(
                text: 'Loading State',
                icon: Icons.download,
                isLoading: true,
                backgroundColor: Colors.green,
                onPressed: () {},
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Animated Text Fields
          const Text('Animated Text Fields', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          AnimatedTextField(
            hintText: 'Enter destination',
            labelText: 'Destination',
            prefixIcon: Icons.location_on,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a destination';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AnimatedTextField(
            hintText: 'Enter your budget',
            labelText: 'Budget',
            prefixIcon: Icons.currency_rupee,
            suffixIcon: Icons.info,
            onSuffixTap: () => _showFeedback('Budget info tapped!'),
          ),
          
          const SizedBox(height: 24),
          
          // Progress Indicators
          const Text('Progress Indicators', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          ProgressIndicatorWidget(
            progress: 0.7,
            label: 'Trip Planning Progress',
            color: Colors.deepOrangeAccent,
          ),
          const SizedBox(height: 16),
          ProgressIndicatorWidget(
            progress: 0.4,
            label: 'Budget Allocation',
            color: Colors.blue,
          ),
          
          const SizedBox(height: 24),
          
          // Skeleton Loaders
          const Text('Skeleton Loaders', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              const SkeletonLoader(width: 60, height: 60, borderRadius: BorderRadius.all(Radius.circular(30))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    const SkeletonLoader(width: double.infinity, height: 16),
                    const SizedBox(height: 8),
                    SkeletonLoader(width: MediaQuery.of(context).size.width * 0.6, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageTransitionsShowcase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Page Transitions & Morphing',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Transition Demos
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildTransitionDemo(
                'Slide Transition',
                Icons.swipe,
                Colors.blue,
                () => _navigateWithTransition(RouteTransitions.slideFromRight(_buildDemoPage('Slide Transition'))),
              ),
              _buildTransitionDemo(
                'Fade Scale',
                Icons.zoom_in,
                Colors.green,
                () => _navigateWithTransition(RouteTransitions.fadeScale(_buildDemoPage('Fade Scale'))),
              ),
              _buildTransitionDemo(
                'Travel Themed',
                Icons.flight,
                Colors.orange,
                () => _navigateWithTransition(RouteTransitions.travelThemed(_buildDemoPage('Travel Themed'))),
              ),
              _buildTransitionDemo(
                'Page Curl',
                Icons.book,
                Colors.purple,
                () => _navigateWithTransition(PageCurlTransition(child: _buildDemoPage('Page Curl'))),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Morphing Container
          const Text('Morphing Container', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _isMorphingExpanded = !_isMorphingExpanded),
            child: MorphingContainer(
              isExpanded: _isMorphingExpanded,
              fromBorderRadius: BorderRadius.circular(8),
              toBorderRadius: BorderRadius.circular(20),
              fromColor: Colors.grey[800],
              toColor: Colors.deepOrangeAccent,
              child: Container(
                width: double.infinity,
                height: _isMorphingExpanded ? 120 : 60,
                child: Center(
                  child: Text(
                    _isMorphingExpanded ? 'Expanded State\nTap to collapse' : 'Collapsed State\nTap to expand',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Staggered List
          const Text('Staggered Animations', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          StaggeredListTransition(
            children: List.generate(4, (index) => 
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepOrangeAccent,
                      child: Text('${index + 1}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Item ${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('Staggered animation demo', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveShowcase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interactive Elements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Interactive Map
          const Text('Interactive Map with Animations', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Interactive Map Demo\n(Map widget temporarily disabled)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Animated Budget Slider
          const Text('Animated Budget Slider', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Budget: ₹${_budgetValue.toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Slider(
                value: _budgetValue,
                min: 5000,
                max: 300000,
                divisions: 59,
                onChanged: (value) => setState(() => _budgetValue = value),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Weather Animations
          const Text('Weather Animations', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_sunny, color: Colors.orange, size: 24),
                    Text('32°C', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grain, color: Colors.blue, size: 24),
                    Text('24°C', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ac_unit, color: Colors.lightBlue, size: 24),
                    Text('2°C', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedEffectsShowcase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Advanced Effects & Physics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Particle Systems
          const Text('Particle Systems', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Stack(
                      children: [
                        AdvancedParticleSystem(
                          type: ParticleType.sparkle,
                          particleCount: 30,
                          baseColor: Colors.deepOrangeAccent,
                        ),
                        Center(
                          child: Text(
                            'Sparkle\nParticles',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Stack(
                      children: [
                        AdvancedParticleSystem(
                          type: ParticleType.confetti,
                          particleCount: 25,
                          baseColor: Colors.purple,
                        ),
                        Center(
                          child: Text(
                            'Confetti\nParticles',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Morphing Shapes
          const Text('Morphing Shapes', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Center(
            child: MorphingShapeWidget(
              shapes: [
                ShapeData(
                  points: [
                    const Offset(100, 50),
                    const Offset(150, 100),
                    const Offset(100, 150),
                    const Offset(50, 100),
                  ],
                  color: Colors.deepOrangeAccent,
                  strokeWidth: 3,
                ),
                ShapeData(
                  points: [
                    const Offset(100, 60),
                    const Offset(140, 80),
                    const Offset(140, 120),
                    const Offset(100, 140),
                    const Offset(60, 120),
                    const Offset(60, 80),
                  ],
                  color: Colors.blue,
                  strokeWidth: 3,
                ),
                ShapeData(
                  points: [
                    const Offset(100, 70),
                    const Offset(130, 100),
                    const Offset(100, 130),
                    const Offset(70, 100),
                  ],
                  color: Colors.green,
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Visual Feedback
          const Text('Visual Feedback Effects', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: VisualFeedbackWidget(
                  feedbackType: FeedbackType.ripple,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.deepOrangeAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Ripple Effect\nTap me!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VisualFeedbackWidget(
                  feedbackType: FeedbackType.glow,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Glow Effect\nTap me!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Physics-based Animation
          const Text('Physics-based Animation', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: PhysicsBasedAnimation(
              spring: const SpringDescription(
                mass: 1.0,
                stiffness: 100.0,
                damping: 10.0,
              ),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.sports_basketball, color: Colors.white),
              ),
            ),
          ),
          const Text(
            'Drag the ball around to see physics simulation!',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionDemo(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().scale(delay: 100.ms).fadeIn();
  }

  Widget _buildDemoPage(String title) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1722),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.deepOrangeAccent,
              size: 80,
            ).animate().scale(delay: 300.ms).fadeIn(),
            const SizedBox(height: 20),
            Text(
              '$title Demo Page',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 10),
            const Text(
              'This demonstrates the page transition animation',
              style: TextStyle(color: Colors.white70),
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, List<String> features) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              feature,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          )),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  void _navigateWithTransition(Route route) {
    Navigator.of(context).push(route);
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepOrangeAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}