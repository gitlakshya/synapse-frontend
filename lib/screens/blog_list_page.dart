import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/footer_widget.dart';

class BlogListPage extends StatelessWidget {
  const BlogListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SharedAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHero(context),
                  _buildBlogGrid(context),
                  const FooterWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          children: [
            Text('Travel Blog', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Text('Tips, guides, and inspiration for your next adventure', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogGrid(BuildContext context) {
    final blogs = [
      {'title': '10 Hidden Gems in Rajasthan', 'date': 'Dec 15, 2024', 'category': 'Destinations'},
      {'title': 'Budget Travel Tips for India', 'date': 'Dec 10, 2024', 'category': 'Tips'},
      {'title': 'Best Time to Visit Goa', 'date': 'Dec 5, 2024', 'category': 'Guides'},
      {'title': 'Solo Travel Safety Guide', 'date': 'Nov 28, 2024', 'category': 'Tips'},
      {'title': 'Kerala Backwaters Experience', 'date': 'Nov 20, 2024', 'category': 'Destinations'},
      {'title': 'Mountain Trekking Essentials', 'date': 'Nov 15, 2024', 'category': 'Adventure'},
    ];

    return Container(
      padding: const EdgeInsets.all(40),
      constraints: const BoxConstraints(maxWidth: 1200),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.2,
        ),
        itemCount: blogs.length,
        itemBuilder: (context, index) => _buildBlogCard(context, blogs[index]),
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, Map<String, String> blog) {
    return Card(
      child: InkWell(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening: ${blog['title']}')),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(blog['category']!, style: Theme.of(context).textTheme.bodySmall),
              ),
              const SizedBox(height: 16),
              Text(blog['title']!, style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Text(blog['date']!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
