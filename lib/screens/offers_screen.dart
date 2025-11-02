import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/footer_widget.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SharedAppBar(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF007BFF), Color(0xFF0056b3)],
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'Exclusive Offers & Deals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Save big on your next adventure',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.2,
                children: [
                  _buildOfferCard(
                    'Up to 20% OFF on Flights',
                    'Book domestic flights and save',
                    'FLIGHT20',
                    Colors.blue,
                  ),
                  _buildOfferCard(
                    'Flat ₹1000 OFF on Hotels',
                    'Use code on hotel bookings',
                    'HOTEL1000',
                    Colors.orange,
                  ),
                  _buildOfferCard(
                    'Holiday Packages from ₹9,999',
                    'Limited time offer',
                    'HOLIDAY99',
                    Colors.green,
                  ),
                  _buildOfferCard(
                    'Extra 10% Cashback',
                    'On all AI-generated trips',
                    'AICASH10',
                    Colors.purple,
                  ),
                  _buildOfferCard(
                    'Free Cancellation',
                    'Book now, decide later',
                    'FREECANCEL',
                    Colors.red,
                  ),
                  _buildOfferCard(
                    'Weekend Getaway Deals',
                    'Starting at ₹4,999',
                    'WEEKEND49',
                    Colors.teal,
                  ),
                ],
              ),
            ),
            const FooterWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(String title, String subtitle, String code, Color color) {
    return Builder(
      builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HOT DEAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color, style: BorderStyle.solid),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/booking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }
}
