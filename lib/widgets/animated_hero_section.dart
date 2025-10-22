import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'dart:ui';
import '../services/localization_service.dart';
import '../widgets/language_selector.dart';
import '../models/user_models.dart';
import '../services/web_auth_service.dart';

class AnimatedHeroSection extends StatefulWidget {
  final String destination;
  final Function(String) onDestinationChanged;
  final VoidCallback onPlanTrip;
  final double height;

  const AnimatedHeroSection({
    super.key,
    required this.destination,
    required this.onDestinationChanged,
    required this.onPlanTrip,
    this.height = 520,
  });

  @override
  State<AnimatedHeroSection> createState() => _AnimatedHeroSectionState();
}

class _AnimatedHeroSectionState extends State<AnimatedHeroSection>
    with TickerProviderStateMixin {
  late AnimationController _searchController;
  late AnimationController _cardController;
  late AnimationController _parallaxController;
  late Animation<double> _searchExpansion;
  late Animation<double> _cardScale;
  late Animation<Offset> _parallaxOffset;
  
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _searchTextController = TextEditingController();
  bool _isSearchFocused = false;
  bool _isCardHovered = false;
  bool _showSuggestions = false;
  
  final List<Map<String, dynamic>> _trendingPlaces = [
    {'name': 'Goa', 'tag': '🔥 Trending', 'subtitle': 'Beach paradise'},
    {'name': 'Kerala', 'tag': '⭐ Popular', 'subtitle': 'Backwaters & hills'},
    {'name': 'Rajasthan', 'tag': '🔥 Trending', 'subtitle': 'Royal heritage'},
    {'name': 'Himachal Pradesh', 'tag': '❄️ Winter special', 'subtitle': 'Mountain escape'},
    {'name': 'Mumbai', 'tag': '🏙️ City break', 'subtitle': 'Financial capital'},
    {'name': 'Delhi', 'tag': '🏛️ Heritage', 'subtitle': 'Historic capital'},
    {'name': 'Karnataka', 'tag': '🏛️ Temples', 'subtitle': 'Garden city & temples'},
    {'name': 'Tamil Nadu', 'tag': '🏛️ Heritage', 'subtitle': 'Temple trail & culture'},
    {'name': 'Uttarakhand', 'tag': '🏔️ Spiritual', 'subtitle': 'Himalayan pilgrimage'},
    {'name': 'Andaman', 'tag': '🏝️ Islands', 'subtitle': 'Tropical paradise'},
    {'name': 'Ladakh', 'tag': '🏔️ Adventure', 'subtitle': 'High altitude desert'},
    {'name': 'Assam', 'tag': '🌿 Nature', 'subtitle': 'Tea gardens & wildlife'},
  ];

  final List<Map<String, dynamic>> _destinationCards = [
    {
      'name': 'Goa',
      'image': 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=400&h=300&fit=crop',
      'gradient': [Colors.orange, Colors.deepOrange],
      'tag': 'Beach Paradise'
    },
    {
      'name': 'Kerala',
      'image': 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=400&h=300&fit=crop',
      'gradient': [Colors.green, Colors.teal],
      'tag': 'Backwaters'
    },
    {
      'name': 'Rajasthan',
      'image': 'https://images.unsplash.com/photo-1477587458883-47145ed94245?w=400&h=300&fit=crop',
      'gradient': [Colors.purple, Colors.pink],
      'tag': 'Royal Heritage'
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchTextController.text = widget.destination;
    _initializeAnimations();
    _setupListeners();
  }

  void _initializeAnimations() {
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _parallaxController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _searchExpansion = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeInOut,
    ));

    _cardScale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));

    _parallaxOffset = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.02, 0),
    ).animate(CurvedAnimation(
      parent: _parallaxController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupListeners() {
    _searchFocus.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocus.hasFocus;
        _showSuggestions = _searchFocus.hasFocus;
      });
      if (_searchFocus.hasFocus) {
        _searchController.forward();
        HapticFeedback.lightImpact();
      } else {
        _searchController.reverse();
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showSuggestions = false);
        });
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedHeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destination != widget.destination) {
      _searchTextController.text = widget.destination;
    }
  }

  void _showSignInDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      barrierLabel: 'Sign In',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1620),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.deepOrangeAccent, size: 20),
                    const SizedBox(width: 8),
                    const Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      
                      // Show loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signing in...'), backgroundColor: Colors.blue),
                      );
                      
                      try {
                        final user = await WebAuthService().signInWithGoogle();
                        if (user != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Welcome, ${user.displayName ?? user.email}!'), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sign in failed. Please try again.'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    splashColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.05),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/google_logo.png',
                            height: 20,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 20, color: Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cardController.dispose();
    _parallaxController.dispose();
    _searchFocus.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Animated Background with Parallax
          _buildAnimatedBackground(),
          
          // Gradient Overlay
          _buildGradientOverlay(),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  if (!_showSuggestions) Expanded(
                    child: _buildHeroContent(),
                  ),
                  const SizedBox(height: 8),
                  _buildMorphingSearchBar(),
                  if (_showSuggestions) Flexible(
                    child: _buildSearchSuggestions(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _parallaxOffset,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _parallaxOffset.value.dx * 50,
            _parallaxOffset.value.dy * 50,
          ),
          child: CachedNetworkImage(
            imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2000&auto=format&fit=crop',
            fit: BoxFit.cover,
            width: double.infinity,
            height: widget.height + 100,
            placeholder: (context, url) => Container(
              color: Colors.grey[800],
              child: const Center(
                child: CircularProgressIndicator(color: Colors.deepOrangeAccent),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.deepOrangeAccent.withOpacity(0.1),
            Colors.black.withOpacity(0.3),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        const Icon(Icons.travel_explore, color: Colors.white, size: 32)
            .animate()
            .rotate(duration: 2000.ms)
            .then()
            .shimmer(delay: 1000.ms),
        const SizedBox(width: 12),
        const Text(
          'AI Trip Planner',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
        const Spacer(),
        const LanguageSelector(),
        const SizedBox(width: 8),
        Consumer<firebase_auth.User?>(
          builder: (context, user, child) => user == null
            ? ElevatedButton.icon(
                onPressed: () {
                  // Show sign-in popup dialog
                  _showSignInDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.person, size: 16),
                label: const Text('Sign In', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user.photoURL != null)
                          CircleAvatar(
                            radius: 8,
                            backgroundImage: NetworkImage(user.photoURL!),
                          )
                        else
                          const Icon(Icons.person, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(user.displayName ?? user.email ?? 'User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await WebAuthService().signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signed out successfully!'), backgroundColor: Colors.orange),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(0, 28),
                    ),
                    icon: const Icon(Icons.logout, size: 12),
                    label: const Text('Sign Out', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text('4.8', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ).animate().scale(delay: 600.ms).shimmer(delay: 2000.ms),
      ],
    );
  }

  Widget _buildHeroContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LocalizationService>(
          builder: (context, localization, child) => Text(
            localization.getText('discover_trip'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
        
        const SizedBox(height: 8),
        
        Consumer<LocalizationService>(
          builder: (context, localization, child) => Text(
            localization.getText('ai_companion'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.3,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
        
        const SizedBox(height: 12),
        
        // Trust indicators with animated counters
        Flexible(
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildTrustBadge('25K+', 'Happy Travelers', Icons.people),
              _buildTrustBadge('₹45L+', 'Amount Saved', Icons.savings),
              _buildTrustBadge('247', 'Trips Planned Today', Icons.flight_takeoff),
            ],
          ).animate().fadeIn(delay: 1000.ms),
        ),
      ],
    );
  }

  Widget _buildTrustBadge(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.deepOrangeAccent, size: 16),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black87,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(delay: 200.ms).shimmer(delay: 3000.ms);
  }

  Widget _buildMorphingSearchBar() {
    return AnimatedBuilder(
      animation: _searchExpansion,
      builder: (context, child) {
        return Container(
            constraints: const BoxConstraints(
              minHeight: 65,
              maxHeight: 85,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(_isSearchFocused ? 0.2 : 0.1),
                  Colors.white.withOpacity(_isSearchFocused ? 0.1 : 0.05),
                ],
              ),
              border: Border.all(
                color: _isSearchFocused 
                    ? Colors.deepOrangeAccent.withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
                width: _isSearchFocused ? 2 : 1,
              ),
              boxShadow: _isSearchFocused ? [
                BoxShadow(
                  color: Colors.deepOrangeAccent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: _isSearchFocused 
                            ? Colors.deepOrangeAccent 
                            : Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchTextController,
                          focusNode: _searchFocus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textInputAction: TextInputAction.search,
                          onChanged: (value) {
                            setState(() {});
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              widget.onDestinationChanged(value);
                              _searchFocus.unfocus();
                              widget.onPlanTrip();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Where to? Goa, Kerala, Rajasthan...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildSearchButton(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

  Widget _buildSearchButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          if (_searchTextController.text.isNotEmpty) {
            widget.onDestinationChanged(_searchTextController.text);
          }
          widget.onPlanTrip();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 40,
            minWidth: 100,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.deepOrangeAccent, Colors.orange],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.deepOrangeAccent.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Builder(
                  builder: (context) => Text(
                    context.read<LocalizationService>().getText('plan_trip'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(delay: 100.ms).shimmer(delay: 2000.ms);
  }

  Widget _buildSearchSuggestions() {
    final searchQuery = _searchTextController.text.toLowerCase();
    final filteredPlaces = searchQuery.isEmpty 
        ? _trendingPlaces.take(6).toList()
        : _trendingPlaces.where((place) => 
            place['name'].toString().toLowerCase().contains(searchQuery) ||
            place['subtitle'].toString().toLowerCase().contains(searchQuery)
          ).toList();
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      searchQuery.isEmpty ? Icons.trending_up : Icons.search,
                      color: Colors.deepOrangeAccent, 
                      size: 16
                    ),
                    const SizedBox(width: 8),
                    Text(
                      searchQuery.isEmpty 
                          ? 'Trending destinations' 
                          : 'Search results (${filteredPlaces.length})',
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 14
                      )
                    ),
                  ],
                ),
              ),
              if (filteredPlaces.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No destinations found for "$searchQuery"',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredPlaces.length,
                    itemBuilder: (context, index) => _buildSuggestionItem(filteredPlaces[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1);
  }

  Widget _buildSuggestionItem(Map<String, dynamic> place) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          final selectedDestination = place['name'];
          setState(() {
            _searchTextController.text = selectedDestination;
          });
          widget.onDestinationChanged(selectedDestination);
          _searchFocus.unfocus();
          // Navigate to customize page immediately
          widget.onPlanTrip();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.place, color: Colors.deepOrangeAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            place['name'], 
                            style: const TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            place['tag'], 
                            style: const TextStyle(
                              color: Colors.deepOrangeAccent, 
                              fontSize: 9, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place['subtitle'], 
                      style: const TextStyle(
                        color: Colors.white70, 
                        fontSize: 11
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
            ],
          ),
        ),
      ),
    );
  }


}