import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../main.dart';

class MockBookingScreen extends StatefulWidget {
  final TripPreferences tripPrefs;
  
  const MockBookingScreen({super.key, required this.tripPrefs});

  @override
  State<MockBookingScreen> createState() => _MockBookingScreenState();
}

class _MockBookingScreenState extends State<MockBookingScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _cardController;
  int _currentStep = 0;
  bool _isBooking = false;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedClass = 'Economy';
  String _selectedMeal = 'Vegetarian';
  
  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardController.forward();
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _cardController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1722),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTripSummary(),
                    const SizedBox(height: 20),
                    _buildBookingForm(),
                    const SizedBox(height: 20),
                    _buildPriceBreakdown(),
                    const SizedBox(height: 30),
                    _buildBookButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrangeAccent, Colors.orange.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EaseMyTrip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Complete your booking',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('Secure', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: -0.3).fadeIn();
  }

  Widget _buildTripSummary() {
    return Column(
      children: [
        _buildTravelModeSelector(),
        const SizedBox(height: 16),
        Card(
          color: const Color(0xFF1A2332),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_selectedMode == 'Flight' ? Icons.flight_takeoff : 
                         _selectedMode == 'Train' ? Icons.train : Icons.directions_bus, 
                         color: Colors.deepOrangeAccent),
                    const SizedBox(width: 8),
                    Text(
                      '$_selectedMode Details',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Best Price',
                        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTravelRoute(),
                const SizedBox(height: 16),
                _buildTripInfo(),
                const SizedBox(height: 16),
                _buildAdditionalInfo(),
              ],
            ),
          ),
        ),
      ],
    ).animate().slideX(begin: -0.3).fadeIn(delay: 200.ms);
  }

  String _selectedMode = 'Flight';

  Widget _buildTravelModeSelector() {
    final modes = ['Flight', 'Train', 'Bus'];
    return Row(
      children: modes.map((mode) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedMode = mode),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _selectedMode == mode ? Colors.deepOrangeAccent : const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedMode == mode ? Colors.deepOrangeAccent : Colors.white24,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  mode == 'Flight' ? Icons.flight_takeoff : 
                  mode == 'Train' ? Icons.train : Icons.directions_bus,
                  color: _selectedMode == mode ? Colors.white : Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  mode,
                  style: TextStyle(
                    color: _selectedMode == mode ? Colors.white : Colors.white70,
                    fontSize: 12,
                    fontWeight: _selectedMode == mode ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildTravelRoute() {
    final destination = widget.tripPrefs.destination.isEmpty ? 'GOI' : _getAirportCode(widget.tripPrefs.destination);
    final flightDetails = _getFlightDetails();
    
    return Column(
      children: [
        // Flight/Transport Details
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1722),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Airline Logo/Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _selectedMode == 'Flight' ? Icons.flight : 
                  _selectedMode == 'Train' ? Icons.train : Icons.directions_bus,
                  color: Colors.deepOrangeAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flightDetails['carrier']!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      flightDetails['number']!,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (_selectedMode == 'Flight')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'On Time',
                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Route Information
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('DEL', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Delhi', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    flightDetails['departure']!,
                    style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.tripPrefs.dates?.start != null 
                      ? DateFormat('MMM dd').format(widget.tripPrefs.dates!.start)
                      : 'Today',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  _selectedMode == 'Flight' ? Icons.flight_takeoff : 
                  _selectedMode == 'Train' ? Icons.train : Icons.directions_bus,
                  color: Colors.deepOrangeAccent,
                ),
                Container(
                  width: 60,
                  height: 2,
                  color: Colors.deepOrangeAccent,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                Text(
                  flightDetails['duration']!,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                if (_selectedMode == 'Flight')
                  const Text(
                    'Non-stop',
                    style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  Text(destination, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(widget.tripPrefs.destination.isEmpty ? 'Goa' : widget.tripPrefs.destination, 
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    flightDetails['arrival']!,
                    style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.tripPrefs.dates?.start != null 
                      ? DateFormat('MMM dd').format(widget.tripPrefs.dates!.start)
                      : 'Today',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoItem(Icons.people, '${widget.tripPrefs.people} Travelers'),
        _buildInfoItem(Icons.calendar_today, '${_getTripDuration()} Days'),
        _buildInfoItem(Icons.account_balance_wallet, '₹${widget.tripPrefs.budget.toInt()}'),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepOrangeAccent, size: 20),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildBookingForm() {
    return Card(
      color: const Color(0xFF1A2332),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person, color: Colors.deepOrangeAccent),
                  SizedBox(width: 8),
                  Text('Passenger Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField('Full Name', _nameController, Icons.person_outline),
              const SizedBox(height: 12),
              _buildTextField('Email Address', _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField('Phone Number', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildClassSelection(),
              const SizedBox(height: 16),
              _buildMealSelection(),
              const SizedBox(height: 16),
              _buildBaggageInfo(),
              const SizedBox(height: 16),
              _buildCancellationPolicy(),
            ],
          ),
        ),
      ),
    ).animate().slideX(begin: 0.3).fadeIn(delay: 400.ms);
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.deepOrangeAccent),
        filled: true,
        fillColor: const Color(0xFF0F1722),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepOrangeAccent),
        ),
      ),
      validator: (value) => value?.isEmpty == true ? 'This field is required' : null,
    );
  }

  Widget _buildClassSelection() {
    List<String> classes;
    String label;
    
    if (_selectedMode == 'Flight') {
      classes = ['Economy', 'Premium Economy', 'Business'];
      label = 'Travel Class';
    } else if (_selectedMode == 'Train') {
      classes = ['Sleeper', '3AC', '2AC', '1AC'];
      label = 'Train Class';
    } else {
      classes = ['Seater', 'Semi-Sleeper', 'AC Sleeper'];
      label = 'Bus Type';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: classes.map((cls) => GestureDetector(
            onTap: () => setState(() => _selectedClass = cls),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedClass == cls ? Colors.deepOrangeAccent : const Color(0xFF0F1722),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedClass == cls ? Colors.deepOrangeAccent : Colors.white24,
                ),
              ),
              child: Text(
                cls,
                style: TextStyle(
                  color: _selectedClass == cls ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: _selectedClass == cls ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMealSelection() {
    if (_selectedMode == 'Bus') return const SizedBox.shrink();
    
    List<String> meals;
    if (_selectedMode == 'Flight') {
      meals = ['Vegetarian', 'Non-Vegetarian', 'Jain', 'Special Diet'];
    } else {
      meals = ['No Meal', 'Vegetarian', 'Non-Vegetarian'];
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedMode == 'Flight' ? 'Meal Preference' : 'Food Preference',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: meals.map((meal) => GestureDetector(
            onTap: () => setState(() => _selectedMeal = meal),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedMeal == meal ? Colors.green : const Color(0xFF0F1722),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedMeal == meal ? Colors.green : Colors.white24,
                ),
              ),
              child: Text(
                meal,
                style: TextStyle(
                  color: _selectedMeal == meal ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: _selectedMeal == meal ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    final basePrice = _getBasePrice();
    final convenienceFee = _selectedMode == 'Flight' ? 299 : _selectedMode == 'Train' ? 49 : 99;
    final taxes = _selectedMode == 'Flight' ? (basePrice * 0.12).round() : 
                  _selectedMode == 'Train' ? (basePrice * 0.05).round() : (basePrice * 0.08).round();
    final discount = widget.tripPrefs.people >= 4 ? (basePrice * 0.08).round() : 0;
    final total = basePrice + taxes + convenienceFee - discount;
    
    return Card(
      color: const Color(0xFF1A2332),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt, color: Colors.deepOrangeAccent),
                const SizedBox(width: 8),
                const Text('Fare Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Instant Confirmation',
                    style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Base Fare (${widget.tripPrefs.people} Traveler${widget.tripPrefs.people > 1 ? 's' : ''})', basePrice),
            _buildPriceRow('${_selectedMode == 'Flight' ? 'Airport Taxes & Fuel' : _selectedMode == 'Train' ? 'Railway Charges' : 'Toll & Service Tax'}', taxes),
            _buildPriceRow('Convenience Fee', convenienceFee),
            if (discount > 0)
              _buildPriceRow('Group Discount (${widget.tripPrefs.people}+ travelers)', -discount, isDiscount: true),
            const Divider(color: Colors.white24),
            _buildPriceRow('Total Amount', total, isTotal: true),
            const SizedBox(height: 12),
            // EaseMyTrip specific offers
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_offer, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'EMT Savings: ₹${(basePrice * 0.12).round()} vs other booking sites',
                          style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.credit_card, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Extra ₹${_selectedMode == 'Flight' ? '500' : '200'} cashback with HDFC Credit Card',
                          style: const TextStyle(color: Colors.orange, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Payment options
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1722),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Options',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildPaymentChip('UPI', Icons.account_balance_wallet),
                      _buildPaymentChip('Cards', Icons.credit_card),
                      _buildPaymentChip('Net Banking', Icons.account_balance),
                      _buildPaymentChip('EMI', Icons.payment),
                      _buildPaymentChip('Wallets', Icons.wallet),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.3).fadeIn(delay: 600.ms);
  }
  
  Widget _buildPaymentChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepOrangeAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepOrangeAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.deepOrangeAccent, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, int amount, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isTotal ? Colors.white : isDiscount ? Colors.green : Colors.white70,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
              ),
            ),
          ),
          Text(
            isDiscount ? '-₹${amount.abs()}' : '₹$amount',
            style: TextStyle(
              color: isTotal ? Colors.deepOrangeAccent : isDiscount ? Colors.green : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isBooking ? null : _handleBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrangeAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
        ),
        child: _isBooking
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Processing Booking...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flight_takeoff, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Book Now - ₹${_getBasePrice() + (_getBasePrice() * 0.12).round()}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
      ),
    ).animate().scale(delay: 800.ms).shimmer(delay: 2000.ms);
  }

  void _handleBooking() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isBooking = true);
    HapticFeedback.mediumImpact();
    
    // Simulate booking process
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            tripPrefs: widget.tripPrefs,
            passengerName: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            travelClass: _selectedClass,
            totalAmount: _getBasePrice() + (_getBasePrice() * 0.12).round(),
          ),
        ),
      );
    }
  }

  Widget _buildAdditionalInfo() {
    if (_selectedMode != 'Flight') return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFlightFeature(Icons.wifi, 'Free WiFi', Colors.blue),
              _buildFlightFeature(Icons.restaurant, 'Meals', Colors.orange),
              _buildFlightFeature(Icons.airline_seat_recline_extra, 'Extra Legroom', Colors.green),
              _buildFlightFeature(Icons.usb, 'USB Charging', Colors.purple),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 14),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Web check-in available 48 hours before departure • Arrive 2 hours early for domestic flights',
                    style: TextStyle(color: Colors.blue, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFlightFeature(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildBaggageInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.luggage, color: Colors.deepOrangeAccent, size: 16),
              SizedBox(width: 8),
              Text(
                'Baggage Information',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_selectedMode == 'Flight') ..._getFlightBaggageInfo(),
          if (_selectedMode == 'Train') ..._getTrainBaggageInfo(),
          if (_selectedMode == 'Bus') ..._getBusBaggageInfo(),
        ],
      ),
    );
  }
  
  List<Widget> _getFlightBaggageInfo() {
    final cabinBaggage = _selectedClass == 'Economy' ? '7 kg' : 
                        _selectedClass == 'Premium Economy' ? '10 kg' : '12 kg';
    final checkedBaggage = _selectedClass == 'Economy' ? '15 kg' : 
                          _selectedClass == 'Premium Economy' ? '20 kg' : '30 kg';
    
    return [
      _buildBaggageRow('Cabin Baggage', cabinBaggage, 'Included'),
      _buildBaggageRow('Check-in Baggage', checkedBaggage, 'Included'),
      const SizedBox(height: 8),
      const Text(
        'Additional baggage can be purchased at check-in or online',
        style: TextStyle(color: Colors.white54, fontSize: 11),
      ),
    ];
  }
  
  List<Widget> _getTrainBaggageInfo() {
    return [
      _buildBaggageRow('Personal Luggage', '40 kg', 'Free'),
      _buildBaggageRow('Bedding', 'Provided', _selectedClass == 'Sleeper' ? 'Extra ₹50' : 'Included'),
    ];
  }
  
  List<Widget> _getBusBaggageInfo() {
    return [
      _buildBaggageRow('Under Seat', '15 kg', 'Included'),
      _buildBaggageRow('Overhead', '5 kg', 'Included'),
    ];
  }
  
  Widget _buildBaggageRow(String type, String weight, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(type, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text('$weight • $status', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
  
  Widget _buildCancellationPolicy() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.policy, color: Colors.deepOrangeAccent, size: 16),
              SizedBox(width: 8),
              Text(
                'Cancellation & Changes',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._getCancellationRules(),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield, color: Colors.orange, size: 14),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Add Travel Insurance for ₹149 to protect against cancellations',
                    style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _getCancellationRules() {
    if (_selectedMode == 'Flight') {
      return [
        _buildPolicyRow('0-2 hours before', 'No refund'),
        _buildPolicyRow('2-24 hours before', '₹3,000 + airline fee'),
        _buildPolicyRow('24+ hours before', '₹2,500 + airline fee'),
        _buildPolicyRow('Date change', '₹2,000 + fare difference'),
      ];
    } else if (_selectedMode == 'Train') {
      return [
        _buildPolicyRow('0-4 hours before', 'No refund'),
        _buildPolicyRow('4-12 hours before', '50% refund'),
        _buildPolicyRow('12+ hours before', '75% refund'),
      ];
    } else {
      return [
        _buildPolicyRow('0-6 hours before', 'No refund'),
        _buildPolicyRow('6-24 hours before', '50% refund'),
        _buildPolicyRow('24+ hours before', '90% refund'),
      ];
    }
  }
  
  Widget _buildPolicyRow(String time, String policy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(time, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text(policy, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
  
  String _getAirportCode(String destination) {
    final codes = {
      'goa': 'GOI',
      'kerala': 'COK',
      'mumbai': 'BOM',
      'delhi': 'DEL',
      'bengaluru': 'BLR',
      'bangalore': 'BLR',
      'chennai': 'MAA',
      'kolkata': 'CCU',
      'hyderabad': 'HYD',
      'pune': 'PNQ',
      'ahmedabad': 'AMD',
      'jaipur': 'JAI',
      'rajasthan': 'JAI',
      'himachal': 'KUU',
    };
    return codes[destination.toLowerCase()] ?? 'GOI';
  }

  int _getTripDuration() {
    if (widget.tripPrefs.dates != null) {
      return widget.tripPrefs.dates!.end.difference(widget.tripPrefs.dates!.start).inDays + 1;
    }
    return 4; // Default
  }

  int _getBasePrice() {
    final destination = widget.tripPrefs.destination.toLowerCase();
    int basePerPerson;
    
    if (_selectedMode == 'Flight') {
      // Realistic flight prices based on destination and class
      final destinationMultiplier = _getDestinationMultiplier(destination);
      final classMultipliers = {
        'Economy': 1.0,
        'Premium Economy': 1.4,
        'Business': 2.1,
      };
      
      final baseFare = {
        'goa': 4500,
        'kerala': 5200,
        'mumbai': 3800,
        'rajasthan': 4200,
        'delhi': 0, // Same city
        'himachal': 4800,
      };
      
      final fare = baseFare[destination] ?? 4500;
      basePerPerson = (fare * (classMultipliers[_selectedClass] ?? 1.0) * destinationMultiplier).round();
      
      // Add seasonal pricing
      final now = DateTime.now();
      if (now.month >= 11 || now.month <= 2) { // Peak season
        basePerPerson = (basePerPerson * 1.3).round();
      }
      
    } else if (_selectedMode == 'Train') {
      final trainFares = {
        'Sleeper': {'goa': 650, 'kerala': 850, 'mumbai': 450, 'rajasthan': 550, 'himachal': 750},
        '3AC': {'goa': 1650, 'kerala': 2100, 'mumbai': 1200, 'rajasthan': 1400, 'himachal': 1900},
        '2AC': {'goa': 2400, 'kerala': 3100, 'mumbai': 1800, 'rajasthan': 2100, 'himachal': 2800},
        '1AC': {'goa': 4200, 'kerala': 5400, 'mumbai': 3200, 'rajasthan': 3800, 'himachal': 4900},
      };
      basePerPerson = trainFares[_selectedClass]?[destination] ?? 1200;
      
    } else { // Bus
      final busFares = {
        'Seater': {'goa': 800, 'kerala': 1200, 'mumbai': 600, 'rajasthan': 700, 'himachal': 900},
        'Semi-Sleeper': {'goa': 1200, 'kerala': 1600, 'mumbai': 900, 'rajasthan': 1000, 'himachal': 1300},
        'AC Sleeper': {'goa': 1800, 'kerala': 2200, 'mumbai': 1400, 'rajasthan': 1600, 'himachal': 1900},
      };
      basePerPerson = busFares[_selectedClass]?[destination] ?? 1000;
    }
    
    // Group discount
    double groupDiscount = 1.0;
    if (widget.tripPrefs.people >= 4) {
      groupDiscount = 0.92; // 8% group discount
    } else if (widget.tripPrefs.people >= 6) {
      groupDiscount = 0.88; // 12% group discount
    }
    
    return (basePerPerson * widget.tripPrefs.people * groupDiscount).round();
  }
  
  double _getDestinationMultiplier(String destination) {
    // Popular destinations cost more
    final multipliers = {
      'goa': 1.2,
      'kerala': 1.1,
      'mumbai': 1.0,
      'rajasthan': 1.15,
      'himachal': 1.25,
    };
    return multipliers[destination] ?? 1.0;
  }
  
  Map<String, String> _getFlightDetails() {
    final destination = widget.tripPrefs.destination.toLowerCase();
    final now = DateTime.now();
    
    if (_selectedMode == 'Flight') {
      final airlines = ['IndiGo', 'Air India', 'SpiceJet', 'Vistara', 'GoFirst'];
      final selectedAirline = airlines[destination.hashCode % airlines.length];
      
      final flightNumbers = {
        'IndiGo': '6E-${1200 + (destination.hashCode % 800)}',
        'Air India': 'AI-${400 + (destination.hashCode % 300)}',
        'SpiceJet': 'SG-${800 + (destination.hashCode % 400)}',
        'Vistara': 'UK-${600 + (destination.hashCode % 200)}',
        'GoFirst': 'G8-${300 + (destination.hashCode % 500)}',
      };
      
      final durations = {
        'goa': '2h 15m',
        'kerala': '2h 45m',
        'mumbai': '2h 10m',
        'rajasthan': '1h 30m',
        'himachal': '1h 45m',
      };
      
      final departureTime = '${6 + (now.hour % 12)}:${(now.minute + destination.hashCode) % 60 < 10 ? '0' : ''}${(now.minute + destination.hashCode) % 60}';
      final arrivalHour = (6 + (now.hour % 12) + (durations[destination]?.contains('2h') == true ? 2 : 1)) % 24;
      final arrivalMinute = (now.minute + destination.hashCode + 30) % 60;
      final arrivalTime = '$arrivalHour:${arrivalMinute < 10 ? '0' : ''}$arrivalMinute';
      
      return {
        'carrier': selectedAirline,
        'number': flightNumbers[selectedAirline] ?? 'AI-404',
        'departure': departureTime,
        'arrival': arrivalTime,
        'duration': durations[destination] ?? '2h 30m',
      };
    } else if (_selectedMode == 'Train') {
      final trains = {
        'goa': 'Goa Express (12779)',
        'kerala': 'Kerala Express (12625)',
        'mumbai': 'Rajdhani Express (12951)',
        'rajasthan': 'Jaipur Express (12413)',
        'himachal': 'Himalayan Queen (14095)',
      };
      
      return {
        'carrier': trains[destination] ?? 'Express Train',
        'number': 'Platform 3',
        'departure': '22:30',
        'arrival': '16:45',
        'duration': '18h 15m',
      };
    } else {
      final operators = ['RedBus', 'Travels India', 'VRL Travels', 'SRS Travels'];
      final selectedOperator = operators[destination.hashCode % operators.length];
      
      return {
        'carrier': selectedOperator,
        'number': 'AC Volvo',
        'departure': '21:00',
        'arrival': '08:30',
        'duration': '11h 30m',
      };
    }
  }
}

class BookingConfirmationScreen extends StatefulWidget {
  final TripPreferences tripPrefs;
  final String passengerName;
  final String email;
  final String phone;
  final String travelClass;
  final int totalAmount;

  const BookingConfirmationScreen({
    super.key,
    required this.tripPrefs,
    required this.passengerName,
    required this.email,
    required this.phone,
    required this.travelClass,
    required this.totalAmount,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> with TickerProviderStateMixin {
  late AnimationController _successController;
  late AnimationController _cardController;
  
  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _successController.forward();
    _cardController.forward();
    HapticFeedback.heavyImpact();
  }
  
  @override
  void dispose() {
    _successController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1722),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildSuccessAnimation(),
                      const SizedBox(height: 30),
                      _buildBookingDetails(),
                      const SizedBox(height: 20),
                      _buildQRCode(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _successController,
          builder: (context, child) {
            return Transform.scale(
              scale: _successController.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 60),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Booking Confirmed!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: 8),
        Text(
          'Booking ID: EMT${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          style: const TextStyle(
            color: Colors.deepOrangeAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 700.ms),
      ],
    );
  }

  Widget _buildBookingDetails() {
    return Card(
      color: const Color(0xFF1A2332),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flight Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Passenger', widget.passengerName),
            _buildDetailRow('Email', widget.email),
            _buildDetailRow('Phone', widget.phone),
            _buildDetailRow('Class', widget.travelClass),
            _buildDetailRow('Total Paid', '₹${widget.totalAmount}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'E-tickets sent to your email. Check-in opens 24 hours before departure.',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.3).fadeIn(delay: 300.ms);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQRCode() {
    return Card(
      color: const Color(0xFF1A2332),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Mobile Boarding Pass',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.qr_code, size: 100, color: Colors.black),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Show this QR code at the airport',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    ).animate().scale(delay: 600.ms);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate back to main app
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.home),
            label: const Text('Back to Trip Planner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking details shared!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Share'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Boarding pass downloaded!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download'),
              ),
            ),
          ],
        ),
      ],
    ).animate().slideY(begin: 0.3).fadeIn(delay: 800.ms);
  }
}