// lib/main.dart
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'firebase_options.dart';
import 'services/web_auth_service.dart';
import 'services/chat_service.dart';
import 'services/api_service.dart';
import 'services/authenticated_http_client.dart';
import 'services/theme_service.dart';
import 'services/favorites_service.dart';
import 'config/api_config.dart';
import 'widgets/animated_hero_section.dart';
import 'widgets/interactive_map_widget.dart';
import 'screens/mock_booking_screen.dart';
import 'services/localization_service.dart';
import 'services/slider_visibility_service.dart';
import 'services/session_service.dart';
import 'screens/favorites_screen.dart';

class MapMarker {
  final LatLng position;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  MapMarker({
    required this.position,
    required this.icon,
    this.color = Colors.blue,
    this.onTap,
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase for web
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize web auth service
  await WebAuthService().initialize();
  
  // Initialize other services
  // Note: Push notifications removed for web-only deployment
  
  try {
    ApiService.instance.initialize();
  } catch (e) {
    debugPrint('API service failed: $e');
  }
  
  try {
    await SessionService().initialize();
  } catch (e) {
    debugPrint('Session service failed: $e');
  }
  
  runApp(const TripPlannerApp());
}

class TripPlannerApp extends StatelessWidget {
  const TripPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => ThemeService()),
        provider.ChangeNotifierProvider(create: (_) => LocalizationService()),
        provider.StreamProvider<firebase_auth.User?>(
          create: (_) => WebAuthService().userStream,
          initialData: null,
        ),
      ],
      child: provider.Consumer2<ThemeService, LocalizationService>(
        builder: (context, themeService, localizationService, child) {
          return MaterialApp(
            title: 'AI Trip Planner',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: ThemeService.lightTheme,
            darkTheme: ThemeService.darkTheme,
            themeMode: themeService.themeMode,
            home: const LandingShell(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0,
                ),
                child: Builder(
                  builder: (context) {
                    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                      return Container(
                        color: Colors.red,
                        child: const Center(
                          child: Text('Error', style: TextStyle(color: Colors.white)),
                        ),
                      );
                    };
                    return ResponsiveBreakpoints.builder(
                      child: child!,
                      breakpoints: [
                        const Breakpoint(start: 0, end: 450, name: MOBILE),
                        const Breakpoint(start: 451, end: 800, name: TABLET),
                        const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                      ],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Top-level shell with simple navigation between pages
class LandingShell extends StatefulWidget {
  const LandingShell({super.key});
  @override
  State<LandingShell> createState() => _LandingShellState();
}

class _OnboardingDialog extends StatefulWidget {
  final List<Map<String, String>> steps;
  final int initialStep;
  
  const _OnboardingDialog({required this.steps, required this.initialStep});
  
  @override
  State<_OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<_OnboardingDialog> with TickerProviderStateMixin {
  late int currentStep;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    currentStep = widget.initialStep;
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }
  
  void _nextStep() async {
    if (currentStep < widget.steps.length - 1) {
      _slideController.forward().then((_) {
        setState(() {
          currentStep++;
        });
        _slideController.reverse();
      });
    } else {
      // Call session API when user clicks 'Get Started'
      try {
        await SessionService().ensureValidSession();
        Navigator.pop(context);
      } catch (e) {
        debugPrint('Session creation failed: $e');
        Navigator.pop(context);
      }
    }
  }
  
  void _previousStep() {
    if (currentStep > 0) {
      _slideController.forward().then((_) {
        setState(() {
          currentStep--;
        });
        _slideController.reverse();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final step = widget.steps[currentStep];
    
    return Dialog(
      backgroundColor: const Color(0xFF0F1722),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_slideAnimation.value.dx * 50, 0),
              child: Opacity(
                opacity: 1 - _slideAnimation.value.dx.abs(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(step['icon']!, style: const TextStyle(fontSize: 60)),
                    const SizedBox(height: 24),
                    Text(
                      step['title']!,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      step['description']!,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.steps.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == currentStep ? Colors.deepOrangeAccent : Colors.white24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (currentStep > 0)
                          TextButton(
                            onPressed: _previousStep,
                            child: const Text('Previous', style: TextStyle(color: Colors.white70)),
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrangeAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(currentStep < widget.steps.length - 1 ? 'Next' : 'Get Started'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LandingShellState extends State<LandingShell> with TickerProviderStateMixin {
  final tripPrefs = TripPreferences();
  int page = 0;
  String selectedLanguage = 'English';
  late AnimationController _mainAnimationController; // Single controller for all animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isGeneratingItinerary = false;
  bool _showOnboarding = true;
  Map<String, dynamic>? _apiItineraryResponse; // Store the API response
  final List<TripPreferences> _undoStack = [];
  final List<TripPreferences> _redoStack = [];
  final List<ItineraryItem> _favoriteItems = [];
  
  // Advanced features - reduced timers
  Timer? _periodicUpdateTimer;
  UserProfile? _currentUserProfile;
  final AIRecommendationEngine _aiEngine = AIRecommendationEngine();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  
  void goTo(int p) {
    final user = provider.Provider.of<firebase_auth.User?>(context, listen: false);
    
    if ((p == 3 || p == 4) && user == null) {
      _showLoginPrompt();
      return;
    }
    
    // Check if destination is selected for customize and itinerary tabs
    if ((p == 1 || p == 2) && tripPrefs.destination.isEmpty) {
      _showDestinationRequiredDialog();
      return;
    }
    
    if (p == 2) {
      _saveState();
      _generateItinerary();
    } else if (p == 3 && user != null) {
      // Load favorites for the signed-in user
      _loadUserFavorites(user.uid);
      _mainAnimationController.forward().then((_) {
        setState(() => page = p);
        _mainAnimationController.reverse();
      });
    } else {
      _mainAnimationController.forward().then((_) {
        setState(() => page = p);
        _mainAnimationController.reverse();
      });
    }
  }
  
  void _loadUserFavorites(String userId) async {
    // Load favorites from service for the current user
    try {
      await FavoritesService().loadFavorites(userId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading favorites: $e');
    }
  }
  
  void _generateItinerary() {
    setState(() => _isGeneratingItinerary = true);
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isGeneratingItinerary = false;
          page = 2;
        });
        _mainAnimationController.reverse();
      }
    });
    
    _mainAnimationController.forward();
  }
  
  void _showLoginPrompt() {
    _showAuthDialog();
  }
  
  void _showDestinationRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0E1620),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            const Icon(Icons.location_on, color: Colors.deepOrangeAccent),
            const SizedBox(width: 8),
            Text('Destination Required', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Please select a destination from the search bar before customizing your trip or viewing the itinerary.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
            child: const Text('Got it!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _showAuthDialog() {
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
                    Text(context.read<LocalizationService>().getText('sign_in'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                        if (user != null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Welcome, ${user.displayName ?? user.email}!'), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
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
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.read<LocalizationService>().getText('continue_with_google'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
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
  void initState() {
    super.initState();
    // Single animation controller for better performance
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _checkFirstTimeUser();
    _initializeAdvancedFeatures();
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.03, 0),
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeInOutQuart,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeInOutQuart,
    ));

    if (_showOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startOnboarding());
    }
  }
  
  void _initializeAdvancedFeatures() {
    _loadUserProfile();
    _startPeriodicUpdates(); // Consolidated timer
    _initializeLocationServices();
    _setupNotifications();
  }
  
  void _loadUserProfile() async {
    // In real app, load from secure storage
    _currentUserProfile = UserProfile();
    tripPrefs.userProfile = _currentUserProfile;
  }
  
  void _startPeriodicUpdates() {
    // Consolidate all periodic updates into single timer for better performance
    _periodicUpdateTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _updatePrices();
      _updateRealTimeData();
    });
  }
  
  void _initializeLocationServices() async {
    await _locationService.initialize();
  }
  
  void _setupNotifications() {
    _notificationService.initialize();
  }
  
  void _updatePrices() {
    // Simulate dynamic pricing
    for (final alert in tripPrefs.priceAlerts) {
      final newPrice = alert.currentPrice * (0.9 + Random().nextDouble() * 0.2);
      if (newPrice <= alert.targetPrice && alert.isActive) {
        _notificationService.showPriceAlert(alert, newPrice);
      }
      alert.currentPrice = newPrice;
    }
  }
  
  void _updateRealTimeData() {
    // Update opening hours, availability, etc.
    if (mounted) {
      setState(() {
        // Trigger UI updates for real-time data
      });
    }
  }
  
  void _checkFirstTimeUser() {
    // In real app, check SharedPreferences
    _showOnboarding = true;
  }
  
  void _startOnboarding() {
    _showOnboardingStep(0);
  }
  
  void _showOnboardingStep(int step) {
    final steps = [
      {'title': 'Welcome to AI Trip Planner!', 'description': 'Plan amazing trips with AI-powered recommendations', 'icon': '🌟'},
      {'title': 'Choose Your Destination', 'description': 'Select from popular destinations or search for any place', 'icon': '🌍'},
      {'title': 'Customize Your Trip', 'description': 'Set budget, themes, and preferences for personalized planning', 'icon': '⚙️'},
      {'title': 'Get Smart Itinerary', 'description': 'AI generates optimized daily plans with activities and costs', 'icon': '📅'},
      {'title': 'Collaborate & Share', 'description': 'Invite friends and share your amazing travel plans', 'icon': '🤝'},
    ];
    
    if (step >= steps.length) {
      setState(() => _showOnboarding = false);
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => _OnboardingDialog(steps: steps, initialStep: step),
    );
  }
  
  void _saveState() {
    _undoStack.add(TripPreferences.copy(tripPrefs));
    if (_undoStack.length > 10) _undoStack.removeAt(0);
    _redoStack.clear();
  }
  
  void _undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(TripPreferences.copy(tripPrefs));
      final previous = _undoStack.removeLast();
      setState(() {
        tripPrefs.copyFrom(previous);
      });
    }
  }
  
  void _redo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(TripPreferences.copy(tripPrefs));
      final next = _redoStack.removeLast();
      setState(() {
        tripPrefs.copyFrom(next);
      });
    }
  }
  
  void _toggleFavorite(ItineraryItem item) {
    setState(() {
      if (_favoriteItems.any((fav) => fav.id == item.id)) {
        _favoriteItems.removeWhere((fav) => fav.id == item.id);
      } else {
        _favoriteItems.add(item);
      }
    });
  }
  
  bool _isFavorite(ItineraryItem item) {
    return _favoriteItems.any((fav) => fav.id == item.id);
  }
  
  @override
  void dispose() {
    _mainAnimationController.dispose();
    _periodicUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (page) {
      case 1:
        body = CustomizationPage(
          prefs: tripPrefs,
          onNext: () => goTo(2),
          onBack: () => goTo(0),
          onApiResponse: (response) => setState(() => _apiItineraryResponse = response),
        );
        break;
      case 2:
        if (_isGeneratingItinerary) {
          body = const LoadingScreen();
        } else {
          body = ItineraryPage(
            prefs: tripPrefs,
            apiResponse: _apiItineraryResponse, // Pass the API response
            onBook: () => _openBookingUrl(),
            onBack: () => goTo(1),
            onUndo: _undoStack.isNotEmpty ? _undo : null,
            onRedo: _redoStack.isNotEmpty ? _redo : null,
            aiEngine: _aiEngine,
            locationService: _locationService,
            onToggleFavorite: _toggleFavorite,
            isFavorite: _isFavorite,
          );
        }
        break;
      case 3:
        body = FavoritesScreen(favoriteItems: _favoriteItems);
        break;
      case 4:
        body = const AIAssistant();
        break;
      default:
        body = provider.Consumer<firebase_auth.User?>(
          builder: (context, user, child) => LandingPage(
            prefs: tripPrefs,
            onCustomize: () => goTo(1),
            user: user,
          ),
        );
    }

    return Scaffold(
      body: RepaintBoundary( // Add RepaintBoundary for better performance
        child: AnimatedBuilder(
          animation: _mainAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: body,
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: RepaintBoundary( // Add RepaintBoundary
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0F1722),
          selectedItemColor: Colors.deepOrangeAccent,
          unselectedItemColor: Colors.white54,
          currentIndex: page,
          onTap: (index) {
            if (index != page) {
              HapticFeedback.lightImpact();
              goTo(index);
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: context.read<LocalizationService>().getText('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.tune),
              label: context.read<LocalizationService>().getText('customize'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map),
              label: context.read<LocalizationService>().getText('itinerary'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.smart_toy),
              label: context.read<LocalizationService>().getText('ai_assistant'),
            ),
          ],
        ),
      ),
      floatingActionButton: (page == 3 || page == 4) ? null : RepaintBoundary(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: 'share',
              backgroundColor: Colors.green,
              onPressed: () {
                HapticFeedback.lightImpact();
                _showShareDialog();
              },
              child: const Icon(Icons.share),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'ai_chat',
              backgroundColor: Colors.deepOrangeAccent,
              onPressed: () {
                HapticFeedback.mediumImpact();
                goTo(4);
              },
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showShareDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E1620),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share Your Itinerary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _shareOption(Icons.link, 'Copy Link', Colors.blue, () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard!'), backgroundColor: Colors.green)
                  );
                }),
                _shareOption(Icons.picture_as_pdf, 'PDF', Colors.red, () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF generated!'), backgroundColor: Colors.green)
                  );
                }),
                _shareOption(Icons.message, 'WhatsApp', Colors.green, () {
                  Navigator.pop(context);
                  Share.share('Check out my amazing trip itinerary!');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _shareOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.05),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _openBookingUrl() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MockBookingScreen(tripPrefs: tripPrefs)),
    );
  }
  

}

/// ---------------------- Models ----------------------
class UserProfile {
  String id = '';
  String name = '';
  String email = '';
  List<String> dietaryRestrictions = [];
  List<String> accessibilityNeeds = [];
  String travelStyle = 'Balanced'; // Luxury, Budget, Adventure, Balanced
  List<String> favoriteDestinations = [];
  Map<String, double> activityPreferences = {};
  List<TripHistory> pastTrips = [];
  DateTime lastActive = DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'dietaryRestrictions': dietaryRestrictions,
    'accessibilityNeeds': accessibilityNeeds,
    'travelStyle': travelStyle,
    'favoriteDestinations': favoriteDestinations,
    'activityPreferences': activityPreferences,
    'lastActive': lastActive.toIso8601String(),
  };
}

class TripHistory {
  String destination;
  DateTime date;
  double rating;
  List<String> likedActivities;
  List<String> dislikedActivities;
  
  TripHistory({
    required this.destination,
    required this.date,
    required this.rating,
    required this.likedActivities,
    required this.dislikedActivities,
  });
}

class PriceAlert {
  String activityId;
  double targetPrice;
  double currentPrice;
  bool isActive;
  DateTime created;
  
  PriceAlert({
    required this.activityId,
    required this.targetPrice,
    required this.currentPrice,
    this.isActive = true,
    required this.created,
  });
}

class ExpenseTracker {
  Map<String, double> categorySpent = {};
  Map<String, double> categoryBudget = {};
  List<Expense> expenses = [];
  
  double get totalSpent => expenses.fold(0, (sum, e) => sum + e.amount);
  double get totalBudget => categoryBudget.values.fold(0, (sum, b) => sum + b);
  double get remainingBudget => totalBudget - totalSpent;
}

class Expense {
  String id;
  String category;
  double amount;
  String description;
  DateTime date;
  String location;
  
  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    required this.location,
  });
}

class TripPreferences {
  String destination = '';
  DateTimeRange? dates;
  double budget = 50000;
  Set<String> themes = {'heritage', 'food'};
  int people = 2;
  UserProfile? userProfile;
  ExpenseTracker expenseTracker = ExpenseTracker();
  List<PriceAlert> priceAlerts = [];
  
  static TripPreferences copy(TripPreferences other) {
    final copy = TripPreferences();
    copy.destination = other.destination;
    copy.dates = other.dates;
    copy.budget = other.budget;
    copy.themes = Set.from(other.themes);
    copy.people = other.people;
    copy.userProfile = other.userProfile;
    return copy;
  }
  
  void copyFrom(TripPreferences other) {
    destination = other.destination;
    dates = other.dates;
    budget = other.budget;
    themes = Set.from(other.themes);
    people = other.people;
    userProfile = other.userProfile;
  }
}

/// ---------------------- Landing Page ----------------------
class LandingPage extends StatefulWidget {
  final TripPreferences prefs;
  final VoidCallback onCustomize;
  final firebase_auth.User? user;
  const LandingPage({super.key, required this.prefs, required this.onCustomize, this.user});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  String selectedLanguage = 'English';
  late AnimationController _heroAnimationController;
  late AnimationController _statsController;
  late Timer _testimonialTimer;
  late PageController _testimonialController;
  int _currentTestimonialIndex = 0;
  int _hoveredCardIndex = -1;
  
  
  @override
  void initState() {
    super.initState();
    _heroAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _statsController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    
    _testimonialController = PageController(viewportFraction: 0.85);
    
    _startTestimonialTimer();
  }

  
  void _startTestimonialTimer() {
    _testimonialTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _currentTestimonialIndex = (_currentTestimonialIndex + 1) % 3;
        _testimonialController.animateToPage(
          _currentTestimonialIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }
  
  @override
  void dispose() {
    _heroAnimationController.dispose();
    _statsController.dispose();
    _testimonialTimer.cancel();
    _testimonialController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final heroHeight = (size.height * 0.55).clamp(320.0, 520.0);

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              AnimatedHeroSection(
                destination: widget.prefs.destination,
                onDestinationChanged: (value) {
                  setState(() {
                    widget.prefs.destination = value;
                  });
                },
                onPlanTrip: widget.onCustomize,
                height: heroHeight,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildPopularDestinations(),
          const SizedBox(height: 24),
          _buildTripTypeFilters(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return Column(
                        children: [
                          _highlightCard(Icons.monetization_on, 'Transparent Costs', 'See full breakdown of stay, travel, food, experiences'),
                          const SizedBox(height: 12),
                          _highlightCard(Icons.schedule, 'Smart Adjust', 'Real-time plan updates for weather & delays'),
                          const SizedBox(height: 12),
                          _highlightCard(Icons.language, 'Multilingual', 'Assist in multiple Indian languages'),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          _highlightCard(Icons.monetization_on, 'Transparent Costs', 'See full breakdown of stay, travel, food, experiences'),
                          const SizedBox(width: 12),
                          _highlightCard(Icons.schedule, 'Smart Adjust', 'Real-time plan updates for weather & delays'),
                          const SizedBox(width: 12),
                          _highlightCard(Icons.language, 'Multilingual', 'Assist in multiple Indian languages'),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 18),
                _testimonialsCarousel(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _highlightCard(IconData icon, String title, String subtitle) {
    return Flexible(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showFeatureDialog(title, subtitle),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Card(
              color: const Color(0xFF0E1620),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showFeatureDialog(title, subtitle),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 80),
                  padding: const EdgeInsets.all(12.0),
                  child: Row(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Icon(icon, color: Colors.deepOrangeAccent, size: 20)
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]
                      )
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white38,
                      size: 12
                    )
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFeatureDialog(String title, String subtitle) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: title,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            )),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
        backgroundColor: const Color(0xFF0E1620),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              title == 'Transparent Costs' ? Icons.monetization_on :
              title == 'Smart Adjust' ? Icons.schedule : Icons.language,
              color: Colors.deepOrangeAccent
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white))
          ]
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            if (title == 'Transparent Costs') ..._getCostFeatures(),
            if (title == 'Smart Adjust') ..._getSmartFeatures(),
            if (title == 'Multilingual') ..._getLanguageFeatures(),
          ]
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.deepOrangeAccent))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
            onPressed: () {
              Navigator.pop(context);
              if (widget.prefs.destination.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a destination first!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else {
                widget.onCustomize();
              }
            },
            child: const Text('Try Now', style: TextStyle(color: Colors.white))
          )
        ]
      )
    );
  }

  List<Widget> _getCostFeatures() {
    return [
      const Text('• Accommodation breakdown', style: TextStyle(color: Colors.white70)),
      const Text('• Transport costs', style: TextStyle(color: Colors.white70)),
      const Text('• Food & dining expenses', style: TextStyle(color: Colors.white70)),
      const Text('• Activity & experience fees', style: TextStyle(color: Colors.white70)),
      const Text('• No hidden charges', style: TextStyle(color: Colors.white70)),
    ];
  }

  List<Widget> _getSmartFeatures() {
    return [
      const Text('• Weather-based adjustments', style: TextStyle(color: Colors.white70)),
      const Text('• Traffic & delay updates', style: TextStyle(color: Colors.white70)),
      const Text('• Alternative suggestions', style: TextStyle(color: Colors.white70)),
      const Text('• Real-time notifications', style: TextStyle(color: Colors.white70)),
    ];
  }

  List<Widget> _getLanguageFeatures() {
    return [
      const Text('• Hindi support', style: TextStyle(color: Colors.white70)),
      const Text('• Regional languages', style: TextStyle(color: Colors.white70)),
      const Text('• Voice assistance', style: TextStyle(color: Colors.white70)),
      const Text('• Local guide communication', style: TextStyle(color: Colors.white70)),
    ];
  }

  void _configureTripType(String tripType) {
    final random = Random();
    
    setState(() {
      switch (tripType) {
        case 'Solo Travel':
          widget.prefs.people = 1;
          widget.prefs.budget = (15000 + random.nextInt(25000)).toDouble();
          widget.prefs.themes = {'Adventure', 'Heritage'};
          break;
        case 'Family':
          widget.prefs.people = 3 + random.nextInt(3);
          widget.prefs.budget = (40000 + random.nextInt(60000)).toDouble();
          widget.prefs.themes = {'Relaxation', 'Heritage'};
          break;
        case 'Honeymoon':
          widget.prefs.people = 2;
          widget.prefs.budget = (50000 + random.nextInt(100000)).toDouble();
          widget.prefs.themes = {'Relaxation', 'Food'};
          break;
        case 'Business':
          widget.prefs.people = 1 + random.nextInt(2);
          widget.prefs.budget = (25000 + random.nextInt(50000)).toDouble();
          widget.prefs.themes = {'Heritage', 'Food'};
          break;
      }
    });
    
    widget.onCustomize();
  }

  Widget _testimonialsCarousel() {
    final quotes = [
      '"Planned our honeymoon in under 2 minutes — flawless!" — A.',
      '"Saved us ₹8,000 vs booking separately" — R.',
      '"Local guides recommended hidden gems we loved." — S.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                context.read<LocalizationService>().getText('testimonials'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_stories, color: Colors.white54, size: 14),
                const SizedBox(width: 2),
                const Text('Auto-rolling', style: TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: PageView.builder(
            itemCount: quotes.length,
            controller: _testimonialController,
            itemBuilder: (_, i) => Container(
              margin: const EdgeInsets.only(right: 8),
              child: Card(
                color: const Color(0xFF0E1620),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          quotes[i],
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) => 
                          const Icon(Icons.star, color: Colors.amber, size: 10)
                        ),
                      ),
                    ],
                  )
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularDestinations() {
    final destinations = [
      {
        'name': 'Goa', 
        'image': 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=400&h=300&fit=crop', 
        'startingPrice': 15000,
        'tag': 'Beach Paradise',
        'trending': true
      },
      {
        'name': 'Kerala', 
        'image': 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=400&h=300&fit=crop', 
        'startingPrice': 18000,
        'tag': 'Backwaters',
        'trending': false
      },
      {
        'name': 'Rajasthan', 
        'image': 'https://images.unsplash.com/photo-1477587458883-47145ed94245?w=400&h=300&fit=crop', 
        'startingPrice': 22000,
        'tag': 'Royal Heritage',
        'trending': true
      },
      {
        'name': 'Mumbai', 
        'image': 'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?w=400&h=300&fit=crop', 
        'startingPrice': 12000,
        'tag': 'City of Dreams',
        'trending': false
      },
      {
        'name': 'Delhi', 
        'image': 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=400&h=300&fit=crop', 
        'startingPrice': 14000,
        'tag': 'Historic Capital',
        'trending': false
      },
      {
        'name': 'Himachal', 
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop', 
        'startingPrice': 20000,
        'tag': 'Mountain Escape',
        'trending': true
      },
      {
        'name': 'Uttarakhand', 
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400&h=300&fit=crop', 
        'startingPrice': 16000,
        'tag': 'Spiritual Journey',
        'trending': false
      },
      {
        'name': 'Andaman', 
        'image': 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop', 
        'startingPrice': 35000,
        'tag': 'Tropical Paradise',
        'trending': true
      },
      {
        'name': 'Ladakh', 
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop', 
        'startingPrice': 28000,
        'tag': 'High Altitude Desert',
        'trending': true
      },
      {
        'name': 'Tamil Nadu', 
        'image': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=400&h=300&fit=crop', 
        'startingPrice': 13000,
        'tag': 'Temple Trail',
        'trending': false
      },
      {
        'name': 'Karnataka', 
        'image': 'https://images.unsplash.com/photo-1596176530529-78163a4f7af2?w=400&h=300&fit=crop', 
        'startingPrice': 17000,
        'tag': 'Garden City',
        'trending': false
      },
      {
        'name': 'Agra', 
        'image': 'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=400&h=300&fit=crop', 
        'startingPrice': 11000,
        'tag': 'Taj Mahal Wonder',
        'trending': true
      },
      {
        'name': 'Assam', 
        'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop', 
        'startingPrice': 19000,
        'tag': 'Tea Gardens',
        'trending': false
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              provider.Consumer<LocalizationService>(
                builder: (context, localization, child) => Text(
                  localization.getText('popular_destinations'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const Spacer(),
              provider.Consumer<LocalizationService>(
                builder: (context, localization, child) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepOrangeAccent.withOpacity(0.2), Colors.deepOrangeAccent.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepOrangeAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up, color: Colors.deepOrangeAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '247 ${localization.getText('trips_planned_today')}',
                        style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final dest = destinations[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _hoveredCardIndex = index),
                  onExit: (_) => setState(() => _hoveredCardIndex = -1),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        widget.prefs.destination = dest['name']! as String;
                        widget.prefs.budget = (dest['startingPrice'] as int).toDouble();
                      });
                      widget.onCustomize();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _hoveredCardIndex == index ? [
                          BoxShadow(
                            color: Colors.deepOrangeAccent.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 50,
                            spreadRadius: -5,
                            offset: const Offset(0, 15),
                          ),
                        ] : null,
                      ),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: dest['image']! as String,
                          height: 220,
                          width: 160,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[800]!,
                            highlightColor: Colors.grey[600]!,
                            child: Container(height: 220, color: Colors.grey[800]),
                          ),
                        ),
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.8), 
                                Colors.transparent,
                                Colors.black.withOpacity(0.3)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: const [0.0, 0.6, 1.0],
                            ),
                          ),
                        ),
                        if (dest['trending'] == true)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.trending_up, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text('Trending', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dest['name']! as String,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dest['tag']! as String,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Starting ₹${(dest['startingPrice'] as int).toString()}',
                                  style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 14, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      ),
                    ),
                  ),
                ),
                ).animate().fadeIn(delay: (index * 200).ms).slideX(begin: 0.3),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTripTypeFilters() {
    final tripTypes = [
      {'name': context.read<LocalizationService>().getText('solo_travel'), 'icon': Icons.person, 'color': Colors.blue},
      {'name': context.read<LocalizationService>().getText('family'), 'icon': Icons.family_restroom, 'color': Colors.green},
      {'name': context.read<LocalizationService>().getText('honeymoon'), 'icon': Icons.favorite, 'color': Colors.pink},
      {'name': context.read<LocalizationService>().getText('business'), 'icon': Icons.business_center, 'color': Colors.orange},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.read<LocalizationService>().getText('trip_type'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            children: tripTypes.map((type) => 
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => _configureTripType(type['name'] as String),
                    child: Card(
                      color: const Color(0xFF0E1620),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Icon(type['icon'] as IconData, color: type['color'] as Color, size: 24),
                            const SizedBox(height: 8),
                            Text(
                              type['name'] as String,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ).toList(),
          ),
        ],
      ),
    );
  }
}

/// ---------------------- Customization Dashboard ----------------------
class CustomizationPage extends StatefulWidget {
  final TripPreferences prefs;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onApiResponse; // Add callback for API response
  const CustomizationPage({super.key, required this.prefs, required this.onNext, required this.onBack, required this.onApiResponse});

  @override
  State<CustomizationPage> createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> with TickerProviderStateMixin {
  double budgetLocal = 50000;
  int nights = 3;
  late AnimationController _slideController;
  late AnimationController _budgetController;
  final TextEditingController _specialRequirementsController = TextEditingController();
  late StreamSubscription _visibilitySubscription;
  bool _showAllSliders = true;
  
  final Map<String, double> _themeIntensity = {
    'nature': 50.0,
    'nightlife': 30.0,
    'adventure': 50.0,
    'leisure': 40.0,
    'heritage': 70.0,
    'culture': 60.0,
    'food': 80.0,
    'shopping': 50.0,
    'unexplored': 60.0,
  };
  
  Map<String, double> _budgetBreakdown = {};
  

  
  final List<_ThemeCardData> themeCards = [
    _ThemeCardData('nature', Icons.nature, 'Nature'),
    _ThemeCardData('nightlife', Icons.nightlife, 'Nightlife'),
    _ThemeCardData('adventure', Icons.terrain, 'Adventure'),
    _ThemeCardData('leisure', Icons.beach_access, 'Leisure'),
    _ThemeCardData('heritage', Icons.account_balance, 'Heritage'),
    _ThemeCardData('culture', Icons.museum, 'Culture'),
    _ThemeCardData('food', Icons.restaurant, 'Food'),
    _ThemeCardData('shopping', Icons.shopping_bag, 'Shopping'),
    _ThemeCardData('unexplored', Icons.explore, 'Unexplored'),
  ];

  @override
  void initState() {
    super.initState();
    budgetLocal = widget.prefs.budget;
    _showAllSliders = SliderVisibilityService().showAllSliders;
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _budgetController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController.forward();
    _budgetController.forward();
    
    // Listen for slider visibility changes
    _visibilitySubscription = SliderVisibilityService().visibilityStream.listen((showAll) {
      if (mounted) {
        setState(() {
          _showAllSliders = showAll;
        });
      }
    });
  }
  

  
  @override
  void dispose() {
    _slideController.dispose();
    _budgetController.dispose();
    _specialRequirementsController.dispose();
    _visibilitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _topBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  provider.Consumer<LocalizationService>(
          builder: (context, localization, child) => Text(
            localization.getText('customize_trip'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - Budget & Group
                      Expanded(
                        flex: 5,
                        child: Card(
                          color: const Color(0xFF0E1620),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                provider.Consumer<LocalizationService>(
                                  builder: (context, localization, child) => Text(
                                    localization.getText('budget_group'),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                provider.Consumer<LocalizationService>(
                                  builder: (context, localization, child) => Text(
                                    '${localization.getText('budget')}: ₹${budgetLocal.toInt()}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  width: 400,
                                  child: Slider(
                                    value: budgetLocal,
                                    min: 1000,
                                    max: 100000,
                                    divisions: ((100000 - 1000) / 1000).round(),
                                    activeColor: Colors.deepOrangeAccent,
                                    onChanged: (v) {
                                      HapticFeedback.selectionClick();

                                      setState(() {
                                        budgetLocal = v;
                                        widget.prefs.budget = v;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('${widget.prefs.people} people • $nights nights', style: const TextStyle(color: Colors.white70)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Text('Group Size: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: widget.prefs.people > 1 ? () => setState(() {
                                            widget.prefs.people--;
                                          }) : null,
                                          icon: const Icon(Icons.remove_circle_outline),
                                        ),
                                        Text('${widget.prefs.people}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        IconButton(
                                          onPressed: widget.prefs.people < 10 ? () => setState(() {
                                            widget.prefs.people++;
                                          }) : null,
                                          icon: const Icon(Icons.add_circle_outline),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (_showAllSliders) _buildBudgetBreakdownChart(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Right side - Themes
                      Expanded(
                        flex: 5,
                        child: Card(
                          color: const Color(0xFF0E1620),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Trip themes & intensity', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: themeCards.take(5).map((t) {
                                        final selected = widget.prefs.themes.contains(t.title);
                                        return InkWell(
                                          onTap: () => setState(() {
                                            if (selected) {
                                              widget.prefs.themes.remove(t.title);
                                            } else {
                                              widget.prefs.themes.add(t.title);
                                            }
                                          }),
                                          child: Container(
                                            width: 80,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: selected ? Colors.deepOrangeAccent.withOpacity(0.15) : const Color(0xFF0B1220),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: selected ? Colors.deepOrangeAccent : Colors.white10),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(t.icon, size: 20, color: selected ? Colors.deepOrangeAccent : Colors.white70),
                                                const SizedBox(height: 4),
                                                Text(t.displayName, style: TextStyle(color: selected ? Colors.white : Colors.white70, fontSize: 10)),
                                              ]
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: themeCards.skip(5).map((t) {
                                        final selected = widget.prefs.themes.contains(t.title);
                                        return InkWell(
                                          onTap: () => setState(() {
                                            if (selected) {
                                              widget.prefs.themes.remove(t.title);
                                            } else {
                                              widget.prefs.themes.add(t.title);
                                            }
                                          }),
                                          child: Container(
                                            width: 80,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: selected ? Colors.deepOrangeAccent.withOpacity(0.15) : const Color(0xFF0B1220),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: selected ? Colors.deepOrangeAccent : Colors.white10),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(t.icon, size: 20, color: selected ? Colors.deepOrangeAccent : Colors.white70),
                                                const SizedBox(height: 4),
                                                Text(t.displayName, style: TextStyle(color: selected ? Colors.white : Colors.white70, fontSize: 10)),
                                              ]
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (_showAllSliders) _buildThemeIntensitySliders(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSpecialRequirements(),
                  const SizedBox(height: 12),
                  const Text('Trip duration', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickDates(context), 
                      icon: const Icon(Icons.calendar_month), 
                      label: const Text('Pick dates')
                    ),
                    const SizedBox(width: 12),
                    Text(widget.prefs.dates == null ? 'Flexible' : '${DateFormat.yMMMd().format(widget.prefs.dates!.start)} → ${DateFormat.yMMMd().format(widget.prefs.dates!.end)}'),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onBack();
                      }, 
                      child: Text(context.read<LocalizationService>().getText('back'))
                    ).animate().slideX(begin: -0.3, delay: 400.ms),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 250,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          widget.prefs.budget = budgetLocal;
                          
                          // Prepare trip data for API call
                          final tripData = {
                            'destination': widget.prefs.destination,
                            'budget': budgetLocal.toInt(),
                            'people': widget.prefs.people,
                            'themes': widget.prefs.themes.toList(),
                            'themeIntensity': Map.fromEntries(
                              _themeIntensity.entries
                                .where((entry) => widget.prefs.themes.contains(entry.key))
                                .map((entry) => MapEntry(entry.key, double.parse(entry.value.toStringAsFixed(2))))
                            ),
                            'specialRequirements': _specialRequirementsController.text,
                            'dates': widget.prefs.dates != null ? {
                              'start': widget.prefs.dates!.start.toIso8601String(),
                              'end': widget.prefs.dates!.end.toIso8601String(),
                            } : null,
                          };
                          
                          try {
                            // Show loading state
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Generating itinerary...'),
                                  ],
                                ),
                                backgroundColor: Colors.deepOrangeAccent,
                                duration: Duration(seconds: 130), // Slightly longer than API timeout
                              ),
                            );
                            
                            // Make API call
                            final apiService = ApiService.instance;
                            final response = await apiService.planTrip(tripData);
                            
                            // Hide loading snackbar
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            
                            if (response.success) {
                              // Pass the API response to parent widget
                              widget.onApiResponse(response.data ?? {});
                              
                              // Success - proceed to itinerary page
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Itinerary generated successfully!'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              widget.onNext();
                            } else {
                              // Error - show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to generate itinerary: ${response.error}'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          } catch (e) {
                            // Hide loading snackbar
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Network error: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 8,
                        ),
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: Text(
                          context.read<LocalizationService>().getText('generate_itinerary'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ).animate().slideX(begin: 0.3, delay: 400.ms).shimmer(delay: 1000.ms),
                    ),
                  ])
                ],
              ),
            ),
          ),
          // Add bottom padding to prevent button from being hidden behind FABs
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  PreferredSizeWidget _topBar() => AppBar(title: const Text('Customize Trip'), backgroundColor: Colors.transparent, elevation: 0);

  Widget _buildBudgetBreakdownChart() {
    _budgetBreakdown = _calculateBudgetBreakdown();
    return Card(
      color: const Color(0xFF0B1220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.read<LocalizationService>().getText('budget_breakdown'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ..._budgetBreakdown.entries.map((entry) => _buildBudgetSlider(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSlider(String category, double amount) {
    final colors = {
      'Accommodation': Colors.blue,
      'Transport': Colors.green,
      'Food': Colors.orange,
      'Activities': Colors.purple,
      'Shopping': Colors.pink,
    };
    final color = colors[category] ?? Colors.grey;
    final minAmount = budgetLocal * 0.05;
    final maxAmount = budgetLocal * 0.8;
    final clampedAmount = amount.clamp(minAmount, maxAmount);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Text('₹${clampedAmount.toInt()}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: color.withOpacity(0.3),
              trackHeight: 6,
            ),
            child: SizedBox(
              width: 290,
              child: Slider(
                value: clampedAmount,
                min: minAmount,
                max: maxAmount,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  if (mounted) {
                    setState(() {
                      _budgetBreakdown[category] = value;
                      _updateBudgetFromBreakdown();
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _updateBudgetFromBreakdown() {
    final total = _budgetBreakdown.values.fold(0.0, (sum, value) => sum + value);
    if (total > 0 && mounted) {
      budgetLocal = total;
      widget.prefs.budget = total;
    }
  }

  Map<String, double> _calculateBudgetBreakdown() {
    // Base percentages
    double accommodationPct = 0.4;
    double transportPct = 0.25;
    double foodPct = 0.2;
    double activitiesPct = 0.1;
    double shoppingPct = 0.05;
    
    // Adjust based on selected themes and their intensity
    if (widget.prefs.themes.contains('food')) {
      final intensity = (_themeIntensity['food'] ?? 50.0) / 100.0;
      foodPct += 0.15 * intensity;
      accommodationPct -= 0.08 * intensity;
      shoppingPct -= 0.07 * intensity;
    }
    if (widget.prefs.themes.contains('adventure')) {
      final intensity = (_themeIntensity['adventure'] ?? 50.0) / 100.0;
      activitiesPct += 0.2 * intensity;
      accommodationPct -= 0.12 * intensity;
      foodPct -= 0.08 * intensity;
    }
    if (widget.prefs.themes.contains('nightlife')) {
      final intensity = (_themeIntensity['nightlife'] ?? 50.0) / 100.0;
      activitiesPct += 0.15 * intensity;
      foodPct += 0.08 * intensity;
      accommodationPct -= 0.18 * intensity;
      transportPct -= 0.05 * intensity;
    }
    if (widget.prefs.themes.contains('relaxation')) {
      final intensity = (_themeIntensity['relaxation'] ?? 50.0) / 100.0;
      accommodationPct += 0.15 * intensity;
      activitiesPct -= 0.08 * intensity;
      transportPct -= 0.07 * intensity;
    }
    if (widget.prefs.themes.contains('heritage')) {
      final intensity = (_themeIntensity['heritage'] ?? 50.0) / 100.0;
      activitiesPct += 0.1 * intensity;
      transportPct += 0.05 * intensity;
      accommodationPct -= 0.1 * intensity;
      shoppingPct -= 0.05 * intensity;
    }
    
    // Special requirements adjustments
    final specialReqs = _specialRequirementsController.text.toLowerCase();
    if (specialReqs.contains('wheelchair') || specialReqs.contains('accessible')) {
      accommodationPct += 0.1;
      transportPct += 0.05;
      activitiesPct -= 0.15;
    }
    if (specialReqs.contains('budget') || specialReqs.contains('conscious')) {
      accommodationPct -= 0.1;
      foodPct -= 0.05;
      activitiesPct -= 0.05;
      transportPct += 0.2;
    }
    if (specialReqs.contains('vegetarian') || specialReqs.contains('vegan')) {
      foodPct += 0.05;
      shoppingPct += 0.05;
      activitiesPct -= 0.1;
    }
    
    // Group size adjustments
    final groupMultiplier = widget.prefs.people > 4 ? 0.85 : widget.prefs.people > 2 ? 0.9 : 1.0;
    
    final accommodation = budgetLocal * accommodationPct * groupMultiplier;
    final transport = budgetLocal * transportPct;
    final food = budgetLocal * foodPct * (1 + (widget.prefs.people - 1) * 0.1);
    final activities = budgetLocal * activitiesPct * (1 + (widget.prefs.people - 1) * 0.15);
    final shopping = budgetLocal * shoppingPct * (1 + (widget.prefs.people - 1) * 0.05);
    
    return {
      'Accommodation': accommodation,
      'Transport': transport,
      'Food': food,
      'Activities': activities,
      'Shopping': shopping.clamp(budgetLocal * 0.02, budgetLocal * 0.15),
    };
  }

  Widget _buildThemeIntensitySliders() {
    final selectedThemes = widget.prefs.themes.toList();
    if (selectedThemes.isEmpty) return const SizedBox.shrink();
    
    return Card(
      color: const Color(0xFF0B1220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.read<LocalizationService>().getText('theme_intensity'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(context.read<LocalizationService>().getText('adjust_theme_desc'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 12),
            ...selectedThemes.map((theme) => _buildIntensitySlider(theme)),
          ],
        ),
      ),
    );
  }

  String _getThemeDisplayName(String theme) {
    final themeCard = themeCards.firstWhere((card) => card.title == theme, orElse: () => _ThemeCardData(theme, Icons.help, theme));
    return themeCard.displayName;
  }

  Widget _buildIntensitySlider(String theme) {
    final intensity = (_themeIntensity[theme] ?? 50.0).clamp(0.0, 100.0);
    final colors = {
      'nature': Colors.green,
      'nightlife': Colors.purple,
      'adventure': Colors.red,
      'leisure': Colors.blue,
      'heritage': Colors.amber,
      'culture': Colors.teal,
      'food': Colors.orange,
      'shopping': Colors.pink,
      'unexplored': Colors.indigo,
    };
    final color = colors[theme] ?? Colors.grey;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_getThemeDisplayName(theme), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Text('${intensity.toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: color.withOpacity(0.3),
              trackHeight: 6,
            ),
            child: SizedBox(
              width: 280,
              child: Slider(
                value: intensity,
                min: 0.0,
                max: 100.0,
                divisions: 20,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  if (mounted) {
                    setState(() {
                      _themeIntensity[theme] = value.clamp(0.0, 100.0);
                      // Trigger budget recalculation by updating themes
                      widget.prefs.themes = Set.from(widget.prefs.themes);
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRequirements() {
    return Card(
      color: const Color(0xFF0B1220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.accessibility, color: Colors.deepOrangeAccent, size: 20),
                const SizedBox(width: 8),
                Text(context.read<LocalizationService>().getText('special_requirements'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.read<LocalizationService>().getText('special_requirements_desc'),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _specialRequirementsController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                // Trigger budget recalculation when special requirements change
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: context.read<LocalizationService>().getText('special_requirements_hint'),
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0F1722),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.deepOrangeAccent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickTag(context.read<LocalizationService>().getText('pet_friendly'), Icons.pets),
                _buildQuickTag(context.read<LocalizationService>().getText('wheelchair_accessible'), Icons.accessible),
                _buildQuickTag(context.read<LocalizationService>().getText('food_allergies'), Icons.no_food),
                _buildQuickTag(context.read<LocalizationService>().getText('elderly_travelers'), Icons.elderly),
                _buildQuickTag(context.read<LocalizationService>().getText('budget_conscious'), Icons.savings),
                _buildQuickTag(context.read<LocalizationService>().getText('vegetarian_only'), Icons.eco),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTag(String label, IconData icon) {
    final isSelected = _specialRequirementsController.text.toLowerCase().contains(label.toLowerCase());
    return GestureDetector(
      onTap: () {
        final currentText = _specialRequirementsController.text;
        if (isSelected) {
          _specialRequirementsController.text = currentText.replaceAll(label, '').replaceAll(RegExp(r',\s*,'), ',').trim();
        } else {
          final newText = currentText.isEmpty ? label : '$currentText, $label';
          _specialRequirementsController.text = newText;
        }
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrangeAccent.withOpacity(0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.deepOrangeAccent : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.deepOrangeAccent : Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDates(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(context: context, firstDate: now, lastDate: now.add(const Duration(days: 365)));
    if (picked != null) {
      setState(() {
        widget.prefs.dates = picked;
        nights = picked.end.difference(picked.start).inDays;
      });
    }
  }
}

class _ThemeCardData {
  final String title;
  final IconData icon;
  final String displayName;
  _ThemeCardData(this.title, this.icon, this.displayName);
}
/// ---------------------- Itinerary Page ----------------------
class ItineraryPage extends StatefulWidget {
  final TripPreferences prefs;
  final Map<String, dynamic>? apiResponse; // Add API response parameter
  final VoidCallback onBook;
  final VoidCallback onBack;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final AIRecommendationEngine aiEngine;
  final LocationService locationService;
  const ItineraryPage({super.key, required this.prefs, this.apiResponse, required this.onBook, required this.onBack, this.onUndo, this.onRedo, required this.aiEngine, required this.locationService, required this.onToggleFavorite, required this.isFavorite});
  
  final Function(ItineraryItem) onToggleFavorite;
  final bool Function(ItineraryItem) isFavorite;

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> with TickerProviderStateMixin {
  // Static gradients for better performance (reused across rebuilds)
  static final _headerGradient = LinearGradient(
    colors: [Colors.deepOrangeAccent.withOpacity(0.1), Colors.transparent],
  );
  static const _dayHeaderGradient = LinearGradient(
    colors: [Colors.deepOrangeAccent, Colors.orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  late final List<ItineraryDay> days;
  late int hotelCost, transportCost, experiencesCost, foodCost;

  bool _showMap = false;
  late AnimationController _mainAnimationController; // Single controller
  Timer? _priceUpdateTimer; // Add timer reference
  
  List<LatLng> _routePoints = [];
  
  // Itinerary metadata for Smart Adjust API
  String? itineraryTitle;
  String? destination;
  String? itineraryId;
  double? totalBudget;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedPriceFilter = 'All';
  String _selectedRatingFilter = 'All';
  bool _showFilters = false;
  bool _showBudgetTracker = false;

  @override
  void initState() {
    super.initState();
    // Only use API response - no fallback to mock data
    if (widget.apiResponse != null) {
      _generateFromApiResponse();
    } else {
      // If no API response, initialize empty state
      days = [];
      hotelCost = 0;
      transportCost = 0;
      experiencesCost = 0;
      foodCost = 0;
      _routePoints = [];
    }
    // Single animation controller for better performance
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _mainAnimationController.forward();
    _initializeAdvancedFeatures();
  }
  
  @override
  void dispose() {
    _mainAnimationController.dispose();
    _searchController.dispose();
    _priceUpdateTimer?.cancel(); // Cancel price update timer
    super.dispose();
  }
  
  void _initializeAdvancedFeatures() {
    _getCurrentLocation();
    _setupBudgetTracking();
    _updatePricesRealTime();
  }
  
  void _getCurrentLocation() async {
    // Location tracking removed for web optimization
  }
  
  void _setupBudgetTracking() {
    widget.prefs.expenseTracker.categoryBudget = {
      'Accommodation': hotelCost.toDouble(),
      'Transport': transportCost.toDouble(),
      'Activities': experiencesCost.toDouble(),
      'Food': foodCost.toDouble(),
    };
  }
  
  void _updatePricesRealTime() {
    _priceUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        for (final day in days) {
          for (final item in day.items) {
            final fluctuation = (Random().nextDouble() - 0.5) * 0.1;
            item.currentPrice = item.approxCost * (1 + fluctuation);
            item.lastPriceUpdate = DateTime.now();
          }
        }
        setState(() {});
      } else {
        timer.cancel(); // Cancel timer if widget is disposed
      }
    });
  }
  
  void _exportToCalendar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0E1620),
        title: const Text('Export to Calendar', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text('Google Calendar', style: TextStyle(color: Colors.white)),
              onTap: () => _exportToGoogleCalendar(),
            ),
            ListTile(
              leading: const Icon(Icons.apple, color: Colors.white),
              title: const Text('Apple Calendar', style: TextStyle(color: Colors.white)),
              onTap: () => _exportToAppleCalendar(),
            ),
          ],
        ),
      ),
    );
  }
  
  void _exportToGoogleCalendar() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exported to Google Calendar!'), backgroundColor: Colors.green),
    );
  }
  
  void _exportToAppleCalendar() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exported to Apple Calendar!'), backgroundColor: Colors.green),
    );
  }
  
  void _generateFromApiResponse() {
    final apiResponse = widget.apiResponse!;
    final itinerary = apiResponse['itinerary'];
    final apiDays = itinerary['days'] as List<dynamic>;
    
    // Convert API response to ItineraryDay format
    days = apiDays.map<ItineraryDay>((apiDay) {
      final dayIndex = apiDay['dayIndex'] as int;
      final activities = apiDay['activities'] as List<dynamic>;
      
      final items = activities.map<ItineraryItem>((activity) {
        return ItineraryItem(
          id: activity['poiId'] ?? 'fallback_${Random().nextInt(10000)}',
          title: activity['title'] ?? 'Unknown Activity',
          description: activity['description'] ?? 'No description available',
          image: '', // Remove image URL - no longer used
          rating: 4.0, // Use static default rating
          reviews: 100, // Use static default reviews
          approxCost: activity['cost'] ?? 0,
          startTime: _getTimeFromActivity(activity, 'start'),
          endTime: _getTimeFromActivity(activity, 'end'),
          duration: activity['durationMins'] ?? 120,
          difficulty: _getDifficultyFromCategory(activity['category']),
          isAccessible: true,
          insiderTip: activity['safetyNote'] ?? '',
          isOpen: true,
          crowdLevel: 'Moderate',
          localPhrases: [],
          emergencyContact: '',
          hasBooking: activity['bookingRequired'] ?? false,
          travelTimeToNext: 15,
          currentPrice: (activity['cost'] ?? 0).toDouble(),
          lastPriceUpdate: DateTime.now(),
          isCurrentlyOpen: true,
          alternatives: [],
          location: null,
        );
      }).toList();
      
      return ItineraryDay(dayNumber: dayIndex, items: items);
    }).toList();
    
    // Use API costs or calculate from activities
    final estimatedCost = itinerary['estimatedCost'] ?? 10000;
    hotelCost = (estimatedCost * 0.4).round();
    transportCost = (estimatedCost * 0.2).round();
    experiencesCost = (estimatedCost * 0.3).round();
    foodCost = (estimatedCost * 0.1).round();
    
    // Generate route points from first few activities
    _routePoints = _generateRoutePointsFromActivities(days);
  }
  
  String _getTimeFromActivity(Map<String, dynamic> activity, String type) {
    final timeOfDay = activity['timeOfDay'] ?? 'morning';
    switch (timeOfDay) {
      case 'morning':
        return type == 'start' ? '09:00' : '11:00';
      case 'afternoon':
        return type == 'start' ? '13:00' : '15:00';
      case 'evening':
        return type == 'start' ? '18:00' : '20:00';
      default:
        return type == 'start' ? '10:00' : '12:00';
    }
  }
  
  String _getDifficultyFromCategory(String? category) {
    switch (category) {
      case 'adventure':
        return 'Hard';
      case 'nature':
        return 'Moderate';
      default:
        return 'Easy';
    }
  }
  
  List<LatLng> _generateRoutePointsFromActivities(List<ItineraryDay> days) {
    // Extract coordinates from actual activities in the itinerary
    // In a real implementation, you would geocode the location strings
    // For now, return empty list as we should get coordinates from API response
    List<LatLng> points = [];
    return points;
  }

  
  
  String _getActivityStartTime(String timeSlot, int day) {
    final times = {
      'morning': ['8:30 AM', '9:00 AM', '9:30 AM'],
      'afternoon': ['1:30 PM', '2:00 PM', '2:30 PM'],
      'evening': ['6:30 PM', '7:00 PM', '7:30 PM'],
    };
    return times[timeSlot]![(day - 1) % 3];
  }
  
  String _getActivityEndTime(String timeSlot, int day) {
    final times = {
      'morning': ['11:00 AM', '11:30 AM', '12:00 PM'],
      'afternoon': ['4:30 PM', '5:00 PM', '5:30 PM'],
      'evening': ['9:00 PM', '9:30 PM', '10:00 PM'],
    };
    return times[timeSlot]![(day - 1) % 3];
  }
  
  int _getActivityDuration(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('cruise') || titleLower.contains('safari') || titleLower.contains('tour')) return 180;
    if (titleLower.contains('walk') || titleLower.contains('visit') || titleLower.contains('market')) return 120;
    if (titleLower.contains('class') || titleLower.contains('performance') || titleLower.contains('show')) return 90;
    if (titleLower.contains('sunset') || titleLower.contains('cafe') || titleLower.contains('bar')) return 150;
    return 150;
  }
  
  Map<String, List<Map<String, dynamic>>> _filterActivitiesByThemes(Map<String, List<Map<String, dynamic>>> activities, Set<String> themes) {
    if (themes.isEmpty) return activities;
    
    final filtered = <String, List<Map<String, dynamic>>>{};
    
    for (final timeSlot in activities.keys) {
      final timeActivities = activities[timeSlot]!;
      final filteredTimeActivities = <Map<String, dynamic>>[];
      
      for (final activity in timeActivities) {
        final title = activity['title'].toString().toLowerCase();
        final desc = activity['desc'].toString().toLowerCase();
        
        bool matches = false;
        
        for (final theme in themes) {
          switch (theme.toLowerCase()) {
            case 'heritage':
              if (title.contains('fort') || title.contains('palace') || title.contains('temple') || 
                  title.contains('heritage') || desc.contains('historic') || desc.contains('ancient')) {
                matches = true;
              }
              break;
            case 'food':
              if (title.contains('food') || title.contains('cooking') || title.contains('market') ||
                  title.contains('spice') || desc.contains('taste') || desc.contains('cuisine')) {
                matches = true;
              }
              break;
            case 'adventure':
              if (title.contains('safari') || title.contains('rafting') || title.contains('activities') ||
                  title.contains('paragliding') || desc.contains('adventure') || desc.contains('sports')) {
                matches = true;
              }
              break;
            case 'nightlife':
              if (title.contains('night') || title.contains('bar') || title.contains('club') ||
                  desc.contains('nightlife') || desc.contains('dancing')) {
                matches = true;
              }
              break;
            case 'relaxation':
              if (title.contains('spa') || title.contains('sunset') || title.contains('cruise') ||
                  desc.contains('peaceful') || desc.contains('relaxing') || desc.contains('wellness')) {
                matches = true;
              }
              break;
          }
        }
        
        if (matches) {
          filteredTimeActivities.add(activity);
        }
      }
      
      // If no activities match themes, include all activities for that time slot
      filtered[timeSlot] = filteredTimeActivities.isNotEmpty ? filteredTimeActivities : timeActivities;
    }
    
    return filtered;
  }
  
  
  String _getDifficulty(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('trek') || titleLower.contains('climb') || titleLower.contains('adventure')) return 'Challenging';
    if (titleLower.contains('walk') || titleLower.contains('tour') || titleLower.contains('ride')) return 'Moderate';
    return 'Easy';
  }
  
  bool _isAccessible(String title) {
    final titleLower = title.toLowerCase();
    return !titleLower.contains('climb') && !titleLower.contains('trek') && !titleLower.contains('stairs');
  }
  
  String _getInsiderTip(String title) {
    final tips = {
      'beach': 'Visit early morning for best photos and fewer crowds',
      'fort': 'Climb to the highest point for panoramic views',
      'market': 'Bargain prices are usually 30-40% of asking price',
      'temple': 'Remove shoes before entering, dress modestly',
      'food': 'Try the local specialties, avoid ice in drinks',
      'museum': 'Audio guides available in multiple languages',
      'palace': 'Photography may require additional fees',
      'garden': 'Best visited during golden hour for photos',
    };
    
    for (final key in tips.keys) {
      if (title.toLowerCase().contains(key)) {
        return tips[key]!;
      }
    }
    return 'Ask locals for hidden gems nearby';
  }
  
  List<String> _getLocalPhrases(String destination) {
    final phrases = {
      'goa': ['Obrigado (Thank you)', 'Kitem korum? (How much?)', 'Susegad (Take it easy)'],
      'kerala': ['Nanni (Thank you)', 'Enthanu vila? (What\'s the price?)', 'Namaste (Hello)'],
      'rajasthan': ['Dhanyawad (Thank you)', 'Kitna paisa? (How much money?)', 'Khamma ghani (Hello)'],
      'mumbai': ['Dhanyawad (Thank you)', 'Kitna hai? (How much?)', 'Kem cho? (How are you?)'],
      'delhi': ['Shukriya (Thank you)', 'Kitna paisa? (How much?)', 'Namaste (Hello)'],
    };
    return phrases[destination] ?? ['Namaste (Hello)', 'Dhanyawad (Thank you)', 'Kitna hai? (How much?)'];
  }
  
  String _getEmergencyContact(String destination) {
    final contacts = {
      'goa': 'Tourist Helpline: 1363, Police: 100',
      'kerala': 'Tourist Helpline: 0471-2321132, Police: 100',
      'rajasthan': 'Tourist Helpline: 1363, Police: 100',
      'mumbai': 'Tourist Helpline: 1363, Police: 100',
      'delhi': 'Tourist Helpline: 1363, Police: 100',
    };
    return contacts[destination] ?? 'Police: 100, Tourist Helpline: 1363';
  }
  
  bool _hasBooking(String title) {
    final titleLower = title.toLowerCase();
    return titleLower.contains('tour') || titleLower.contains('class') || titleLower.contains('show') || titleLower.contains('cruise');
  }

  int get total => hotelCost + transportCost + experiencesCost + foodCost;

  @override
  Widget build(BuildContext context) {
    // Cache MediaQuery to avoid repeated lookups
    final mediaQuery = MediaQuery.of(context);
    final isWide = mediaQuery.size.width > 1000;
    final screenWidth = mediaQuery.size.width;
    
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: _headerGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(children: [
                        IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Itinerary • ${widget.prefs.destination.isEmpty ? 'Your Trip' : widget.prefs.destination}', 
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                '${days.length} days • ${widget.prefs.people} travelers • ₹${total.toStringAsFixed(0)}', 
                                style: const TextStyle(color: Colors.white70, fontSize: 9),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.onUndo != null)
                              IconButton(
                                onPressed: widget.onUndo,
                                icon: const Icon(Icons.undo),
                                tooltip: 'Undo',
                              ),
                            if (widget.onRedo != null)
                              IconButton(
                                onPressed: widget.onRedo,
                                icon: const Icon(Icons.redo),
                                tooltip: 'Redo',
                              ),
                            IconButton(
                              onPressed: () => setState(() => _showBudgetTracker = !_showBudgetTracker),
                              icon: const Icon(Icons.account_balance_wallet),
                              tooltip: 'Budget Tracker',
                            ),
                            IconButton(
                              onPressed: () => setState(() => _showFilters = !_showFilters),
                              icon: const Icon(Icons.filter_list),
                              tooltip: 'Filters',
                            ),
                            IconButton(
                              onPressed: _exportToCalendar,
                              icon: const Icon(Icons.calendar_today),
                              tooltip: 'Export to Calendar',
                            ),
                            IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() => _showMap = !_showMap);
                              },
                              icon: Icon(_showMap ? Icons.list : Icons.map),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                foregroundColor: Colors.blue,
                              ),
                              tooltip: _showMap ? 'Show Itinerary' : 'Show Map',
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                _showSmartAdjustDialog();
                              }, 
                              icon: const Icon(Icons.auto_fix_high), 
                              label: const Text('Smart Adjust'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrangeAccent,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_showBudgetTracker) _buildBudgetTracker(),
                if (_showBudgetTracker) const SizedBox(height: 12),
                if (_showFilters) _buildFiltersSection(),
                if (_showFilters) const SizedBox(height: 12),
                _buildSearchBar(),
                const SizedBox(height: 12),
                if (_showMap)
                  Card(
                    color: const Color(0xFF0E1620),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.map, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              const Text('Trip Route Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Spacer(),
                              Text('${_routePoints.length} locations', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          InteractiveMapWidget(
                            routePoints: _routePoints,
                            markers: _getItineraryMarkers(),
                            onLocationTap: (location) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Location: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}'),
                                  backgroundColor: Colors.deepOrangeAccent,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (final d in _getFilteredDays()) 
                    RepaintBoundary(key: ValueKey(d.dayNumber), child: _dayTile(d)),
                const SizedBox(height: 60),
              ],
            ),
          ),
          if (isWide)
            SizedBox(
              width: 420,
              child: _rightPanel(),
            ),
        ],
      ),
    );
  }

  Widget _dayTile(ItineraryDay day) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // Day header with improved styling
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: _dayHeaderGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Day ${day.dayNumber}', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, size: 12, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${_getTotalDuration(day)} hrs total',
                      style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${day.items.length} activities',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ]),
            const SizedBox(height: 16),
            _buildTimelineView(day),
          ]
        ),
      ),
    );
  }
  
  Widget _buildTimelineView(ItineraryDay day) {
    return Column(
      children: day.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == day.items.length - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.deepOrangeAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 180, // Increased height for better spacing
                    color: Colors.white24,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Time information
            SizedBox(
              width: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.startTime,
                    style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${item.duration}min',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                  if (item.travelTimeToNext > 0 && !isLast)
                    Text(
                      '+${item.travelTimeToNext}m travel',
                      style: const TextStyle(color: Colors.amber, fontSize: 9),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Activity card - full width for single column layout
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: _itineraryCard(item, day.dayNumber),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
  
  String _getTotalDuration(ItineraryDay day) {
    final totalMinutes = day.items.fold(0, (sum, item) => sum + item.duration + item.travelTimeToNext);
    return (totalMinutes / 60).toStringAsFixed(1);
  }

  Widget _itineraryCard(ItineraryItem item, int dayNumber) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and cost row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    '₹${item.approxCost}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Time and duration info
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${item.startTime} - ${item.endTime}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.duration} min',
                      style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              item.description,
              style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 12),
            
            // Additional details row
            Row(
              children: [
                // Difficulty
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(item.difficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _getDifficultyColor(item.difficulty).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, color: _getDifficultyColor(item.difficulty), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        item.difficulty,
                        style: TextStyle(color: _getDifficultyColor(item.difficulty), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                
                // Category icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Icon(
                    _getCategoryIcon(item.title),
                    size: 16,
                    color: Colors.purple,
                  ),
                ),
                const Spacer(),
                
                // Booking indicator
                if (item.hasBooking)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_available, color: Colors.amber, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Booking Required',
                          style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            // Insider tip if available
            if (item.insiderTip.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Insider Tip',
                            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.insiderTip,
                            style: const TextStyle(color: Colors.amber, fontSize: 11, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().scale(delay: 100.ms).fadeIn();
  }
  
  IconData _getCategoryIcon(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('museum') || titleLower.contains('palace') || titleLower.contains('heritage')) {
      return Icons.account_balance;
    } else if (titleLower.contains('beach') || titleLower.contains('nature') || titleLower.contains('park')) {
      return Icons.nature;
    } else if (titleLower.contains('food') || titleLower.contains('restaurant') || titleLower.contains('dinner')) {
      return Icons.restaurant;
    } else if (titleLower.contains('temple') || titleLower.contains('church') || titleLower.contains('synagogue')) {
      return Icons.temple_hindu;
    } else if (titleLower.contains('market') || titleLower.contains('shopping')) {
      return Icons.shopping_bag;
    } else if (titleLower.contains('performance') || titleLower.contains('dance') || titleLower.contains('show')) {
      return Icons.theater_comedy;
    }
    return Icons.place;
  }

  Widget _rightPanel() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
          const SizedBox(height: 12),
          _buildBudgetSummary(),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              widget.onBook();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flight_takeoff, size: 16),
                SizedBox(width: 8),
                Text('Book on EaseMyTrip'),
              ],
            ),
          ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack).shimmer(delay: 2000.ms),
          const SizedBox(height: 12),
          const Text('Share & export', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            IconButton(
              onPressed: () => _mockShare(),
              icon: const Icon(Icons.message),
              tooltip: 'Share via WhatsApp',
            ),
            IconButton(
              onPressed: () => _downloadItinerary(),
              icon: const Icon(Icons.file_download),
              tooltip: 'Download PDF',
            ),
            IconButton(
              onPressed: () => _copyItineraryLink(),
              icon: const Icon(Icons.link),
              tooltip: 'Copy Link',
            ),
            IconButton(
              onPressed: () => _collaborateItinerary(),
              icon: const Icon(Icons.group_add),
              tooltip: 'Collaborate',
            ),
          ]),
          const SizedBox(height: 16),
          _buildSmartRecommendations(),
          const SizedBox(height: 12),
          _buildPriceAlertsSection(),
          const SizedBox(height: 12),
          _buildSocialIntegration(),
          const SizedBox(height: 12),
          _buildCollaborationSection(),
        ]
        ),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search activities...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF0E1620),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
  
  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPriceFilter,
              decoration: const InputDecoration(labelText: 'Price'),
              items: ['All', 'Under ₹500', '₹500-₹1500', 'Above ₹1500']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedPriceFilter = value!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedRatingFilter,
              decoration: const InputDecoration(labelText: 'Rating'),
              items: ['All', '4+ Stars', '3+ Stars']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedRatingFilter = value!),
            ),
          ),
        ],
      ),
    );
  }
  
  List<ItineraryDay> _getFilteredDays() {
    if (_searchQuery.isEmpty && _selectedPriceFilter == 'All' && _selectedRatingFilter == 'All') {
      return days;
    }
    
    return days.map((day) {
      final filteredItems = day.items.where((item) {
        if (_searchQuery.isNotEmpty && 
            !item.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
        
        if (_selectedPriceFilter != 'All') {
          switch (_selectedPriceFilter) {
            case 'Under ₹500':
              if (item.approxCost >= 500) return false;
              break;
            case '₹500-₹1500':
              if (item.approxCost < 500 || item.approxCost > 1500) return false;
              break;
            case 'Above ₹1500':
              if (item.approxCost <= 1500) return false;
              break;
          }
        }
        
        if (_selectedRatingFilter != 'All') {
          switch (_selectedRatingFilter) {
            case '4+ Stars':
              if (item.rating < 4.0) return false;
              break;
            case '3+ Stars':
              if (item.rating < 3.0) return false;
              break;
          }
        }
        
        return true;
      }).toList();
      
      return ItineraryDay(dayNumber: day.dayNumber, items: filteredItems);
    }).where((day) => day.items.isNotEmpty).toList();
  }
  
  Widget _buildSmartRecommendations() {
    return Card(
      color: const Color(0xFF0B1220),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Colors.deepOrangeAccent, size: 16),
                SizedBox(width: 8),
                Text('AI Recommendations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            const Text('💡 Swap Day 2 activities', style: TextStyle(fontSize: 11)),
            const Text('🚗 Add 30min buffer', style: TextStyle(fontSize: 11)),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Smart recommendations applied!'), backgroundColor: Colors.green),
                ),
                icon: const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                label: const Text('Apply', style: TextStyle(fontSize: 11, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCollaborationSection() {
    return Card(
      color: const Color(0xFF0B1220),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.group, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Text('Collaboration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showCollaborationDialog(),
                    icon: const Icon(Icons.person_add, size: 14),
                    label: const Text('Invite', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareRichContent(),
                    icon: const Icon(Icons.share, size: 14),
                    label: const Text('Share', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCollaborationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0E1620),
        title: const Text('Invite Collaborators', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter email addresses',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1A2332),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invitations sent!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
  
  void _shareRichContent() {
    final content = '''🌟 Check out my ${widget.prefs.destination} trip!

📅 ${days.length} days • 💰 Budget: ₹${(hotelCost + transportCost + experiencesCost + foodCost)}

🎯 Highlights:
${days.take(2).map((d) => '• ${d.items.first.title}').join('\n')}

#TravelPlanning #${widget.prefs.destination}''';
    
    Share.share(content);
  }
  
  Widget _buildBudgetTracker() {
    final tracker = widget.prefs.expenseTracker;
    return Card(
      color: const Color(0xFF0B1220),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('Budget Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spent: ₹${tracker.totalSpent.toInt()}', style: const TextStyle(fontSize: 12)),
                      Text('Budget: ₹${tracker.totalBudget.toInt()}', style: const TextStyle(fontSize: 12)),
                      Text('Remaining: ₹${tracker.remainingBudget.toInt()}', 
                        style: TextStyle(fontSize: 12, color: tracker.remainingBudget > 0 ? Colors.green : Colors.red)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addExpense,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Expense', style: TextStyle(fontSize: 12, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPriceAlertsSection() {
    return Card(
      color: const Color(0xFF0B1220),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Text('Price Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('💰 Activity prices updated 2 min ago', style: TextStyle(fontSize: 12)),
            const Text('🔔 2 price drops detected!', style: TextStyle(fontSize: 12, color: Colors.green)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _setupPriceAlerts,
              icon: const Icon(Icons.add_alert, size: 14),
              label: const Text('Set Alert', style: TextStyle(fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSocialIntegration() {
    return Card(
      color: const Color(0xFF0B1220),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.photo_camera, color: Colors.pink, size: 16),
                SizedBox(width: 8),
                Text('Social Sharing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareToInstagram,
                    icon: const Icon(Icons.camera_alt, size: 14),
                    label: const Text('Instagram', style: TextStyle(fontSize: 12, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareToFacebook,
                    icon: const Icon(Icons.facebook, size: 14),
                    label: const Text('Facebook', style: TextStyle(fontSize: 12, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _addExpense() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0E1620),
        title: const Text('Add Expense', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['Food', 'Transport', 'Activities', 'Shopping']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense added!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _setupPriceAlerts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Price alerts configured!'), backgroundColor: Colors.orange),
    );
  }
  
  void _shareToInstagram() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shared to Instagram!'), backgroundColor: Colors.pink),
    );
  }
  
  void _shareToFacebook() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shared to Facebook!'), backgroundColor: Colors.blue),
    );
  }

  Widget _buildBudgetSummary() {
    return Card(
      color: const Color(0xFF0B1220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.deepOrangeAccent, size: 16),
                SizedBox(width: 8),
                Text('Budget Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _costRow('Accommodation', hotelCost, total),
                      _costRow('Transport', transportCost, total),
                      _costRow('Activities', experiencesCost, total),
                      _costRow('Food', foodCost, total),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 120,
                    child: BudgetPieChart(
                      data: {
                        'Accommodation': hotelCost.toDouble(),
                        'Transport': transportCost.toDouble(),
                        'Activities': experiencesCost.toDouble(),
                        'Food': foodCost.toDouble(),
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepOrangeAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Budget:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('₹${total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _costRow(String label, int amt, int tot) {
    final pct = tot == 0 ? 0.0 : amt / tot;
    final color = label == 'Accommodation' ? Colors.blue : label == 'Transport' ? Colors.green : label == 'Activities' ? Colors.purple : Colors.orange;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(children: [Icon(Icons.circle, size: 10, color: color), const SizedBox(width: 8), Expanded(child: Text(label)), Text('₹$amt')]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: pct, minHeight: 10, color: color)),
        ]
      ),
    );
  }

  /// Show Smart Adjust dialog for textual instructions
  void _showSmartAdjustDialog() {
    final TextEditingController instructionController = TextEditingController();
    bool isLoading = false;
    int currentCharCount = 0;
    const int minChars = 20;
    const int maxChars = 256;
    String? activeRequestId;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 500, maxHeight: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_fix_high, color: Colors.deepOrangeAccent, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Smart Adjust',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (!isLoading)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Describe what you\'d like to adjust in your itinerary:',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: instructionController,
                      maxLines: 4,
                      maxLength: maxChars,
                      enabled: !isLoading,
                      onChanged: (text) {
                        setDialogState(() {
                          currentCharCount = text.length;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'e.g., "Replace outdoor activities on day 2 with indoor alternatives", "Add more cultural experiences", "Make the schedule less packed"...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        counterText: '', // Hide default counter
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Minimum $minChars characters required',
                          style: TextStyle(
                            fontSize: 12,
                            color: currentCharCount < minChars ? Colors.red : Colors.grey,
                          ),
                        ),
                        Text(
                          '$currentCharCount/$maxChars',
                          style: TextStyle(
                            fontSize: 12,
                            color: currentCharCount > maxChars ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (isLoading) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Processing your request... This may take up to 90 seconds.',
                                style: TextStyle(fontSize: 12, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isLoading) ...[
                          TextButton.icon(
                            onPressed: () {
                              if (activeRequestId != null) {
                                AuthenticatedHttpClient().cancelRequest(activeRequestId!);
                                setDialogState(() {
                                  isLoading = false;
                                  activeRequestId = null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Request cancelled'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.cancel, size: 18),
                            label: const Text('Cancel Request'),
                          ),
                        ] else ...[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final text = instructionController.text.trim();
                              
                              if (text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter your adjustment instructions'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              
                              if (text.length < minChars) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Instructions must be at least $minChars characters long'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              
                              if (text.length > maxChars) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Instructions must be no more than $maxChars characters long'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              
                              // Generate request ID for cancellation
                              activeRequestId = 'smart_adjust_${DateTime.now().millisecondsSinceEpoch}';
                              setDialogState(() => isLoading = true);
                              
                              try {
                                await _applySmartAdjust(text, activeRequestId!);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Smart Adjust applied successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                setDialogState(() {
                                  isLoading = false;
                                  activeRequestId = null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to apply adjustments: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.auto_fix_high),
                            label: const Text('Apply Adjustments'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrangeAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Apply smart adjustments using the API
  Future<void> _applySmartAdjust(String instruction, String requestId) async {
    final AuthenticatedHttpClient httpClient = AuthenticatedHttpClient();
    
    try {
      // Use original API response data if available, otherwise fall back to reconstructed data
      Map<String, dynamic> itineraryData;
      String itineraryIdValue;
      
      if (widget.apiResponse != null && widget.apiResponse!['itinerary'] != null) {
        // Use the original itinerary object from the /plantrip API response
        itineraryData = widget.apiResponse!['itinerary'] as Map<String, dynamic>;
        itineraryIdValue = widget.apiResponse!['itineraryId'] as String? ?? 
                          itineraryData['itineraryId'] as String? ?? 
                          'itin_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        // Fallback: reconstruct from current state
        itineraryData = {
          'itineraryId': 'itin_${DateTime.now().millisecondsSinceEpoch}',
          'days': days.map((day) => {
            'dayIndex': day.dayNumber,
            'activities': day.items.map((item) => {
              'poiId': item.id,
              'title': item.title,
              'description': item.description,
              'cost': item.approxCost,
              'timeOfDay': _getTimeOfDayFromStartTime(item.startTime),
              'category': _getCategoryFromItem(item),
              'durationMins': item.duration,
            }).toList(),
          }).toList(),
        };
        itineraryIdValue = itineraryData['itineraryId'] as String;
      }

      // Serialize request body in the format expected by the API
      final requestBody = {
        'sessionID': await _getSessionId(),
        'userRequest': instruction,
        'itinerary': itineraryData,
        'itineraryId': itineraryIdValue,
      };

      // Make API call to smart adjust endpoint with cancellation support
      final response = await httpClient.apiPost(
        ApiConfig.smartAdjustEndpoint,
        body: requestBody,
        requestId: requestId,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Smart adjust API returns { status, adjustedItinerary, ... }
        // Extract the adjustedItinerary object which contains the actual itinerary data
        if (responseData['adjustedItinerary'] != null) {
          _updateItineraryFromApi(responseData['adjustedItinerary']);
        } else {
          // Fallback: if response is already in the correct format
          _updateItineraryFromApi(responseData);
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Smart Adjust error: $e');
      rethrow;
    }
  }

  /// Get session ID for unauthenticated users or fallback
  Future<String> _getSessionId() async {
    try {
      // Try to get user profile first (for authenticated users)
      final userProfile = await WebAuthService().getUserProfile();
      if (userProfile != null && userProfile['uid'] != null) {
        return userProfile['uid'] as String;
      }
    } catch (e) {
      debugPrint('Could not get authenticated user ID: $e');
    }
    
    // For unauthenticated users, generate or retrieve session ID
    // This could be stored in localStorage or generated as UUID
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Map itinerary item to activity category
  String _getCategoryFromItem(ItineraryItem item) {
    final title = item.title.toLowerCase();
    final description = item.description.toLowerCase();
    
    if (title.contains('transport') || title.contains('arrival') || title.contains('departure') || 
        title.contains('airport') || title.contains('transfer')) {
      return 'transport';
    } else if (title.contains('museum') || title.contains('palace') || title.contains('temple') || 
               title.contains('heritage') || title.contains('synagogue') || description.contains('historic')) {
      return 'heritage';
    } else if (title.contains('beach') || title.contains('nature') || title.contains('cruise') || 
               title.contains('backwater') || description.contains('natural')) {
      return 'nature';
    } else if (title.contains('dinner') || title.contains('lunch') || title.contains('food') || 
               title.contains('restaurant') || description.contains('meal')) {
      return 'food';
    } else if (title.contains('dance') || title.contains('performance') || title.contains('cultural') || 
               title.contains('spice') || description.contains('traditional')) {
      return 'culture';
    } else if (title.contains('adventure') || title.contains('trekking') || title.contains('climbing')) {
      return 'adventure';
    } else if (title.contains('nightlife') || title.contains('bar') || title.contains('club')) {
      return 'nightlife';
    } else {
      return 'leisure';
    }
  }

  /// Get time of day from start time
  String _getTimeOfDayFromStartTime(String startTime) {
    if (startTime.isEmpty) return 'morning';
    
    try {
      final hour = int.parse(startTime.split(':')[0]);
      if (hour >= 5 && hour < 12) return 'morning';
      if (hour >= 12 && hour < 17) return 'afternoon';
      if (hour >= 17 && hour < 21) return 'evening';
      return 'night';
    } catch (e) {
      return 'morning';
    }
  }

  /// Calculate total estimated cost
  double _calculateTotalCost() {
    double total = 0.0;
    for (final day in days) {
      for (final item in day.items) {
        total += item.approxCost;
      }
    }
    return total;
  }

  /// Update itinerary from API response
  void _updateItineraryFromApi(Map<String, dynamic> adjustedItinerary) {
    try {
      // Update metadata
      itineraryTitle = adjustedItinerary['title'] ?? itineraryTitle;
      itineraryId = adjustedItinerary['itineraryId'] ?? itineraryId;
      totalBudget = (adjustedItinerary['estimatedCost'] ?? totalBudget ?? 0.0).toDouble();
      
      // Extract destination from input
      if (adjustedItinerary['input'] != null && adjustedItinerary['input']['destination'] != null) {
        destination = adjustedItinerary['input']['destination']['name'] ?? destination;
      }
      
      final adjustedDays = adjustedItinerary['days'] as List<dynamic>;
      
      // Clear and rebuild days list with adjusted data
      days.clear();
      
      for (int i = 0; i < adjustedDays.length; i++) {
        final dayData = adjustedDays[i] as Map<String, dynamic>;
        final activities = dayData['activities'] as List<dynamic>;
        
        final dayItems = activities.map<ItineraryItem>((activityData) {
          final activity = activityData as Map<String, dynamic>;
          return ItineraryItem(
            id: activity['poiId'] ?? '',
            title: activity['title'] ?? '',
            description: activity['description'] ?? '',
            image: 'https://picsum.photos/seed/${activity['poiId']}/900/600', // Default image
            rating: 4.0, // Default rating
            reviews: 100, // Default reviews
            approxCost: activity['cost'] ?? 0,
            startTime: _convertTimeOfDayToTime(activity['timeOfDay'] ?? 'morning'),
            endTime: _calculateEndTime(_convertTimeOfDayToTime(activity['timeOfDay'] ?? 'morning'), activity['durationMins'] ?? 60),
            duration: activity['durationMins'] ?? 60,
            difficulty: 'Easy', // Default difficulty
            isAccessible: true, // Default accessibility
            insiderTip: activity['safetyNote'] ?? '',
            isOpen: true, // Default open status
            crowdLevel: 'Moderate', // Default crowd level
            localPhrases: [], // Default empty phrases
            emergencyContact: '', // Default empty contact
            hasBooking: activity['bookingRequired'] ?? false,
            travelTimeToNext: 15, // Default travel time
            currentPrice: (activity['cost'] ?? 0.0).toDouble(),
            lastPriceUpdate: DateTime.now(),
            isCurrentlyOpen: true, // Default currently open
            alternatives: [], // Default empty alternatives
            location: null, // Default no location
          );
        }).toList();
        
        days.add(ItineraryDay(
          dayNumber: (dayData['dayIndex'] ?? (i + 1)) as int,
          items: dayItems,
        ));
      }
      
      // Recalculate costs
      hotelCost = (totalBudget! * 0.3).toInt();
      transportCost = (totalBudget! * 0.2).toInt();
      experiencesCost = (totalBudget! * 0.35).toInt();
      foodCost = (totalBudget! * 0.15).toInt();
      
    } catch (e) {
      debugPrint('Error updating itinerary from API: $e');
      throw Exception('Failed to parse adjusted itinerary data');
    }
  }

  /// Convert time of day string to HH:MM format
  String _convertTimeOfDayToTime(String timeOfDay) {
    switch (timeOfDay.toLowerCase()) {
      case 'morning':
        return '09:00';
      case 'afternoon':
        return '14:00';
      case 'evening':
        return '18:00';
      case 'night':
        return '20:00';
      default:
        return '09:00';
    }
  }

  /// Calculate end time based on start time and duration
  String _calculateEndTime(String startTime, int durationMins) {
    try {
      final parts = startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final startDateTime = DateTime(2000, 1, 1, hour, minute);
      final endDateTime = startDateTime.add(Duration(minutes: durationMins));
      
      return '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return startTime; // Return start time if calculation fails
    }
  }

  void _mockShare() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<LocalizationService>().getText('share_mock'))));
  }
  
  void _showActivityDetails(ItineraryItem item, int dayNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0E1620),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: item.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.deepOrangeAccent, size: 16),
                    const SizedBox(width: 8),
                    Text('${item.startTime} - ${item.endTime}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(item.difficulty).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.difficulty,
                        style: TextStyle(color: _getDifficultyColor(item.difficulty), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.description,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              if (item.insiderTip.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Insider Tip', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(item.insiderTip, style: const TextStyle(color: Colors.amber, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusChip(
                      item.isOpen ? 'Open Now' : 'Closed',
                      item.isOpen ? Colors.green : Colors.red,
                      item.isOpen ? Icons.check_circle : Icons.cancel,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusChip(
                      '${item.crowdLevel} Crowd',
                      _getCrowdColor(item.crowdLevel),
                      Icons.people,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusChip(
                      item.isAccessible ? 'Accessible' : 'Not Accessible',
                      item.isAccessible ? Colors.blue : Colors.grey,
                      Icons.accessible,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (item.localPhrases.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Useful Phrases', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...item.localPhrases.map((phrase) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• $phrase', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    )),
                  ],
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emergency, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Emergency Contacts', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(item.emergencyContact, style: const TextStyle(color: Colors.red, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (item.hasBooking)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _bookActivity(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.book_online, size: 16),
                        label: const Text('Book Now'),
                      ),
                    ),
                  if (item.hasBooking) const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showOnMap(item, dayNumber);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                      ),
                      icon: const Icon(Icons.map, size: 16),
                      label: const Text('Show on Map'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy': return Colors.green;
      case 'Moderate': return Colors.orange;
      case 'Challenging': return Colors.red;
      default: return Colors.grey;
    }
  }
  
  Color _getCrowdColor(String crowdLevel) {
    switch (crowdLevel) {
      case 'Low': return Colors.green;
      case 'Moderate': return Colors.orange;
      case 'High': return Colors.red;
      default: return Colors.grey;
    }
  }
  
  void _bookActivity(ItineraryItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking ${item.title}...'),
        backgroundColor: Colors.deepOrangeAccent,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
  
  void _downloadItinerary() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating PDF...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _copyItineraryLink() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Itinerary link copied to clipboard!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  void _collaborateItinerary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0E1620),
        title: const Text('Collaborate on Itinerary', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Invite others to plan together:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter email addresses',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1A2332),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Collaboration invites sent!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
            child: const Text('Send Invites'),
          ),
        ],
      ),
    );
  }

  List<MapMarker> _getItineraryMarkers() {
    final markers = <MapMarker>[];
    int pointIndex = 0;
    
    for (final day in days) {
      for (final item in day.items) {
        if (pointIndex < _routePoints.length) {
          markers.add(MapMarker(
            position: _routePoints[pointIndex],
            icon: _getIconForActivity(item.title),
            color: _getColorForDay(day.dayNumber),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.title} - Day ${day.dayNumber}'),
                  backgroundColor: Colors.deepOrangeAccent,
                ),
              );
            },
          ));
          pointIndex++;
        }
      }
    }
    
    return markers;
  }
  
  IconData _getIconForActivity(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('walk') || titleLower.contains('heritage')) return Icons.directions_walk;
    if (titleLower.contains('food') || titleLower.contains('eat')) return Icons.restaurant;
    if (titleLower.contains('museum') || titleLower.contains('cultural')) return Icons.museum;
    if (titleLower.contains('beach') || titleLower.contains('water')) return Icons.beach_access;
    if (titleLower.contains('market') || titleLower.contains('shop')) return Icons.shopping_bag;
    return Icons.place;
  }
  
  Color _getColorForDay(int dayNumber) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.purple, Colors.orange];
    return colors[(dayNumber - 1) % colors.length];
  }

  void _showOnMap(ItineraryItem item, int dayNumber) {
    setState(() => _showMap = true);
    
    // Find the marker index for this item
    int markerIndex = 0;
    bool found = false;
    
    for (final day in days) {
      for (final dayItem in day.items) {
        if (dayItem.title == item.title && day.dayNumber == dayNumber) {
          found = true;
          break;
        }
        markerIndex++;
      }
      if (found) break;
    }
    
    // Scroll to show the map and highlight marker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (markerIndex < _routePoints.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.map, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text('Showing ${item.title} on map - Day $dayNumber')),
              ],
            ),
            backgroundColor: Colors.deepOrangeAccent,
            action: SnackBarAction(
              label: context.read<LocalizationService>().getText('view_list'),
              textColor: Colors.white,
              onPressed: () => setState(() => _showMap = false),
            ),
          ),
        );
      }
    });
  }
  
  void _showActivityReviews(ItineraryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E1620),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${item.title} Reviews', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildReviewItem('Amazing experience! Highly recommended.', 5, 'Sarah M.'),
            _buildReviewItem('Good but crowded during peak hours.', 4, 'Raj K.'),
            _buildReviewItem('Worth the money, great views!', 5, 'Priya S.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddReviewDialog(item),
              child: const Text('Add Your Review'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReviewItem(String review, int rating, String author) {
    return Card(
      color: const Color(0xFF1A2332),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(5, (i) => Icon(
                  Icons.star,
                  size: 16,
                  color: i < rating ? Colors.amber : Colors.grey,
                )),
                const Spacer(),
                Text(author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(review, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
  
  void _showAddReviewDialog(ItineraryItem item) {
    int rating = 5;
    final reviewController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0E1620),
          title: Text('Review ${item.title}', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setDialogState(() => rating = i + 1),
                  child: Icon(
                    Icons.star,
                    color: i < rating ? Colors.amber : Colors.grey,
                  ),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Share your experience...',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Review added!'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------- Assistant (mock) ----------------------
class AIAssistant extends StatefulWidget {
  const AIAssistant({super.key});
  @override
  State<AIAssistant> createState() => _AIAssistantState();
}

class _AIAssistantState extends State<AIAssistant> with TickerProviderStateMixin {
  final ctrl = TextEditingController();
  final scrollController = ScrollController();
  final List<_ChatItem> messages = [ _ChatItem(false, 'Hi! I\'m your AI travel assistant. I can help with weather updates, restaurant suggestions, budget optimization, and itinerary changes. How can I help you today?') ];
  late AnimationController _typingController;
  late AnimationController _messageController;
  late AnimationController _headerController;
  bool _isTyping = false;
  ChatService? _chatService;
  bool _hasApiKey = false;
  
  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _initializeChatService();
    _headerController.forward();
  }
  
  void _initializeChatService() {
    try {
      _chatService = ChatService.instance;
      _hasApiKey = _chatService?.isConfigured ?? false;
    } catch (e) {
      _hasApiKey = false;
    }
  }
  
  @override
  void dispose() {
    _typingController.dispose();
    _messageController.dispose();
    _headerController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrangeAccent.withOpacity(0.1), const Color(0xFF0F1722)],
              ),
              border: const Border(bottom: BorderSide(color: Colors.white12))
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrangeAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.deepOrangeAccent, size: 24),
                ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(delay: 2000.ms, duration: 1000.ms),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.read<LocalizationService>().getText('ai_assistant'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      _hasApiKey ? context.read<LocalizationService>().getText('online_gemini') : context.read<LocalizationService>().getText('online_mock'), 
                      style: TextStyle(color: _hasApiKey ? Colors.green : Colors.orange, fontSize: 12)
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showAssistantInfo(),
                  icon: const Icon(Icons.info_outline, color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                if (messages.length == 1) _buildQuickSuggestions(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == messages.length && _isTyping) {
                        return _typingIndicator();
                      }
                      return _chatBubble(messages[i]);
                    }
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0F1722),
              border: Border(top: BorderSide(color: Colors.white12))
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    onSubmitted: (value) {
                      HapticFeedback.lightImpact();
                      _send();
                    },
                    decoration: InputDecoration(
                      hintText: context.read<LocalizationService>().getText('ask_assistant'),
                      filled: true,
                      fillColor: Color(0xFF0B1220),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                    )
                  )
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _send();
                  },
                  icon: const Icon(Icons.send, color: Colors.deepOrangeAccent),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent.withOpacity(0.1),
                    padding: const EdgeInsets.all(12)
                  )
                ).animate().scale(delay: 100.ms).shimmer(delay: 2000.ms)
              ]
            ),
          )
        ]
      ),
    );
  }

  Widget _chatBubble(_ChatItem m) {
    return Align(
      alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          minWidth: 60,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: m.isUser 
              ? LinearGradient(colors: [Colors.deepOrangeAccent, Colors.deepOrangeAccent.withOpacity(0.8)])
              : LinearGradient(colors: [Colors.white12, Colors.white10]),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(m.isUser ? 16 : 4),
              bottomRight: Radius.circular(m.isUser ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                child: Text(
                  m.text,
                  style: TextStyle(
                    color: m.isUser ? Colors.white : Colors.white,
                    fontSize: 14,
                  ),
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(DateTime.now()),
                style: TextStyle(
                  color: m.isUser ? Colors.white70 : Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn().slideX(begin: m.isUser ? 0.3 : -0.3),
    );
  }
  
  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('AI is typing', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(width: 8),
            SizedBox(
              width: 20,
              height: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (index) => 
                  AnimatedBuilder(
                    animation: _typingController,
                    builder: (context, child) {
                      final delay = index * 0.2;
                      final progress = (_typingController.value - delay).clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(0, -4 * sin(progress * pi)),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white54,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send([String? customMessage]) {
    final message = customMessage ?? ctrl.text.trim();
    if (message.isEmpty) return;
    
    HapticFeedback.lightImpact();
    _messageController.forward().then((_) => _messageController.reset());
    setState(() {
      messages.add(_ChatItem(true, message));
      _isTyping = true;
    });
    _scrollToBottom();
    if (customMessage == null) ctrl.clear();
    
    _typingController.repeat();
    
    _getAIResponse(message).then((response) {
      if (mounted) {
        _typingController.stop();
        setState(() {
          _isTyping = false;
          messages.add(_ChatItem(false, response));
        });
        _scrollToBottom();
      }
    });
  }

  Future<String> _getAIResponse(String message) async {
    if (!_hasApiKey || _chatService == null) {
      return "🤖 I'm here to help with your travel planning! Please configure the API connection in settings for personalized assistance.";
    }
    
    try {
      final destination = context.mounted ? 
        (context.findAncestorStateOfType<_LandingShellState>()?.tripPrefs.destination) : null;
      final budget = context.mounted ? 
        (context.findAncestorStateOfType<_LandingShellState>()?.tripPrefs.budget) : null;
      
      final conversationHistory = messages.take(messages.length - 1)
        .map((msg) => '${msg.isUser ? "User" : "Assistant"}: ${msg.text}')
        .toList();
      
      return await _chatService!.getResponse(message, 
        destination: destination, 
        budget: budget, 
        conversationHistory: conversationHistory);
    } catch (e) {
      return "I'm having trouble connecting to the AI service. Please check your internet connection and try again.";
    }
  }
  
  
  void _showAssistantInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0E1620),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.deepOrangeAccent),
            SizedBox(width: 8),
            Text('AI Assistant Info', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your AI travel companion can help with:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            const Text('• Real-time weather updates & alerts', style: TextStyle(color: Colors.white70)),
            const Text('• Local restaurant recommendations', style: TextStyle(color: Colors.white70)),
            const Text('• Budget optimization tips', style: TextStyle(color: Colors.white70)),
            const Text('• Activity & attraction suggestions', style: TextStyle(color: Colors.white70)),
            if (_hasApiKey)
              const Text(
                'Powered by backend AI service - Real-time responses!',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!', style: TextStyle(color: Colors.deepOrangeAccent))
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final localizationService = context.read<LocalizationService>();
    final suggestions = [
      {'text': localizationService.getText('check_weather_forecast'), 'icon': Icons.wb_sunny, 'color': Colors.orange},
      {'text': localizationService.getText('find_vegetarian_restaurants'), 'icon': Icons.restaurant, 'color': Colors.green},
      {'text': localizationService.getText('optimize_budget'), 'icon': Icons.savings, 'color': Colors.blue},
      {'text': localizationService.getText('suggest_activities'), 'icon': Icons.local_activity, 'color': Colors.purple},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.deepOrangeAccent, size: 16),
              const SizedBox(width: 8),
              Text(localizationService.getText('quick_suggestions'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) => 
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _send(suggestion['text'] as String);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (suggestion['color'] as Color).withOpacity(0.2),
                        (suggestion['color'] as Color).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: (suggestion['color'] as Color).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(suggestion['icon'] as IconData, 
                        color: suggestion['color'] as Color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        suggestion['text'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: suggestion['color'] as Color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (suggestions.indexOf(suggestion) * 100).ms)
                .slideX(begin: 0.3),
            ).toList(),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
/// ---------------------- Small UI Helpers & Models ----------------------
class _ChatItem {
  final bool isUser;
  final String text;
  _ChatItem(this.isUser, this.text);
}

class ItineraryItem {
  String id;
  String title;
  String description;
  String image;
  double rating;
  int reviews;
  int approxCost;
  String startTime;
  String endTime;
  int duration;
  String difficulty;
  bool isAccessible;
  String insiderTip;
  bool isOpen;
  String crowdLevel;
  List<String> localPhrases;
  String emergencyContact;
  bool hasBooking;
  int travelTimeToNext;
  double currentPrice;
  DateTime lastPriceUpdate;
  bool isCurrentlyOpen;
  List<String> alternatives;
  LatLng? location;
  
  ItineraryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.approxCost,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.difficulty = 'Easy',
    this.isAccessible = true,
    this.insiderTip = '',
    this.isOpen = true,
    this.crowdLevel = 'Moderate',
    this.localPhrases = const [],
    this.emergencyContact = '',
    this.hasBooking = false,
    this.travelTimeToNext = 15,
    required this.currentPrice,
    required this.lastPriceUpdate,
    this.isCurrentlyOpen = true,
    this.alternatives = const [],
    this.location,
  });
}

class ItineraryDay {
  int dayNumber;
  List<ItineraryItem> items;
  ItineraryDay({required this.dayNumber, required this.items});
}



/// Simple pie chart painter (no external package needed)
class BudgetPieChart extends StatelessWidget {
  final Map<String, double> data;
  const BudgetPieChart({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(double.infinity, 120), painter: _PiePainter(data));
  }
}

class _PiePainter extends CustomPainter {
  final Map<String, double> data;
  _PiePainter(this.data);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final total = data.values.fold(0.0, (a, b) => a + b);
    final colors = [Colors.blue, Colors.green, Colors.purple, Colors.orange]; // Match cost row colors
    double start = -pi / 2;
    int i = 0;
    final rect = Rect.fromLTWH(0, 0, size.height, size.height); // square
    data.forEach((k, v) {
      final sweep = total == 0 ? 0.0 : (v / total) * 2 * pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
      i++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


  


/// ---------------------- Loading Screen ----------------------
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1722),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.deepOrangeAccent),
            const SizedBox(height: 24),
            Text(context.read<LocalizationService>().getText('generating_itinerary'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(context.read<LocalizationService>().getText('take_moments'), style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 32),
            LinearProgressIndicator(
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrangeAccent),
            ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms),
          ],
        ),
      ),
    );
  }
}



/// ---------------------- Advanced Services ----------------------
class AIRecommendationEngine {
  List<String> getPersonalizedRecommendations(UserProfile profile, String destination) {
    final recommendations = <String>[];
    if (profile.travelStyle == 'Adventure') {
      recommendations.add('Try paragliding at Solang Valley');
      recommendations.add('Go for river rafting');
    } else if (profile.travelStyle == 'Luxury') {
      recommendations.add('Book a spa session');
      recommendations.add('Dine at rooftop restaurants');
    }
    return recommendations;
  }
  
  void learnFromFeedback(String activityId, bool liked) {
    // ML learning implementation
  }
}

class LocationService {
  Future<void> initialize() async {
    // Initialize location services
  }
  
  Future<LatLng?> getCurrentLocation() async {
    // Return mock location
    return LatLng(12.9716, 77.5946);
  }
  
  List<String> getNearbyAlternatives(LatLng location) {
    return ['Nearby Cafe', 'Local Market', 'Park'];
  }
}

class NotificationService {
  void initialize() {
    // Initialize push notifications
  }
  
  void showPriceAlert(PriceAlert alert, double newPrice) {
    // Show price drop notification
  }
  
  void showSmartNotification(String message) {
    // Context-aware notifications
  }
}

/// ---------------------- Tiny utilities ----------------------
void debugPrintWrapped(String text) {
  const wrap = 800;
  for (var i = 0; i < text.length; i += wrap) {
    debugPrint(text.substring(i, i + wrap > text.length ? text.length : i + wrap));
  }
}
