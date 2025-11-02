import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/responsive.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/itinerary_map_widget.dart';
import '../services/weather_service.dart';
import '../services/api_middleware.dart';
import '../providers/auth_provider.dart';
import '../providers/mock_data_provider.dart';
import '../widgets/login_button_widget.dart';
import '../models/booking.dart';

class ItineraryResultPage extends StatefulWidget {
  final Map<String, dynamic> tripConfig;

  const ItineraryResultPage({super.key, required this.tripConfig});

  @override
  State<ItineraryResultPage> createState() => _ItineraryResultPageState();
}

class _ItineraryResultPageState extends State<ItineraryResultPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _refreshController;
  late List<Animation<double>> _cardAnimations;
  final _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = true;
  int _suggestionSeed = 0;
  final Set<int> _expandedSuggestions = {};
  String? _highlightedActivityId;
  bool _showFullMap = false;
  Map<String, dynamic>? _adjustedItinerary; // Stores adjusted itinerary from smart adjust

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _refreshController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _cardAnimations = List.generate(5, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.1, 0.6 + (index * 0.1), curve: Curves.easeOut),
        ),
      );
    });
    _animationController.forward();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    final destination = widget.tripConfig['to'];
    final weather = await _weatherService.getWeather(destination);
    if (mounted) {
      setState(() {
        _weatherData = weather;
        _isLoadingWeather = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _shareItinerary(BuildContext context) {
    final destination = widget.tripConfig['to'];
    final duration = widget.tripConfig['duration'];
    final from = widget.tripConfig['from'];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing your $duration-day trip from $from to $destination...'),
        backgroundColor: const Color(0xFF007BFF),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _downloadPDF(BuildContext context) {
    final destination = widget.tripConfig['to'];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading itinerary for $destination as PDF...'),
        backgroundColor: const Color(0xFF007BFF),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Save itinerary to backend using /api/v1/saveItinerary endpoint
  /// Requires authentication - prompts login if user is not signed in
  Future<void> _saveItinerary(BuildContext context) async {
    // Check if user is authenticated
    final isAuth = await ApiMiddleware.isAuthenticated();
    
    if (!isAuth) {
      // User not logged in - prompt to sign in
      if (!mounted) return;
      
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign In Required'),
          content: const Text(
            'You need to be signed in to save your itinerary. Would you like to sign in now?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
      
      if (result == true && mounted) {
        Navigator.pushNamed(context, '/login');
      }
      return;
    }

    // User is authenticated - proceed with save
    try {
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving your itinerary...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Get trip ID from config (set by plantrip response)
      final tripId = widget.tripConfig['tripId'] ?? 'trip_${DateTime.now().millisecondsSinceEpoch}';
      
      // Prepare itinerary data
      final itineraryData = {
        'destination': widget.tripConfig['to'],
        'from': widget.tripConfig['from'],
        'startDate': (widget.tripConfig['startDate'] as DateTime).toIso8601String(),
        'endDate': (widget.tripConfig['endDate'] as DateTime).toIso8601String(),
        'duration': widget.tripConfig['duration'],
        'totalBudget': widget.tripConfig['totalBudget'],
        'peopleCount': widget.tripConfig['peopleCount'],
        'themeWeights': widget.tripConfig['themeWeights'],
        'itinerary': _adjustedItinerary ?? widget.tripConfig['itinerary'],
        'estimatedCost': widget.tripConfig['estimatedCost'],
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Call API
      final response = await ApiMiddleware.saveItinerary(
        tripId: tripId,
        itinerary: itineraryData,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (response['success'] == true) {
        // Successfully saved
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Itinerary saved successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // API error
        throw Exception(response['error'] ?? 'Failed to save itinerary');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveItinerary(context),
            ),
          ),
        );
      }
    }
  }

  /// Smart adjust itinerary using AI
  /// Opens a modal dialog for user to enter adjustment request
  /// Calls /api/v1/smartadjust endpoint
  Future<void> _smartAdjustItinerary(BuildContext context) async {
    final TextEditingController requestController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Show modal dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.auto_fix_high, color: Color(0xFF007BFF)),
              SizedBox(width: 12),
              Text('Smart Adjust Itinerary'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: MediaQuery.of(dialogContext).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tell us how you\'d like to adjust your itinerary:',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: requestController,
                    maxLines: 5,
                    minLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'E.g., "Add more beach activities", "Reduce budget by 20%", "Include more cultural sites"',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your adjustment request';
                      }
                      if (value.trim().length < 20) {
                        return 'Request must be at least 20 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI will analyze your request and adjust the itinerary accordingly.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Adjust'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    // If user cancelled, return
    if (result != true || !mounted) return;

    final userRequest = requestController.text.trim();
    if (userRequest.isEmpty) return;

    try {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('AI is adjusting your itinerary...'),
                  SizedBox(height: 8),
                  Text(
                    'This may take up to 60 seconds',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );
      }

      // Get current itinerary data (use adjusted if available, otherwise original)
      final currentItinerary = _adjustedItinerary ?? widget.tripConfig['itinerary'];

      // Call smart adjust API
      print('Calling /api/v1/smartadjust with request: $userRequest');
      print('Itinerary data: ${currentItinerary.toString().substring(0, 200)}...');
      
      final response = await ApiMiddleware.smartAdjust(
        itinerary: currentItinerary,
        userRequest: userRequest,
      );
      
      print('Smart adjust response: $response');

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (response['success'] == true) {
        final adjustedItinerary = response['data']?['adjustedItinerary'];
        final changes = response['data']?['changes'] as List<dynamic>?;

        // Update itinerary data
        if (adjustedItinerary != null && mounted) {
          setState(() {
            _adjustedItinerary = adjustedItinerary;
          });
          
          // Show success message with changes
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Itinerary adjusted successfully!'),
                      ],
                    ),
                    if (changes != null && changes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Changes made:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...changes.take(3).map((change) => Padding(
                        padding: const EdgeInsets.only(left: 8, top: 4),
                        child: Text('• $change', style: const TextStyle(fontSize: 12)),
                      )),
                    ],
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Refresh the page to show updated itinerary
            setState(() {
              _suggestionSeed++;
            });
          }
        }
      } else {
        // API error
        print('Smart adjust API error response: $response');
        throw Exception(response['error'] ?? 'Failed to adjust itinerary');
      }
    } catch (e) {
      print('Smart adjust exception: $e');
      
      // Close loading dialog if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _smartAdjustItinerary(context),
            ),
          ),
        );
      }
    } finally {
      requestController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: const SharedAppBar(title: 'Your Itinerary'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 24 : 32),
              child: isMobile || isTablet ? _buildMobileLayout(context) : _buildDesktopLayout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      width: double.infinity,
      height: isMobile ? 200 : 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF007BFF), Color(0xFF0056b3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=1200',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your ${widget.tripConfig['duration']}-Day Trip to ${widget.tripConfig['to']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'From ${widget.tripConfig['from']} • ${widget.tripConfig['peopleCount']} ${widget.tripConfig['peopleCount'] == 1 ? 'Person' : 'People'}',
                  style: TextStyle(color: Colors.white70, fontSize: isMobile ? 14 : 18),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildActionButton(context, Icons.auto_fix_high, 'Smart Adjust', () => _smartAdjustItinerary(context)),
                    _buildActionButton(context, Icons.bookmark, 'Save Trip', () => _saveItinerary(context)),
                    _buildActionButton(context, Icons.edit, 'Edit Trip', () => Navigator.pop(context)),
                    _buildActionButton(context, Icons.share, 'Share', () => _shareItinerary(context)),
                    _buildActionButton(context, Icons.download, 'Download PDF', () => _downloadPDF(context)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF007BFF),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildAnimatedCard(_buildMapSection(context), 0),
              const SizedBox(height: 24),
              _buildAnimatedCard(_buildItinerarySection(context), 1),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildAnimatedCard(_buildWeatherSection(context), 2),
              const SizedBox(height: 24),
              _buildAnimatedCard(_buildBudgetSection(context), 3),
              const SizedBox(height: 24),
              _buildAnimatedCard(_buildAIRecommendationsSection(context), 4),
              // Added 'Book This Trip' button and booking flow integration
              const SizedBox(height: 24),
              _buildBookTripButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildStickyHeader(context, 'Map & Route', Icons.map),
        _buildAnimatedCard(_buildMapSection(context), 0),
        const SizedBox(height: 20),
        _buildStickyHeader(context, 'Weather', Icons.wb_sunny),
        _buildAnimatedCard(_buildWeatherSection(context), 1),
        const SizedBox(height: 20),
        _buildStickyHeader(context, 'Budget', Icons.account_balance_wallet),
        _buildAnimatedCard(_buildBudgetSection(context), 2),
        const SizedBox(height: 20),
        _buildStickyHeader(context, 'Itinerary', Icons.calendar_today),
        _buildAnimatedCard(_buildItinerarySection(context), 3),
        const SizedBox(height: 20),
        _buildStickyHeader(context, 'AI Suggestions', Icons.lightbulb),
        _buildAnimatedCard(_buildAIRecommendationsSection(context), 4),
        // Added 'Book This Trip' button and booking flow integration
        const SizedBox(height: 20),
        _buildBookTripButton(context),
      ],
    );
  }

  Widget _buildStickyHeader(BuildContext context, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF007BFF).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF007BFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF007BFF), size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(Widget child, int index) {
    return FadeTransition(
      opacity: _cardAnimations[index],
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_cardAnimations[index]),
        child: child,
      ),
    );
  }

  Widget _buildWeatherSection(BuildContext context) {
    final destination = widget.tripConfig['to'];
    
    if (_isLoadingWeather) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShimmer(40, 40, isCircle: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmer(120, 18),
                      const SizedBox(height: 4),
                      _buildShimmer(80, 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildShimmer(double.infinity, 120, borderRadius: 12),
            const SizedBox(height: 16),
            _buildShimmer(100, 14),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildShimmer(double.infinity, 100, borderRadius: 8)),
                const SizedBox(width: 8),
                Expanded(child: _buildShimmer(double.infinity, 100, borderRadius: 8)),
                const SizedBox(width: 8),
                Expanded(child: _buildShimmer(double.infinity, 100, borderRadius: 8)),
              ],
            ),
          ],
        ),
      );
    }

    final weatherData = _parseWeatherForDisplay(_weatherData!);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wb_sunny, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weather Forecast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                    Text(destination, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [weatherData['color'].withOpacity(0.2), weatherData['color'].withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: weatherData['color'].withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(weatherData['icon'], size: 56, color: weatherData['color']),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherData['temp'],
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        weatherData['condition'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.water_drop, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text('${weatherData['humidity']}%', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontWeight: FontWeight.w500)),
                          const SizedBox(width: 12),
                          Icon(Icons.air, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text('${weatherData['wind']} km/h', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('3-Day Forecast', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weatherData['forecast'].map<Widget>((day) => _buildForecastDay(context, day)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastDay(BuildContext context, Map<String, dynamic> day) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              day['day'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Icon(day['icon'], size: 28, color: day['color']),
            const SizedBox(height: 8),
            Text(
              day['temp'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              day['condition'],
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _parseWeatherForDisplay(Map<String, dynamic> apiData) {
    final condition = apiData['condition'] ?? 'Clear';
    final temp = apiData['temperature'] ?? '25°C';
    final tempValue = int.tryParse(temp.replaceAll('°C', '')) ?? 25;
    
    final iconData = _getWeatherIcon(condition);
    
    return {
      'condition': condition,
      'icon': iconData['icon'],
      'color': iconData['color'],
      'temp': temp,
      'humidity': 50 + (tempValue % 30),
      'wind': 8 + (tempValue % 15),
      'forecast': [
        {'day': 'Today', 'temp': temp, 'condition': condition, 'icon': iconData['icon'], 'color': iconData['color']},
        {'day': 'Tomorrow', 'temp': '${tempValue + 2}°C', 'condition': 'Cloudy', 'icon': Icons.cloud, 'color': Colors.grey},
        {'day': 'Day 3', 'temp': '${tempValue - 1}°C', 'condition': 'Sunny', 'icon': Icons.wb_sunny, 'color': Colors.orange},
      ],
    };
  }

  Map<String, dynamic> _getWeatherIcon(String condition) {
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('clear') || conditionLower.contains('sunny')) {
      return {'icon': Icons.wb_sunny, 'color': Colors.orange};
    } else if (conditionLower.contains('cloud')) {
      return {'icon': Icons.wb_cloudy, 'color': Colors.blueGrey};
    } else if (conditionLower.contains('rain') || conditionLower.contains('drizzle')) {
      return {'icon': Icons.water_drop, 'color': Colors.blue};
    } else if (conditionLower.contains('snow')) {
      return {'icon': Icons.ac_unit, 'color': Colors.lightBlue};
    } else if (conditionLower.contains('thunder') || conditionLower.contains('storm')) {
      return {'icon': Icons.flash_on, 'color': Colors.amber};
    } else if (conditionLower.contains('mist') || conditionLower.contains('fog')) {
      return {'icon': Icons.cloud_queue, 'color': Colors.grey};
    }
    return {'icon': Icons.wb_sunny, 'color': Colors.orange};
  }

  Widget _buildBudgetSection(BuildContext context) {
    final totalBudget = widget.tripConfig['totalBudget'] ?? 55000;
    final travelBudget = widget.tripConfig['travelBudget'] ?? 30000;
    final foodBudget = widget.tripConfig['foodBudget'] ?? 15000;
    final accommodationBudget = widget.tripConfig['accommodationBudget'] ?? 20000;
    final activitiesBudget = widget.tripConfig['activitiesBudget'] ?? 10000;
    final othersBudget = widget.tripConfig['othersBudget'] ?? 5000;
    final peopleCount = widget.tripConfig['peopleCount'] ?? 2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF007BFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Color(0xFF007BFF), size: 20),
              ),
              const SizedBox(width: 12),
              Text('Price Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF007BFF).withOpacity(0.15), const Color(0xFF007BFF).withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF007BFF).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Trip Cost', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                    Text('₹${totalBudget.toInt()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF007BFF))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$peopleCount ${peopleCount == 1 ? 'Person' : 'People'}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
                    Text('${widget.tripConfig['duration'] ?? 5} Days', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Cost Split', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          _buildBudgetProgressBar(context, 'Travel', travelBudget, totalBudget, const Color(0xFF007BFF), Icons.flight),
          const SizedBox(height: 12),
          _buildBudgetProgressBar(context, 'Food', foodBudget, totalBudget, const Color(0xFFFF9800), Icons.restaurant),
          const SizedBox(height: 12),
          _buildBudgetProgressBar(context, 'Accommodation', accommodationBudget, totalBudget, const Color(0xFF9C27B0), Icons.hotel),
          const SizedBox(height: 12),
          _buildBudgetProgressBar(context, 'Activities', activitiesBudget, totalBudget, const Color(0xFF00BCD4), Icons.local_activity),
          const SizedBox(height: 12),
          _buildBudgetProgressBar(context, 'Others', othersBudget, totalBudget, const Color(0xFF4CAF50), Icons.shopping_bag),
          const Divider(height: 32),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 18, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(width: 8),
                    Text('Cost Per Person', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
                Text('₹${(totalBudget / peopleCount).toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF007BFF))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetProgressBar(BuildContext context, String label, double amount, double total, Color color, IconData icon) {
    final percentage = (amount / total * 100).toInt();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            Text('₹${amount.toInt()}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: (amount / total).clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('$percentage% of total', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
      ],
    );
  }

  Widget _buildMapSection(BuildContext context) {
    final activities = _getAllActivities();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007BFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.map, color: Color(0xFF007BFF), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('Interactive Map', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _showFullMapModal(context, activities),
                  icon: const Icon(Icons.fullscreen, size: 18),
                  label: const Text('🗺 Expand Map'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF007BFF)),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: SizedBox(
              height: 300,
              child: ItineraryMapWidget(
                activities: activities,
                highlightedActivityId: _highlightedActivityId,
                onMarkerTap: (activityId) {
                  setState(() {
                    _highlightedActivityId = activityId;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAllActivities() {
    final itineraryData = (_adjustedItinerary ?? widget.tripConfig['itinerary']) as Map<String, dynamic>?;
    final days = itineraryData?['days'] as List<dynamic>? ?? [];
    
    final activities = <Map<String, dynamic>>[];
    for (var day in days) {
      final dayActivities = day['activities'] as List<dynamic>? ?? [];
      for (var activity in dayActivities) {
        final activityMap = activity as Map<String, dynamic>;
        // Add mock coordinates if not present
        if (activityMap['lat'] == null || activityMap['lng'] == null) {
          activityMap['lat'] = 28.6139 + (activities.length * 0.01);
          activityMap['lng'] = 77.2090 + (activities.length * 0.01);
        }
        activities.add(activityMap);
      }
    }
    return activities;
  }

  void _showFullMapModal(BuildContext context, List<Map<String, dynamic>> activities) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 800),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.map, color: Color(0xFF007BFF), size: 24),
                        const SizedBox(width: 12),
                        Text('Full Map View', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ItineraryMapWidget(
                      activities: activities,
                      highlightedActivityId: _highlightedActivityId,
                      onMarkerTap: (activityId) {
                        setState(() {
                          _highlightedActivityId = activityId;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItinerarySection(BuildContext context) {
    final itineraryData = (_adjustedItinerary ?? widget.tripConfig['itinerary']) as Map<String, dynamic>?;
    final days = itineraryData?['days'] as List<dynamic>? ?? [];
    final duration = days.isNotEmpty ? days.length : (widget.tripConfig['duration'] ?? 5);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF007BFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today, color: Color(0xFF007BFF), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  itineraryData?['title'] ?? 'Daily Itinerary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (days.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'No itinerary generated yet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please generate a new trip',
                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.outline),
                    ),
                  ],
                ),
              ),
            )
          else
            ...days.asMap().entries.map((entry) {
              final index = entry.key;
              final dayData = entry.value as Map<String, dynamic>;
              return _buildDaySection(context, dayData, index, index == days.length - 1);
            }),
        ],
      ),
    );
  }

  Widget _buildDaySection(BuildContext context, Map<String, dynamic> dayData, int index, bool isLast) {
    final dayNumber = dayData['day'] ?? (index + 1);
    final activities = dayData['activities'] as List<dynamic>? ?? [];
    final isExpanded = _expandedSuggestions.contains(index);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF007BFF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007BFF).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$dayNumber',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF007BFF).withOpacity(0.5),
                          const Color(0xFF007BFF).withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedSuggestions.remove(index);
                        } else {
                          _expandedSuggestions.add(index);
                        }
                      });
                    },
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Day $dayNumber – Activities',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            '${activities.length} activities',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: const Color(0xFF007BFF),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: [
                        ...activities.map((activity) => _buildActivityCard(context, activity as Map<String, dynamic>)),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.chat, size: 18),
                              label: const Text('💬 Ask AI for suggestions'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF007BFF),
                                side: const BorderSide(color: Color(0xFF007BFF)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Map<String, dynamic> activity) {
    final title = activity['title'] ?? 'No title';
    final description = activity['description'] ?? 'No description available';
    final durationMins = activity['durationMins'] ?? 0;
    final cost = activity['cost'] ?? 0;
    final timeOfDay = activity['timeOfDay'] ?? 'morning';
    final category = activity['category'] ?? 'heritage';
    final safetyNote = activity['safetyNote'];
    final bookingRequired = activity['bookingRequired'] ?? false;
    final activityId = activity['id'];
    final isHighlighted = activityId == _highlightedActivityId;

    final hours = durationMins ~/ 60;
    final mins = durationMins % 60;
    final durationText = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return InkWell(
      onTap: () {
        setState(() {
          _highlightedActivityId = activityId;
        });
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted 
                ? const Color(0xFF007BFF) 
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: isHighlighted ? 2 : 1,
          ),
          boxShadow: isHighlighted ? [
            BoxShadow(
              color: const Color(0xFF007BFF).withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ] : null,
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getTimeOfDayIcon(timeOfDay),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (bookingRequired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, size: 12, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        'Booking Required',
                        style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildInfoChip(context, Icons.schedule, 'Duration: $durationText'),
              _buildInfoChip(context, Icons.currency_rupee, '₹$cost'),
              _buildCategoryBadge(context, category),
            ],
          ),
          if (safetyNote != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      safetyNote,
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (activityId != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  'Tap to view on map',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF007BFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ));
  }

  Widget _getTimeOfDayIcon(String timeOfDay) {
    switch (timeOfDay.toLowerCase()) {
      case 'morning':
        return const Text('☀️', style: TextStyle(fontSize: 20));
      case 'afternoon':
        return const Text('🌆', style: TextStyle(fontSize: 20));
      case 'evening':
        return const Text('🌃', style: TextStyle(fontSize: 20));
      default:
        return const Icon(Icons.access_time, size: 20, color: Color(0xFF007BFF));
    }
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context, String category) {
    final categoryColors = {
      'heritage': Colors.amber,
      'food': Colors.green,
      'nightlife': Colors.purple,
      'adventure': Colors.orange,
      'nature': Colors.teal,
      'relaxation': Colors.blue,
      'shopping': Colors.pink,
    };

    final color = categoryColors[category.toLowerCase()] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTimelineDay(BuildContext context, int day, bool isLast) {
    final dayData = _getDayData(day);
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF007BFF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007BFF).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(dayData['icon'], color: Colors.white, size: 24),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF007BFF).withOpacity(0.5),
                          const Color(0xFF007BFF).withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
              ),
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
                              dayData['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getDayDate(day),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (dayData['thumbnail'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            dayData['thumbnail'],
                            width: 80,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 80,
                              height: 60,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Icon(Icons.image, color: Theme.of(context).colorScheme.outline),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dayData['description'],
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (dayData['highlights'] as List<Map<String, dynamic>>).map((highlight) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getActivityColor(highlight['type']).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _getActivityColor(highlight['type']).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getActivityIcon(highlight['type']),
                            size: 14,
                            color: _getActivityColor(highlight['type']),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            highlight['label'],
                            style: TextStyle(
                              fontSize: 12,
                              color: _getActivityColor(highlight['type']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getDayData(int day) {
    final dayDataList = [
      {
        'title': 'Day 1 – Arrival & City Tour',
        'icon': Icons.flight_land,
        'description': 'Arrive at your destination and check into your hotel. Start with a guided city tour covering major landmarks and historical sites. Evening at leisure to explore local markets and cuisine.',
        'thumbnail': 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=200&h=150&fit=crop',
        'highlights': [
          {'type': 'Heritage', 'label': 'City Palace'},
          {'type': 'Food', 'label': 'Local Cuisine'},
        ],
      },
      {
        'title': 'Day 2 – Heritage & Culture',
        'icon': Icons.account_balance,
        'description': 'Explore ancient forts and palaces with expert guides. Visit museums showcasing local art and history. Enjoy traditional lunch at a heritage restaurant followed by a cultural show in the evening.',
        'thumbnail': 'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=200&h=150&fit=crop',
        'highlights': [
          {'type': 'Heritage', 'label': 'Fort Visit'},
          {'type': 'Nightlife', 'label': 'Cultural Show'},
        ],
      },
      {
        'title': 'Day 3 – Adventure & Nature',
        'icon': Icons.terrain,
        'description': 'Experience thrilling outdoor activities including trekking, zip-lining, or hot air balloon rides. Visit scenic viewpoints and natural landmarks. Relax with a spa session in the evening.',
        'thumbnail': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=200&h=150&fit=crop',
        'highlights': [
          {'type': 'Adventure', 'label': 'Trekking'},
          {'type': 'Relaxation', 'label': 'Spa'},
        ],
      },
      {
        'title': 'Day 4 – Local Experiences',
        'icon': Icons.restaurant,
        'description': 'Immerse yourself in local life with cooking classes, craft workshops, and market tours. Taste authentic street food and interact with local artisans. Evening rooftop dinner with city views.',
        'thumbnail': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200&h=150&fit=crop',
        'highlights': [
          {'type': 'Food', 'label': 'Cooking Class'},
          {'type': 'Heritage', 'label': 'Craft Workshop'},
        ],
      },
      {
        'title': 'Day 5 – Departure & Shopping',
        'icon': Icons.shopping_bag,
        'description': 'Final day for souvenir shopping at local bazaars and malls. Visit any remaining attractions on your wishlist. Check out from hotel and transfer to airport with wonderful memories.',
        'thumbnail': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=200&h=150&fit=crop',
        'highlights': [
          {'type': 'Heritage', 'label': 'Shopping'},
          {'type': 'Relaxation', 'label': 'Leisure Time'},
        ],
      },
    ];
    
    return dayDataList[(day - 1) % dayDataList.length];
  }

  String _getDayDate(int day) {
    final startDate = widget.tripConfig['startDate'] as DateTime;
    final date = startDate.add(Duration(days: day - 1));
    return '${date.day}/${date.month}/${date.year}';
  }



  List<Map<String, dynamic>> _getMockActivities(int day) {
    final activities = [
      [
        {'time': '09:00 AM', 'type': 'Heritage', 'title': 'Visit Amber Fort', 'description': 'Explore the magnificent Amber Fort with guided tour'},
        {'time': '01:00 PM', 'type': 'Food', 'title': 'Lunch at Chokhi Dhani', 'description': 'Traditional Rajasthani cuisine'},
        {'time': '04:00 PM', 'type': 'Heritage', 'title': 'City Palace Tour', 'description': 'Royal residence with museums'},
        {'time': '07:00 PM', 'type': 'Relaxation', 'title': 'Evening at Jal Mahal', 'description': 'Sunset views at Water Palace'},
      ],
      [
        {'time': '08:00 AM', 'type': 'Adventure', 'title': 'Hot Air Balloon Ride', 'description': 'Aerial views of the Pink City'},
        {'time': '11:00 AM', 'type': 'Heritage', 'title': 'Hawa Mahal Visit', 'description': 'Palace of Winds photography'},
        {'time': '02:00 PM', 'type': 'Food', 'title': 'Street Food Tour', 'description': 'Explore local markets and cuisine'},
        {'time': '06:00 PM', 'type': 'Nightlife', 'title': 'Rooftop Dinner', 'description': 'City lights and live music'},
      ],
      [
        {'time': '10:00 AM', 'type': 'Nature', 'title': 'Jaigarh Fort Trek', 'description': 'Hiking with panoramic views'},
        {'time': '01:00 PM', 'type': 'Food', 'title': 'Lunch at Peacock Rooftop', 'description': 'Continental and Indian fusion'},
        {'time': '04:00 PM', 'type': 'Heritage', 'title': 'Jantar Mantar Observatory', 'description': 'Ancient astronomical instruments'},
        {'time': '07:00 PM', 'type': 'Relaxation', 'title': 'Spa & Wellness', 'description': 'Traditional Ayurvedic massage'},
      ],
      [
        {'time': '09:00 AM', 'type': 'Adventure', 'title': 'Elephant Safari', 'description': 'Ride through Aravalli hills'},
        {'time': '12:00 PM', 'type': 'Food', 'title': 'Royal Thali Experience', 'description': 'Multi-course traditional meal'},
        {'time': '03:00 PM', 'type': 'Heritage', 'title': 'Albert Hall Museum', 'description': 'Art and artifacts collection'},
        {'time': '06:00 PM', 'type': 'Nightlife', 'title': 'Cultural Show & Dinner', 'description': 'Folk dance and music performance'},
      ],
      [
        {'time': '08:00 AM', 'type': 'Nature', 'title': 'Nahargarh Fort Sunrise', 'description': 'Early morning trek and views'},
        {'time': '11:00 AM', 'type': 'Food', 'title': 'Brunch at Tapri', 'description': 'Rooftop cafe with city views'},
        {'time': '02:00 PM', 'type': 'Heritage', 'title': 'Bapu Bazaar Shopping', 'description': 'Handicrafts and textiles'},
        {'time': '05:00 PM', 'type': 'Relaxation', 'title': 'Departure Preparation', 'description': 'Pack and relax at hotel'},
      ],
    ];
    
    return activities[(day - 1) % activities.length];
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'Heritage': return Icons.account_balance;
      case 'Adventure': return Icons.terrain;
      case 'Food': return Icons.restaurant;
      case 'Nightlife': return Icons.nightlife;
      case 'Nature': return Icons.nature;
      case 'Relaxation': return Icons.spa;
      default: return Icons.place;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'Heritage': return Colors.purple;
      case 'Adventure': return Colors.orange;
      case 'Food': return Colors.red;
      case 'Nightlife': return Colors.indigo;
      case 'Nature': return Colors.green;
      case 'Relaxation': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Widget _buildShimmer(double width, double height, {bool isCircle = false, double borderRadius = 8}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(value),
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildAIRecommendationsSection(BuildContext context) {
    final suggestions = _getAISuggestions();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF007BFF).withOpacity(0.2), const Color(0xFF00D4FF).withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFF007BFF), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Smart Suggestions for Your Trip',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: _regenerateSuggestions,
                icon: RotationTransition(
                  turns: Tween<double>(begin: 0, end: 1).animate(_refreshController),
                  child: const Icon(Icons.refresh, size: 22),
                ),
                tooltip: 'Regenerate Suggestions',
                color: const Color(0xFF007BFF),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...suggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestion = {...entry.value, 'index': index};
            return _buildSuggestionCard(context, suggestion, index == suggestions.length - 1);
          }),
        ],
      ),
    );
  }

  void _regenerateSuggestions() {
    _refreshController.forward(from: 0);
    setState(() {
      _suggestionSeed++;
      _expandedSuggestions.clear();
    });
  }

  Widget _buildSuggestionCard(BuildContext context, Map<String, dynamic> suggestion, bool isLast) {
    final index = suggestion['index'] as int;
    final isExpanded = _expandedSuggestions.contains(index);
    final hasExpandableContent = suggestion['tip'] != null || suggestion['learnMore'] != null;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: suggestion['color'].withOpacity(0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: hasExpandableContent ? () {
              setState(() {
                if (isExpanded) {
                  _expandedSuggestions.remove(index);
                } else {
                  _expandedSuggestions.add(index);
                }
              });
            } : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: suggestion['color'].withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(suggestion['icon'], color: suggestion['color'], size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          suggestion['title'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      if (hasExpandableContent)
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Theme.of(context).colorScheme.outline,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    suggestion['description'],
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      letterSpacing: 0.1,
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (suggestion['tip'] != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: suggestion['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.tips_and_updates, size: 16, color: suggestion['color']),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    suggestion['tip'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (suggestion['learnMore'] != null) ...[
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {},
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Learn More',
                                  style: TextStyle(
                                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                                    color: suggestion['color'],
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward, size: 14, color: suggestion['color']),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAISuggestions() {
    // Check if essential data is available
    if (widget.tripConfig['to'] == null || widget.tripConfig['duration'] == null) {
      return _getDefaultSuggestions();
    }

    // Use seed to shuffle suggestions on regenerate
    final random = _suggestionSeed;

    final destination = widget.tripConfig['to'];
    final from = widget.tripConfig['from'] ?? 'your location';
    final duration = widget.tripConfig['duration'] ?? 5;
    final budget = widget.tripConfig['totalBudget'] ?? 55000;
    final peopleCount = widget.tripConfig['peopleCount'] ?? 2;
    final preferences = widget.tripConfig['additionalPreferences'] ?? '';
    final themeWeights = widget.tripConfig['themeWeights'] as Map<String, double>? ?? {};
    final startDate = widget.tripConfig['startDate'] as DateTime? ?? DateTime.now();
    final month = startDate.month;
    
    final isVegetarian = preferences.toLowerCase().contains('vegetarian') || preferences.toLowerCase().contains('veg');
    final hasPets = preferences.toLowerCase().contains('pet') || preferences.toLowerCase().contains('dog') || preferences.toLowerCase().contains('cat');
    final needsAccessibility = preferences.toLowerCase().contains('wheelchair') || preferences.toLowerCase().contains('accessibility');
    final isSummer = month >= 4 && month <= 6;
    final isMonsoon = month >= 7 && month <= 9;
    final isWinter = month >= 11 || month <= 2;
    
    final weatherTemp = _weatherData?['temperature']?.replaceAll('°C', '') ?? '25';
    final temp = int.tryParse(weatherTemp) ?? 25;
    final isHot = temp > 30;
    
    List<Map<String, dynamic>> suggestions = [];

    // Nearby Attractions
    suggestions.add({
      'icon': Icons.place,
      'color': const Color(0xFF007BFF),
      'title': 'Nearby Attractions (Within 20km)',
      'description': _getNearbyAttractions(destination),
      'tip': 'Use local buses or shared autos to reach these spots - costs under ₹50',
      'learnMore': true,
    });

    // Weather-based timing
    if (isHot || isSummer) {
      suggestions.add({
        'icon': Icons.wb_sunny,
        'color': Colors.orange,
        'title': 'Beat the Heat - Best Visit Times',
        'description': 'Current temperature is ${temp}°C. Visit outdoor attractions before 10 AM or after 5 PM. Indoor museums and air-conditioned malls are perfect for 11 AM-4 PM.',
        'tip': 'Carry sunscreen (SPF 50+), hat, and stay hydrated with 3-4 liters of water daily',
      });
    } else if (isMonsoon) {
      suggestions.add({
        'icon': Icons.umbrella,
        'color': Colors.blue,
        'title': 'Monsoon Travel Tips',
        'description': 'Pack waterproof bags and quick-dry clothes. Indoor attractions like museums and galleries are ideal. Enjoy hot street food and chai at covered markets.',
        'tip': 'Book covered transport in advance - outdoor activities may get cancelled',
      });
    } else if (isWinter) {
      suggestions.add({
        'icon': Icons.ac_unit,
        'color': Colors.lightBlue,
        'title': 'Winter Travel - Perfect Weather',
        'description': 'Ideal season for sightseeing! Visit outdoor attractions anytime 9 AM-6 PM. Enjoy rooftop dining and evening walks. Pack light woolens for mornings/evenings.',
        'tip': 'Book sunrise tours and early morning hot air balloon rides for best experience',
      });
    }

    // Food recommendations
    if (isVegetarian) {
      suggestions.add({
        'icon': Icons.restaurant,
        'color': Colors.green,
        'title': 'Vegetarian Food Paradise',
        'description': '$destination has excellent pure-veg restaurants. Try local thalis (₹150-300), street snacks at evening markets, and temple prasad. Budget ₹${(budget * 0.12 / duration / peopleCount).toInt()}/person/day.',
        'tip': 'Look for "Satvik" or "Jain" restaurants for pure vegetarian meals without onion/garlic',
        'learnMore': true,
      });
    } else {
      suggestions.add({
        'icon': Icons.restaurant_menu,
        'color': Colors.orange,
        'title': 'Must-Try Local Cuisine',
        'description': 'Explore street food at local markets (budget ₹${(budget * 0.15 / duration / peopleCount).toInt()}/person/day). Try regional specialties at family-run eateries. Food tours available for ₹800-1200.',
        'tip': 'Download Zomato/Swiggy for reviews. Avoid roadside water - stick to bottled/filtered',
        'learnMore': true,
      });
    }

    // Cultural etiquette
    suggestions.add({
      'icon': Icons.temple_hindu,
      'color': Colors.purple,
      'title': 'Cultural Etiquette & Dress Code',
      'description': 'Remove shoes at temples/homes. Dress modestly at religious sites (covered shoulders/knees). Ask permission before photographing locals. Avoid public displays of affection.',
      'tip': 'Carry a scarf/shawl for temple visits. Most accept UPI/cards but keep ₹500 cash for donations',
    });

    // Accessibility
    if (needsAccessibility) {
      suggestions.add({
        'icon': Icons.accessible,
        'color': Colors.blue,
        'title': 'Wheelchair Accessibility Info',
        'description': 'Major attractions have ramps and accessible toilets. Book accessible taxis via Uber/Ola (select "Wheelchair Accessible"). Hotels with elevators recommended.',
        'tip': 'Call attractions in advance to confirm accessibility. Carry medical documents',
        'learnMore': true,
      });
    }

    // Pet-friendly
    if (hasPets) {
      suggestions.add({
        'icon': Icons.pets,
        'color': Colors.brown,
        'title': 'Pet-Friendly Travel Tips',
        'description': 'Book pet-friendly hotels in advance (₹500-1000 extra/night). Carry vaccination certificates. Many parks and outdoor cafes welcome pets. Avoid crowded temples/monuments.',
        'tip': 'Pack pet food, water bowl, leash, and waste bags. Find nearby vets on Google Maps',
      });
    }

    // Theme-based suggestions
    _addThemeBasedSuggestions(suggestions, themeWeights, destination, budget, duration, peopleCount);

    // Travel hacks
    suggestions.add({
      'icon': Icons.lightbulb,
      'color': Colors.amber,
      'title': 'Time-Saving Travel Hacks',
      'description': 'Book combo tickets online for 20-30% off. Use metro/local buses (save 60% vs taxis). Visit popular spots on weekday mornings. Download offline maps to save data charges.',
      'tip': 'Get a local SIM (₹200-300) for unlimited data. Use Google Pay/Paytm for cashless payments',
    });

    // Photo spots
    suggestions.add({
      'icon': Icons.photo_camera,
      'color': Colors.pink,
      'title': 'Instagram-Worthy Photo Spots',
      'description': 'Golden hour (6-7 AM, 5-6 PM) for best lighting. Rooftop cafes for city views. Local markets for vibrant colors. Heritage sites at sunrise for empty frames.',
      'tip': 'Hire local photographers for ₹1500-3000/hour. Respect "No Photography" signs at religious sites',
      'learnMore': true,
    });

    // Shuffle and return top 5 based on seed
    if (_suggestionSeed > 0) {
      suggestions.shuffle();
    }
    return suggestions.take(5).toList();
  }

  String _getNearbyAttractions(String destination) {
    return 'Explore heritage sites, local markets, parks, viewpoints, and cultural centers within 20km of $destination. Visit tourist information centers or ask hotel staff for popular nearby attractions, hidden gems, and day-trip options.';
  }

  void _addThemeBasedSuggestions(List<Map<String, dynamic>> suggestions, Map<String, double> themeWeights, String destination, double budget, int duration, int peopleCount) {
    final sortedThemes = themeWeights.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedThemes.isEmpty) return;

    final topTheme = sortedThemes.first.key;
    final budgetPerDay = (budget / duration / peopleCount).toInt();

    switch (topTheme) {
      case 'Adventure':
        suggestions.add({
          'icon': Icons.terrain,
          'color': Colors.orange,
          'title': 'Adventure Activities in $destination',
          'description': 'Try trekking, zip-lining, rock climbing, or water sports. Book adventure packages (₹${budgetPerDay * 2}-${budgetPerDay * 4}) through certified operators. Best time: early morning for outdoor activities.',
          'tip': 'Carry comfortable shoes, sunscreen, and book activities 2-3 days in advance',
          'learnMore': true,
        });
        break;
      case 'Heritage':
        suggestions.add({
          'icon': Icons.account_balance,
          'color': Colors.purple,
          'title': 'Heritage Sites & Museums',
          'description': 'Explore historical monuments, museums, and archaeological sites in $destination. Hire local guides (₹500-1000) for detailed history. Many sites offer audio guides and combo tickets.',
          'tip': 'Visit UNESCO World Heritage sites early morning. Photography may require extra permits',
          'learnMore': true,
        });
        break;
      case 'Relaxation':
        suggestions.add({
          'icon': Icons.spa,
          'color': Colors.blue,
          'title': 'Wellness & Relaxation Spots',
          'description': 'Book spa treatments (₹${budgetPerDay}-${budgetPerDay * 2}), visit wellness centers, or enjoy peaceful gardens and lakeside spots. Yoga and meditation sessions available at many resorts.',
          'tip': 'Book spa appointments in advance. Try local Ayurvedic treatments for authentic experience',
        });
        break;
      case 'Nightlife':
        suggestions.add({
          'icon': Icons.nightlife,
          'color': Colors.indigo,
          'title': 'Nightlife & Entertainment',
          'description': 'Explore rooftop bars, live music venues, night markets, and cultural shows in $destination. Budget ₹${budgetPerDay}-${budgetPerDay * 2} per evening. Check local event calendars.',
          'tip': 'Book popular venues in advance. Use ride-sharing apps for safe late-night travel',
          'learnMore': true,
        });
        break;
      case 'Food':
        suggestions.add({
          'icon': Icons.restaurant,
          'color': Colors.red,
          'title': 'Food Tours & Culinary Experiences',
          'description': 'Join food walking tours (₹800-1500), cooking classes (₹${budgetPerDay * 2}), or visit famous local eateries. Try street food at evening markets and heritage restaurants.',
          'tip': 'Book food tours through verified platforms. Carry digestive tablets for street food',
          'learnMore': true,
        });
        break;
      case 'Nature':
        suggestions.add({
          'icon': Icons.nature,
          'color': Colors.green,
          'title': 'Nature & Nightlife Experiences',
          'description': 'Visit national parks, botanical gardens, nature trails, and nightlife spots near $destination. Safari bookings (₹${budgetPerDay * 3}-${budgetPerDay * 5}) require advance reservation.',
          'tip': 'Carry binoculars, wear neutral colors for nature spotting. Best time: early morning',
          'learnMore': true,
        });
        break;
    }
  }

  List<Map<String, dynamic>> _getDefaultSuggestions() {
    return [
      {
        'icon': Icons.explore,
        'color': const Color(0xFF007BFF),
        'title': 'Plan Your Perfect Trip',
        'description': 'Complete your trip details to get personalized AI-powered recommendations based on your destination, preferences, and travel style.',
        'tip': 'Add your budget, themes, and special requirements for tailored suggestions',
      },
      {
        'icon': Icons.tips_and_updates,
        'color': Colors.orange,
        'title': 'Smart Travel Tips',
        'description': 'Book accommodations and transport in advance for better rates. Download offline maps and translation apps. Keep digital copies of important documents.',
        'tip': 'Travel insurance is recommended for all trips. Check visa requirements early',
      },
      {
        'icon': Icons.savings,
        'color': Colors.green,
        'title': 'Save Money While Traveling',
        'description': 'Use local transport, eat at local restaurants, and book combo tickets for attractions. Travel during off-peak seasons for 30-40% savings on hotels and flights.',
        'tip': 'Sign up for travel reward programs and use cashback credit cards',
      },
    ];
  }

  // Added 'Book This Trip' button and booking flow integration
  Widget _buildBookTripButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _handleBookTrip(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007BFF),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: const Color(0xFF007BFF).withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) => states.contains(MaterialState.hovered)
                ? const Color(0xFF0056b3)
                : const Color(0xFF007BFF),
          ),
        ),
        child: const Text(
          'Book This Trip',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Fixed issue: booking process continues automatically after login when user clicks Book My Trip while logged out
  void _handleBookTrip(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => LoginModal(
          onLoginSuccess: () {
            Navigator.of(dialogContext).pop();
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _showBookingConfirmation(context);
              }
            });
          },
        ),
      );
    } else {
      _showBookingConfirmation(context);
    }
  }

  void _showBookingConfirmation(BuildContext context) {
    final destination = widget.tripConfig['to'];
    final from = widget.tripConfig['from'];
    final duration = widget.tripConfig['duration'];
    final totalBudget = widget.tripConfig['totalBudget'] ?? 55000;
    final startDate = widget.tripConfig['startDate'] as DateTime?;
    final endDate = widget.tripConfig['endDate'] as DateTime?;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007BFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.confirmation_number, color: Color(0xFF007BFF), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Confirm Your Trip Booking',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildConfirmationRow(Icons.location_on, 'Destination', destination),
              const SizedBox(height: 12),
              _buildConfirmationRow(Icons.flight_takeoff, 'From', from),
              const SizedBox(height: 12),
              _buildConfirmationRow(Icons.calendar_today, 'Duration', '$duration days'),
              const SizedBox(height: 12),
              if (startDate != null && endDate != null)
                _buildConfirmationRow(Icons.date_range, 'Dates', '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}'),
              const SizedBox(height: 12),
              _buildConfirmationRow(Icons.currency_rupee, 'Total Cost', '₹${totalBudget.toInt()}'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF007BFF)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _confirmBooking(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Confirm Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildConfirmationRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF007BFF)),
        const SizedBox(width: 12),
        Text('$label:', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 14), textAlign: TextAlign.end),
        ),
      ],
    );
  }

  Future<void> _confirmBooking(BuildContext dialogContext) async {
    Navigator.pop(dialogContext);
    
    // Added 'Book This Trip' button and booking persistence in My Trips section
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final mockProvider = Provider.of<MockDataProvider>(context, listen: false);
    
    final destination = widget.tripConfig['to'];
    final totalBudget = widget.tripConfig['totalBudget'] ?? 55000;
    final startDate = widget.tripConfig['startDate'] as DateTime?;
    final endDate = widget.tripConfig['endDate'] as DateTime?;
    final duration = widget.tripConfig['duration'] ?? 5;
    
    // Check if trip already booked
    final existingBookings = mockProvider.getBookings();
    final alreadyBooked = existingBookings.any((b) => 
      b.itineraryId.contains(destination) && 
      b.amount == totalBudget
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);
      
      if (alreadyBooked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This trip is already in My Trips.'),
            backgroundColor: Color(0xFFFF9800),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      
      // Create booking
      final booking = Booking(
        id: 'BK${DateTime.now().millisecondsSinceEpoch}',
        itineraryId: 'itin_${destination.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        userName: authProvider.user?.name ?? 'Guest',
        email: authProvider.user?.email ?? 'guest@example.com',
        amount: totalBudget.toDouble(),
        timestamp: DateTime.now(),
      );
      
      mockProvider.saveBooking(booking);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Trip successfully booked! You can view it in My Trips.'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/my-trips'),
          ),
        ),
      );
    }
  }
}
