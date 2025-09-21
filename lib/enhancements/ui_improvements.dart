// UI Improvements for Trip Planner
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UIImprovements {
  // Enhanced Landing Page Hero Section
  static Widget buildImprovedHeroSection({
    required String destination,
    required VoidCallback onPlanTrip,
  }) {
    return Container(
      height: 650,
      child: Stack(
        children: [
          // Video-like Background Animation
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E),
                  Color(0xFF3949AB),
                  Color(0xFF5E35B1),
                  Color(0xFF7B1FA2),
                ],
              ),
            ),
          ),
          // Floating Elements Animation
          ...List.generate(20, (index) => 
            Positioned(
              left: (index * 50.0) % 400,
              top: (index * 30.0) % 600,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .moveY(begin: 0, end: -100, duration: (3000 + index * 200).ms)
                .fadeIn()
                .then()
                .fadeOut(),
            )
          ),
          // Main Content
          Positioned(
            bottom: 100,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Your Perfect\nIndian Adventure',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                SizedBox(height: 16),
                Text(
                  'AI-powered itineraries • Real-time booking • Local experiences',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ).animate().fadeIn(delay: 600.ms),
                SizedBox(height: 32),
                // Trust Indicators
                Row(
                  children: [
                    _buildTrustIndicator('50K+', 'Happy Travelers'),
                    SizedBox(width: 16),
                    _buildTrustIndicator('4.8★', 'App Rating'),
                    SizedBox(width: 16),
                    _buildTrustIndicator('₹2L+', 'Saved'),
                  ],
                ).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTrustIndicator(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  // Enhanced Destination Cards with Better Visual Hierarchy
  static Widget buildPremiumDestinationCard({
    required String name,
    required String imageUrl,
    required String price,
    required double rating,
    required String description,
    required List<String> highlights,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 320,
      margin: EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Stack(
          children: [
            // Image
            Container(
              height: 240,
              width: double.infinity,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
            // Gradient Overlay
            Container(
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // Trending Badge
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.red, Colors.pink]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Trending', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            // Rating Badge
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    SizedBox(width: 2),
                    Text('$rating', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    // Highlights
                    Wrap(
                      spacing: 8,
                      children: highlights.take(3).map((highlight) => 
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.deepOrangeAccent.withOpacity(0.5)),
                          ),
                          child: Text(
                            highlight,
                            style: TextStyle(
                              color: Colors.deepOrangeAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ).toList(),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Starting $price',
                          style: TextStyle(
                            color: Colors.deepOrangeAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.deepOrangeAccent, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Explore',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Tap Handler
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: Colors.deepOrangeAccent.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideX(begin: 0.3),
    );
  }

  // Enhanced Itinerary Cards with Better Information Architecture
  static Widget buildEnhancedItineraryCard({
    required String title,
    required String description,
    required String imageUrl,
    required double rating,
    required int reviews,
    required int cost,
    required String duration,
    required String category,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Category Badge
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    duration,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '₹$cost',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    // Rating
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12),
                          SizedBox(width: 2),
                          Text(
                            '$rating',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2),
                          Text(
                            '($reviews)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    // Action Buttons
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.favorite_border, color: Colors.white70, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        padding: EdgeInsets.all(8),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share, color: Colors.white70, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        padding: EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  static Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'heritage':
        return Colors.brown;
      case 'adventure':
        return Colors.green;
      case 'food':
        return Colors.orange;
      case 'nature':
        return Colors.teal;
      case 'culture':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}