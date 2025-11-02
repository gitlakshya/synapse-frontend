import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config.dart';
import 'services/map_init_service.dart' if (dart.library.io) 'services/map_init_service_stub.dart';
import 'services/api_middleware.dart';
import 'theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_state.dart';
import 'providers/trip_planner_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/mock_data_provider.dart';
import 'providers/language_provider.dart';
import 'providers/chat_provider.dart';
import 'widgets/ai_chat_widget.dart';
import 'widgets/login_button_widget.dart';
import 'pages/hero_page.dart';
import 'screens/home_page.dart'; // Legacy - to be removed
import 'screens/ai_result_screen.dart' deferred as ai_result;
import 'screens/booking_page.dart' deferred as booking;
import 'screens/login_page.dart' deferred as login;
import 'screens/offers_page.dart' deferred as offers;
import 'screens/my_trips_page.dart' deferred as trips;
import 'screens/privacy_page.dart';
import 'screens/terms_page.dart';
import 'screens/flights_screen.dart';
import 'screens/hotels_screen.dart';
import 'screens/trains_screen.dart';
import 'screens/buses_screen.dart';
import 'screens/cabs_screen.dart';
import 'screens/careers_screen.dart';
import 'screens/partners_screen.dart';
import 'screens/support_screen.dart';
import 'screens/about_page.dart';
import 'screens/how_it_works_page.dart';
import 'screens/blog_list_page.dart';
import 'screens/faqs_page.dart';
import 'screens/cancellation_policy_page.dart';
import 'screens/itinerary_setup_page.dart';
import 'screens/itinerary_result_page.dart';
import 'screens/trip_summary_page.dart';
import 'utils/page_transitions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only if keys are configured
  if (Config.firebaseApiKey.isNotEmpty && Config.firebaseProjectId.isNotEmpty) {
    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: Config.firebaseApiKey,
          appId: Config.firebaseAppId,
          messagingSenderId: Config.firebaseMessagingSenderId,
          projectId: Config.firebaseProjectId,
        ),
      );
    } catch (e) {
      print('Firebase initialization failed: $e');
    }
  }
  
  // Initialize guest session for API calls
  // This ensures sessionId is ready before any API calls are made
  try {
    final isAuth = await ApiMiddleware.isAuthenticated();
    if (!isAuth) {
      // User is not authenticated, ensure guest session exists
      print('Creating guest session for API access...');
      // Guest session will be auto-created on first API call
    } else {
      print('User authenticated, using existing token');
    }
  } catch (e) {
    print('Session initialization warning: $e');
    // Continue app launch - session will be created on first API call
  }
  
  runApp(const EaseMyTripAIApp());
  
  // Initialize Google Maps API key after app starts (for web)
  if (kIsWeb) {
    Future.delayed(const Duration(milliseconds: 100), () {
      MapInitService.injectGoogleMapsApiKey();
    });
  }
}

class EaseMyTripAIApp extends StatelessWidget {
  const EaseMyTripAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockDataProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => TripPlannerProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) => MaterialApp(
            title: 'EaseMyTrip AI Planner',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: '/',
          builder: (context, child) {
            return Stack(
              children: [
                child!,
                // FIX: Added login gating for AI Chat button.
                // Ensures non-logged-in users see login popup before using chat.
                Consumer2<ChatProvider, AuthProvider>(
                  builder: (context, chatProvider, authProvider, _) {
                    return Positioned(
                      bottom: 24,
                      right: 24,
                      child: AnimatedScale(
                        scale: chatProvider.isOpen ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: _PulsingChatButton(
                          onPressed: () {
                            if (!authProvider.isAuthenticated) {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (dialogContext) => LoginModal(
                                  onLoginSuccess: () {
                                    Navigator.of(dialogContext).pop();
                                    Future.delayed(const Duration(milliseconds: 300), () {
                                      chatProvider.toggleChat();
                                    });
                                  },
                                ),
                              );
                            } else {
                              chatProvider.toggleChat();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) {
                    if (!chatProvider.isOpen) return const SizedBox.shrink();
                    return Positioned(
                      bottom: 20,
                      right: 20,
                      child: AIChatWindow(onClose: chatProvider.closeChat),
                    );
                  },
                ),
              ],
            );
          },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const HeroPage());
            case '/ai-result':
              return FadeSlidePageRoute(
                page: FutureBuilder(
                  future: ai_result.loadLibrary(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return ai_result.AIResultScreen();
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              );
            case '/generate':
              final args = settings.arguments as Map<String, dynamic>;
              return FadeSlidePageRoute(
                page: ItinerarySetupPage(tripData: args),
              );
            case '/itinerary':
              final args = settings.arguments as Map<String, dynamic>;
              return FadeSlidePageRoute(
                page: ItineraryResultPage(tripConfig: args),
              );
            case '/booking':
              return FadeSlidePageRoute(
                page: FutureBuilder(
                  future: booking.loadLibrary(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return booking.BookingPage();
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              );
            case '/login':
              return ScalePageRoute(
                page: FutureBuilder(
                  future: login.loadLibrary(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return login.LoginPage();
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              );
            case '/offers':
              return FadeSlidePageRoute(
                page: FutureBuilder(
                  future: offers.loadLibrary(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return offers.OffersPage();
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              );
            case '/my-trips':
              return FadeSlidePageRoute(
                page: FutureBuilder(
                  future: trips.loadLibrary(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return trips.MyTripsPage();
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              );
            case '/privacy':
              return FadeSlidePageRoute(page: const PrivacyPage());
            case '/terms':
              return FadeSlidePageRoute(page: const TermsPage());
            case '/flights':
              return FadeSlidePageRoute(page: const FlightsScreen());
            case '/hotels':
              return FadeSlidePageRoute(page: const HotelsScreen());
            case '/trains':
              return FadeSlidePageRoute(page: const TrainsScreen());
            case '/buses':
              return FadeSlidePageRoute(page: const BusesScreen());
            case '/cabs':
              return FadeSlidePageRoute(page: const CabsScreen());
            case '/careers':
              return FadeSlidePageRoute(page: const CareersScreen());
            case '/partners':
              return FadeSlidePageRoute(page: const PartnersScreen());
            case '/support':
              return FadeSlidePageRoute(page: const SupportScreen());
            case '/about':
              return FadeSlidePageRoute(page: const AboutPage());
            case '/how-it-works':
              return FadeSlidePageRoute(page: const HowItWorksPage());
            case '/blog':
              return FadeSlidePageRoute(page: const BlogListPage());
            case '/faqs':
              return FadeSlidePageRoute(page: const FAQsPage());
            case '/cancellation-policy':
              return FadeSlidePageRoute(page: const CancellationPolicyPage());
            case '/trip-summary':
              final args = settings.arguments as Map<String, dynamic>;
              return FadeSlidePageRoute(
                page: TripSummaryPage(arguments: args),
              );
            default:
              return MaterialPageRoute(builder: (_) => const HomePage());
          }
        },
        ),
      ),
    );
  }
}

class _PulsingChatButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _PulsingChatButton({required this.onPressed});

  @override
  State<_PulsingChatButton> createState() => _PulsingChatButtonState();
}

class _PulsingChatButtonState extends State<_PulsingChatButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00D4FF).withOpacity(_opacityAnimation.value),
                    width: 3,
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            elevation: 8,
            backgroundColor: Colors.transparent,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF007BFF), Color(0xFF00D4FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: const Color(0xFF00D4FF),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
