import 'package:flutter/material.dart';
import '../widgets/hero_search_widget.dart';
import '../widgets/footer.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/trending_carousel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _navigateTo(BuildContext context, String route) {
    try {
      Navigator.pushNamed(context, route);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _scrollToSearch(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scroll down to use AI Trip Planner')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(),
      drawer: MediaQuery.of(context).size.width < 800 ? _buildDrawer(context) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeroCarousel(),
            const SizedBox(height: 40),
            const HeroSearchWidget(),
            const SizedBox(height: 60),
            const TrendingCarousel(),
            const SizedBox(height: 60),
            _buildWhyChooseUs(),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: const Text('EaseMyTrip AI', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          ListTile(leading: const Icon(Icons.flight), title: const Text('Flights'), onTap: () => _navigateTo(context, '/flights')),
          ListTile(leading: const Icon(Icons.hotel), title: const Text('Hotels'), onTap: () => _navigateTo(context, '/hotels')),
          ListTile(leading: const Icon(Icons.card_travel), title: const Text('Holiday Packages'), onTap: () => _navigateTo(context, '/offers')),
          ListTile(leading: const Icon(Icons.train), title: const Text('Trains'), onTap: () => _navigateTo(context, '/trains')),
          ListTile(leading: const Icon(Icons.directions_bus), title: const Text('Buses'), onTap: () => _navigateTo(context, '/buses')),
          ListTile(leading: const Icon(Icons.local_taxi), title: const Text('Cabs'), onTap: () => _navigateTo(context, '/cabs')),
          ListTile(leading: const Icon(Icons.luggage), title: const Text('My Trips'), onTap: () => _navigateTo(context, '/my-trips')),
          ListTile(leading: const Icon(Icons.auto_awesome), title: const Text('AI Trip Planner'), onTap: () => _scrollToSearch(context)),
          ListTile(leading: const Icon(Icons.login), title: const Text('Login / Sign Up'), onTap: () => _navigateTo(context, '/login')),
        ],
      ),
    );
  }





  Widget _buildWhyChooseUs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 800;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 20 : 40, vertical: isSmall ? 40 : 60),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            children: [
              Text('Why Choose EaseMyTrip AI Planner', style: TextStyle(fontSize: isSmall ? 24 : 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: isSmall ? 30 : 40),
              isSmall
                  ? Column(
                      children: [
                        _buildFeatureCard(context, Icons.auto_awesome, 'Personalized AI Trips', 'Get itineraries tailored to your interests', 0),
                        const SizedBox(height: 20),
                        _buildFeatureCard(context, Icons.check_circle_outline, 'Seamless Bookings', 'Book your entire trip with one click', 1),
                        const SizedBox(height: 20),
                        _buildFeatureCard(context, Icons.update, 'Smart Real-Time Adjustments', 'AI adapts based on weather and delays', 2),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildFeatureCard(context, Icons.auto_awesome, 'Personalized AI Trips', 'Get itineraries tailored to your interests', 0)),
                        const SizedBox(width: 30),
                        Expanded(child: _buildFeatureCard(context, Icons.check_circle_outline, 'Seamless Bookings', 'Book your entire trip with one click', 1)),
                        const SizedBox(width: 30),
                        Expanded(child: _buildFeatureCard(context, Icons.update, 'Smart Real-Time Adjustments', 'AI adapts based on weather and delays', 2)),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String description, int index) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('feature_$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 150)),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
              child: Icon(icon, size: 50, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(description, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
