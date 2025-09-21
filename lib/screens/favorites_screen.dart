import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/user_models.dart';
import '../services/favorites_service.dart';
import '../main.dart';

class FavoritesScreen extends StatefulWidget {
  final List<ItineraryItem> favoriteItems;
  const FavoritesScreen({super.key, required this.favoriteItems});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  final FavoritesService _favoritesService = FavoritesService();
  List<SavedTrip> _favoriteTrips = [];
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Planning', 'Booked', 'Completed'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadFavorites();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadFavorites() async {
    setState(() {
      _favoriteTrips = widget.favoriteItems.map((item) => SavedTrip(
        id: item.id,
        userId: 'current_user', // Add required userId parameter
        title: item.title,
        destination: item.title,
        budget: item.approxCost.toDouble(),
        people: 2,
        themes: ['Activity'],
        status: TripStatus.planning,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(), // Add required updatedAt parameter
        isFavorite: true,
      )).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1722),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Favorites', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: _showSortOptions,
            icon: const Icon(Icons.sort, color: Colors.white70),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: _favoriteTrips.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = filter);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepOrangeAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.deepOrangeAccent : Colors.white24,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ).animate().scale(delay: (index * 100).ms);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: const Color(0xFF0F1722),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.deepOrangeAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 60,
                color: Colors.deepOrangeAccent,
              ),
            ).animate().scale(delay: 200.ms),
            const SizedBox(height: 24),
            const Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 8),
            const Text(
              'Start exploring and save your favorite trips',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.explore),
              label: const Text('Explore Destinations'),
            ).animate().scale(delay: 800.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    final filteredTrips = _getFilteredTrips();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTrips.length,
      itemBuilder: (context, index) {
        final trip = filteredTrips[index];
        return _buildTripCard(trip, index);
      },
    );
  }

  Widget _buildTripCard(SavedTrip trip, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A2332),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _openTripDetails(trip),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trip.destination,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _toggleFavorite(trip),
                    icon: Icon(
                      trip.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: trip.isFavorite ? Colors.red : Colors.white54,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white54),
                    color: const Color(0xFF0E1620),
                    onSelected: (value) => _handleMenuAction(value, trip),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, color: Colors.white70, size: 20),
                            SizedBox(width: 12),
                            Text('Share', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, color: Colors.white70, size: 20),
                            SizedBox(width: 12),
                            Text('Duplicate', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 12),
                            Text('Remove', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.calendar_today, _formatDateRange(trip)),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.people, '${trip.people} travelers'),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.account_balance_wallet, '₹${trip.budget.toInt()}'),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: trip.themes.map((theme) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepOrangeAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    theme,
                    style: const TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(trip.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(trip.status),
                      style: TextStyle(
                        color: _getStatusColor(trip.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Saved ${_formatDate(trip.createdAt)}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().slideX(begin: 0.3, delay: (index * 100).ms).fadeIn();
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1620),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  List<SavedTrip> _getFilteredTrips() {
    if (_selectedFilter == 'All') return _favoriteTrips;
    
    final statusMap = {
      'Planning': TripStatus.planning,
      'Booked': TripStatus.booked,
      'Completed': TripStatus.completed,
    };
    
    final targetStatus = statusMap[_selectedFilter];
    return _favoriteTrips.where((trip) => trip.status == targetStatus).toList();
  }

  String _formatDateRange(SavedTrip trip) {
    if (trip.startDate == null || trip.endDate == null) return 'Flexible';
    
    final start = DateFormat('MMM dd').format(trip.startDate!);
    final end = DateFormat('MMM dd').format(trip.endDate!);
    return '$start - $end';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'today';
    if (difference == 1) return 'yesterday';
    if (difference < 7) return '${difference}d ago';
    if (difference < 30) return '${(difference / 7).floor()}w ago';
    return DateFormat('MMM dd').format(date);
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.planning:
        return Colors.orange;
      case TripStatus.booked:
        return Colors.blue;
      case TripStatus.ongoing:
        return Colors.green;
      case TripStatus.completed:
        return Colors.purple;
      case TripStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(TripStatus status) {
    switch (status) {
      case TripStatus.planning:
        return 'Planning';
      case TripStatus.booked:
        return 'Booked';
      case TripStatus.ongoing:
        return 'Ongoing';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _toggleFavorite(SavedTrip trip) async {
    HapticFeedback.lightImpact();
    await _favoritesService.toggleFavorite(trip);
    setState(() {
      _favoriteTrips = _favoritesService.favoriteTrips;
    });
  }

  void _openTripDetails(SavedTrip trip) {
    // Navigate to trip details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${trip.title}...'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
    );
  }

  void _handleMenuAction(String action, SavedTrip trip) {
    switch (action) {
      case 'share':
        _shareTrip(trip);
        break;
      case 'duplicate':
        _duplicateTrip(trip);
        break;
      case 'delete':
        _removeFromFavorites(trip);
        break;
    }
  }

  void _shareTrip(SavedTrip trip) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${trip.title}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _duplicateTrip(SavedTrip trip) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duplicated ${trip.title}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _removeFromFavorites(SavedTrip trip) {
    _favoritesService.removeFromFavorites(trip.id);
    setState(() {
      _favoriteTrips = _favoritesService.favoriteTrips;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${trip.title} from favorites'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () => _favoritesService.addToFavorites(trip),
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E1620),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort by',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption('Date Created', Icons.access_time),
            _buildSortOption('Trip Date', Icons.calendar_today),
            _buildSortOption('Budget', Icons.account_balance_wallet),
            _buildSortOption('Destination', Icons.location_on),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        // Implement sorting logic
      },
    );
  }
}