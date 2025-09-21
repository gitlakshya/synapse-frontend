// Enhanced Booking and Payment Experience
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BookingImprovements {
  // Enhanced Booking Summary with Trust Indicators
  static Widget buildEnhancedBookingSummary({
    required Map<String, int> costs,
    required int total,
    required VoidCallback onBook,
  }) {
    return Card(
      color: Color(0xFF0E1620),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Trust Badge
            Row(
              children: [
                Text(
                  'Booking Summary',
                  style: TextStyle(
                    fontSize: 20,
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
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user, color: Colors.green, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Secure',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Cost Breakdown with Visual Indicators
            ...costs.entries.map((entry) => 
              _buildEnhancedCostRow(
                entry.key,
                entry.value,
                _getCostIcon(entry.key),
                _getCostColor(entry.key),
              )
            ).toList(),
            
            SizedBox(height: 16),
            Divider(color: Colors.white24),
            SizedBox(height: 16),
            
            // Total with Savings Indicator
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepOrangeAccent.withOpacity(0.1),
                    Colors.orange.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepOrangeAccent.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${total + 3200}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            '₹$total',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.savings, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'You saved ₹3,200 with AI optimization!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Enhanced Payment Methods
            Text(
              'Payment Methods',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            
            Row(
              children: [
                _buildPaymentMethod('UPI', Icons.account_balance_wallet, Colors.green, true),
                SizedBox(width: 12),
                _buildPaymentMethod('Card', Icons.credit_card, Colors.blue, false),
                SizedBox(width: 12),
                _buildPaymentMethod('Wallet', Icons.wallet, Colors.orange, false),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Add-ons
            _buildAddOnOption('Travel Insurance', '₹299', 'Recommended', Icons.security),
            SizedBox(height: 8),
            _buildAddOnOption('Priority Support', '₹199', 'Popular', Icons.support_agent),
            
            SizedBox(height: 24),
            
            // Book Button with Loading State
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Secure Payment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Trust Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTrustIndicator(Icons.security, 'SSL Secured'),
                SizedBox(width: 16),
                _buildTrustIndicator(Icons.verified, '100% Safe'),
                SizedBox(width: 16),
                _buildTrustIndicator(Icons.support, '24/7 Support'),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  static Widget _buildEnhancedCostRow(
    String category,
    int amount,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
              category,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            '₹$amount',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPaymentMethod(
    String name,
    IconData icon,
    Color color,
    bool isSelected,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isSelected)
              Container(
                margin: EdgeInsets.only(top: 4),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _buildAddOnOption(
    String title,
    String price,
    String badge,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrangeAccent, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: Colors.deepOrangeAccent,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  price,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: false,
            onChanged: (value) {},
            activeColor: Colors.deepOrangeAccent,
          ),
        ],
      ),
    );
  }

  static Widget _buildTrustIndicator(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.green, size: 12),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  static IconData _getCostIcon(String category) {
    switch (category.toLowerCase()) {
      case 'accommodation':
        return Icons.hotel;
      case 'transport':
        return Icons.directions_car;
      case 'experiences':
        return Icons.local_activity;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.attach_money;
    }
  }

  static Color _getCostColor(String category) {
    switch (category.toLowerCase()) {
      case 'accommodation':
        return Colors.blue;
      case 'transport':
        return Colors.green;
      case 'experiences':
        return Colors.purple;
      case 'food':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Enhanced Success Dialog
  static void showBookingSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF0E1620),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Animation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 40,
                ),
              ).animate().scale(delay: 200.ms),
              
              SizedBox(height: 20),
              
              Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 400.ms),
              
              SizedBox(height: 12),
              
              Text(
                'Your trip has been successfully booked.\nGet ready for an amazing adventure!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 600.ms),
              
              SizedBox(height: 20),
              
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepOrangeAccent.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Booking ID',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'TRP${DateTime.now().millisecondsSinceEpoch}',
                      style: TextStyle(
                        color: Colors.deepOrangeAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 800.ms),
              
              SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.deepOrangeAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(color: Colors.deepOrangeAccent),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}