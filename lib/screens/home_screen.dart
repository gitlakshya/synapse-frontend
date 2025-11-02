import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/trending_destinations_widget.dart';
import '../widgets/why_choose_us_widget.dart';
import '../widgets/footer_widget.dart';
import '../utils/responsive.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Responsive.isMobile(context) ? 40.0 : 60.0;
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SharedAppBar(),
            const HeroCarousel(),
            SizedBox(height: spacing),
            const TrendingDestinationsWidget(),
            SizedBox(height: spacing),
            const WhyChooseUs(),
            const FooterWidget(),
          ],
        ),
      ),
    );
  }
}
