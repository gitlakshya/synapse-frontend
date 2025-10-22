import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/gamification_service.dart';
import '../services/analytics_service.dart';
import '../services/community_service.dart';
import '../services/smart_features_service.dart';

class AdvancedFeaturesWidgets {
  
  // Gamification Dashboard
  static Widget buildGamificationDashboard() {
    return FutureBuilder<UserStats>(
      future: GamificationService.getUserStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        
        final stats = snapshot.data!;
        return Card(
          color: const Color(0xFF0E1620),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Travel Rewards',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        stats.level,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Points Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${stats.totalPoints} Points',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Streak: ${stats.currentStreak} days',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => _showRewardsDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Redeem', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Quick Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Trips', '${stats.tripsCompleted}', Icons.flight_takeoff),
                    _buildStatItem('Saved', '₹${stats.totalSaved.toInt()}', Icons.savings),
                    _buildStatItem('Shared', '${stats.tripsShared}', Icons.share),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn().slideY(begin: 0.2);
      },
    );
  }

  static Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepOrangeAccent, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  // Travel Analytics Dashboard
  static Widget buildAnalyticsDashboard() {
    return FutureBuilder<BudgetAnalytics>(
      future: AnalyticsService.getBudgetAnalytics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        
        final analytics = snapshot.data!;
        return Card(
          color: const Color(0xFF0E1620),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('Travel Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Spending Chart
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: analytics.categoryBreakdown.entries.map((entry) {
                        return PieChartSectionData(
                          value: entry.value,
                          title: entry.key,
                          color: _getCategoryColor(entry.key),
                          radius: 60,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Key Metrics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem('Total Spent', '₹${analytics.totalSpent.toInt()}'),
                    _buildMetricItem('Avg Trip', '₹${analytics.averageTripCost.toInt()}'),
                    _buildMetricItem('Savings', '₹${analytics.savingsOpportunities.fold(0.0, (sum, opp) => sum + opp.potentialSavings).toInt()}'),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn().slideX(begin: 0.3);
      },
    );
  }

  static Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  static Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'accommodation': return Colors.blue;
      case 'transport': return Colors.green;
      case 'food': return Colors.orange;
      case 'activities': return Colors.purple;
      default: return Colors.grey;
    }
  }

  // Community Stories Widget
  static Widget buildCommunityStories() {
    return FutureBuilder<List<TravelStory>>(
      future: CommunityService.getTravelStories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        
        final stories = snapshot.data!.take(5).toList();
        return Card(
          color: const Color(0xFF0E1620),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.purple),
                    const SizedBox(width: 8),
                    const Text('Travel Stories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showAllStories(context),
                      child: const Text('View All', style: TextStyle(color: Colors.purple)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: stories.length,
                    itemBuilder: (context, index) {
                      final story = stories[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          color: const Color(0xFF0B1220),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundImage: NetworkImage(story.authorAvatar),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        story.authorName,
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (story.isLive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 8)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  story.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Icon(Icons.favorite, color: Colors.red, size: 12),
                                    const SizedBox(width: 4),
                                    Text('${story.likes}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                    const SizedBox(width: 12),
                                    Icon(Icons.comment, color: Colors.blue, size: 12),
                                    const SizedBox(width: 4),
                                    Text('${story.comments}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn().slideY(begin: 0.3);
      },
    );
  }

  // Smart Packing Assistant
  static Widget buildPackingAssistant(String destination, DateTime startDate, DateTime endDate) {
    return Card(
      color: const Color(0xFF0E1620),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.luggage, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Smart Packing Assistant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _generatePackingList(destination, startDate, endDate),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Generate List'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      const Text('AI-Powered Suggestions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get personalized packing recommendations based on weather, activities, and destination culture.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.3);
  }

  // Carbon Footprint Tracker
  static Widget buildCarbonTracker() {
    return Card(
      color: const Color(0xFF0E1620),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Carbon Impact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Eco-Friendly', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('125 kg', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text('CO₂ Emissions', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('₹150', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                      const Text('Offset Cost', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () => _showCarbonDetails(),
              icon: const Icon(Icons.nature, size: 16),
              label: const Text('Offset Carbon Footprint'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  // Helper methods for dialogs and actions
  static void _showRewardsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0E1620),
        title: const Text('Redeem Rewards', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRewardOption('₹500 Travel Voucher', '1000 Points', Icons.card_giftcard),
            _buildRewardOption('Free Hotel Upgrade', '1500 Points', Icons.upgrade),
            _buildRewardOption('Airport Lounge Access', '800 Points', Icons.airline_seat_flat),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.deepOrangeAccent)),
          ),
        ],
      ),
    );
  }

  static Widget _buildRewardOption(String title, String cost, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(cost, style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: () {},
    );
  }

  static void _showAllStories(BuildContext context) {
    // Navigate to full stories page
    if (kDebugMode) debugPrint('Show all stories');
  }

  static void _generatePackingList(String destination, DateTime startDate, DateTime endDate) async {
    HapticFeedback.lightImpact();
    
    final packingList = await SmartFeaturesService.generatePackingList(
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      activities: ['sightseeing', 'photography'],
      weatherForecast: 'sunny',
    );
    
    if (kDebugMode) debugPrint('Generated packing list for $destination with ${packingList.items.length} items');
  }

  static void _showCarbonDetails() {
    if (kDebugMode) debugPrint('Carbon footprint details: Transport 85kg, Accommodation 30kg, Activities 10kg');
  }

  static Widget _buildCarbonBreakdown(String category, String amount, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(category, style: const TextStyle(color: Colors.white))),
          Text(amount, style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}