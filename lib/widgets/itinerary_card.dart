import 'package:flutter/material.dart';
import '../utils/dummy_data.dart';
import '../utils/animations_helper.dart';

class ItineraryCard extends StatefulWidget {
  final int day;
  final String title;
  final List<Activity> activities;

  const ItineraryCard({super.key, required this.day, required this.title, required this.activities});

  @override
  State<ItineraryCard> createState() => _ItineraryCardState();
}

class _ItineraryCardState extends State<ItineraryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _isExpanded ? const Color(0xFF007BFF) : Colors.grey.shade300),
        boxShadow: _isExpanded ? [BoxShadow(color: const Color(0xFF007BFF).withOpacity(0.2), blurRadius: 8)] : [],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF007BFF), borderRadius: BorderRadius.circular(20)),
                    child: Text('Day ${widget.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF007BFF)),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            ...List.generate(
              widget.activities.length,
              (index) => StaggeredListAnimation(
                index: index,
                child: _buildActivityItem(widget.activities[index], index),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Activity activity, int index) {
    return _ActivityItem(key: ValueKey('activity_${widget.day}_$index'), activity: activity);
  }
}

class _ActivityItem extends StatelessWidget {
  final Activity activity;

  const _ActivityItem({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF666666)),
                    const SizedBox(width: 4),
                    Text(activity.time, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
                    const SizedBox(width: 12),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${activity.rating}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Text(activity.cost, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF007BFF), fontSize: 16)),
        ],
      ),
    );
  }
}
