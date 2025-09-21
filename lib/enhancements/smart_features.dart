// Smart Features and AI Integration
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SmartFeatures {
  // AI-Powered Budget Optimizer
  static Widget buildBudgetOptimizer({
    required double currentBudget,
    required Function(double) onBudgetChanged,
    required Map<String, double> breakdown,
  }) {
    return Card(
      color: Color(0xFF0E1620),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.deepOrangeAccent),
                SizedBox(width: 8),
                Text(
                  'AI Budget Optimizer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Save ₹3,200',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Smart Suggestions
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildOptimizationSuggestion(
                    'Switch to local transport',
                    'Save ₹1,500',
                    Icons.directions_bus,
                    Colors.blue,
                  ),
                  SizedBox(height: 8),
                  _buildOptimizationSuggestion(
                    'Book activities in advance',
                    'Save ₹800',
                    Icons.discount,
                    Colors.green,
                  ),
                  SizedBox(height: 8),
                  _buildOptimizationSuggestion(
                    'Try local restaurants',
                    'Save ₹900',
                    Icons.restaurant,
                    Colors.orange,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Budget Breakdown with AI Insights
            Text(
              'Optimized Breakdown',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            ...breakdown.entries.map((entry) => 
              _buildBudgetBreakdownRow(
                entry.key,
                entry.value,
                currentBudget,
                _getOptimizationStatus(entry.key),
              )
            ).toList(),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  static Widget _buildOptimizationSuggestion(
    String title,
    String savings,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        Text(
          savings,
          style: TextStyle(
            color: Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 8),
        Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 12),
      ],
    );
  }

  static Widget _buildBudgetBreakdownRow(
    String category,
    double amount,
    double total,
    String status,
  ) {
    final percentage = total > 0 ? (amount / total) : 0.0;
    final color = _getCategoryColor(category);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Expanded(child: Text(category, style: TextStyle(color: Colors.white))),
              Text(
                status,
                style: TextStyle(
                  color: status == 'Optimized' ? Colors.green : Colors.orange,
                  fontSize: 10,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '₹${amount.toInt()}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  // Real-time Weather Integration
  static Widget buildWeatherIntegration({
    required String location,
    required List<Map<String, dynamic>> forecast,
  }) {
    return Card(
      color: Color(0xFF0E1620),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Weather Forecast - $location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.length,
                itemBuilder: (context, index) {
                  final day = forecast[index];
                  return Container(
                    width: 80,
                    margin: EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Text(
                          day['day'],
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          day['emoji'],
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${day['temp']}°C',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (day['alert'] != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              day['alert'],
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Weather-based Recommendations
            if (_hasWeatherAlerts(forecast))
              Container(
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rain expected on Day 2. We\'ve added indoor alternatives to your itinerary.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  // Smart Recommendations Engine
  static Widget buildSmartRecommendations({
    required List<Map<String, dynamic>> recommendations,
  }) {
    return Card(
      color: Color(0xFF0E1620),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'AI Recommendations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Personalized',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...recommendations.map((rec) => 
              Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (rec['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        rec['icon'] as IconData,
                        color: rec['color'] as Color,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec['title'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            rec['description'],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 12),
                  ],
                ),
              )
            ).toList(),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  static Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'accommodation':
        return Colors.blue;
      case 'transport':
        return Colors.green;
      case 'food':
        return Colors.orange;
      case 'activities':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  static String _getOptimizationStatus(String category) {
    // Mock optimization status
    switch (category.toLowerCase()) {
      case 'accommodation':
        return 'Optimized';
      case 'transport':
        return 'Can Save';
      case 'food':
        return 'Optimized';
      case 'activities':
        return 'Can Save';
      default:
        return 'Good';
    }
  }

  static bool _hasWeatherAlerts(List<Map<String, dynamic>> forecast) {
    return forecast.any((day) => day['alert'] != null);
  }
}