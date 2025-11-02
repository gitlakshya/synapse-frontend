import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/mock_data_provider.dart';
import '../models/booking.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idController = TextEditingController();
  String _paymentMethod = 'upi';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mockData = context.watch<MockDataProvider>();
    final itinerary = ModalRoute.of(context)?.settings.arguments as dynamic ?? mockData.getSelectedItinerary();
    final destination = itinerary?.destination ?? 'Jaipur';
    final days = itinerary?.days ?? 5;
    final amount = itinerary?.totalCost ?? 50000;

    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            return Text(
              constraints.maxWidth < 600 ? 'Booking' : 'Complete Your Booking',
              style: const TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.bold),
            );
          },
        ),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 600;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(isSmall ? 16 : 20),
                  color: const Color(0xFFF8F9FA),
                  child: isSmall
                      ? Column(
                          children: [
                            Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: Colors.grey)),
                            const SizedBox(height: 12),
                            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Text('Your $days-Day Trip to $destination', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center), const SizedBox(height: 4), const Text('2 Adults', style: TextStyle(color: Color(0xFF666666)), textAlign: TextAlign.center)]),
                            const SizedBox(height: 12),
                            Text('₹${amount.toInt()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF007BFF))),
                          ],
                        )
                      : Row(children: [Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: Colors.grey)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your $days-Day Trip to $destination', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 4), const Text('2 Adults', style: TextStyle(color: Color(0xFF666666)))])), Text('₹${amount.toInt()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF007BFF)))]),
                );
              },
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.all(constraints.maxWidth < 600 ? 20 : 40),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 600),
                            child: _buildTravelerForm(),
                          ),
                          const SizedBox(height: 30),
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 800),
                            child: _buildPaymentSection(context, amount),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelerForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Traveler Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Name is required';
                if (value.trim().length < 3) return 'Name must be at least 3 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Email is required';
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.phone),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Phone is required';
                final phoneRegex = RegExp(r'^[0-9]{10,15}$');
                if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
                  return 'Enter a valid phone number (10-15 digits)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'ID Proof (Passport/Aadhar) *',
                hintText: 'A1234567 or 1234-5678-9012',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'ID proof is required';
                if (value.trim().length < 6) return 'Enter a valid ID';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context, double amount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Method', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          RadioListTile<String>(
            title: const Text('UPI'),
            value: 'upi',
            groupValue: _paymentMethod,
            onChanged: (value) => setState(() => _paymentMethod = value!),
          ),
          RadioListTile<String>(
            title: const Text('Credit/Debit Card'),
            value: 'card',
            groupValue: _paymentMethod,
            onChanged: (value) => setState(() => _paymentMethod = value!),
          ),
          RadioListTile<String>(
            title: const Text('Wallet'),
            value: 'wallet',
            groupValue: _paymentMethod,
            onChanged: (value) => setState(() => _paymentMethod = value!),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () => _confirmBooking(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF28a745),
                disabledBackgroundColor: Colors.grey,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'PAY ₹${amount.toInt()} & CONFIRM',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final mockData = context.read<MockDataProvider>();
      final itinerary = ModalRoute.of(context)?.settings.arguments as dynamic ?? mockData.getSelectedItinerary();

      final request = BookingRequest(
        itineraryId: itinerary?.id ?? 'unknown',
        userName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        paymentMethod: _paymentMethod,
        amount: itinerary?.totalCost ?? 50000,
      );

      final result = await mockData.simulateBooking(request);

      if (mounted) {
        setState(() => _isProcessing = false);

        if (result.success) {
          _showSuccessDialog(context, result.bookingId, itinerary);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking failed: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String bookingId, dynamic itinerary) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF28a745), size: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Confirmation ID: $bookingId',
              style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 8),
            Text(
              _nameController.text.trim(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadPDF(context, bookingId, itinerary),
                    icon: const Icon(Icons.download),
                    label: const Text('Download PDF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPDF(BuildContext context, String bookingId, dynamic itinerary) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'EaseMyTrip AI Planner',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Booking Confirmation',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Confirmation ID: $bookingId'),
                pw.SizedBox(height: 20),
                pw.Text('Traveler Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Name: ${_nameController.text.trim()}'),
                pw.Text('Email: ${_emailController.text.trim()}'),
                pw.Text('Phone: ${_phoneController.text.trim()}'),
                pw.SizedBox(height: 20),
                pw.Text('Trip Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Destination: ${itinerary?.destination ?? 'N/A'}'),
                pw.Text('Duration: ${itinerary?.days ?? 0} days'),
                pw.Text('Total Cost: ₹${itinerary?.totalCost?.toInt() ?? 0}'),
                pw.SizedBox(height: 20),
                pw.Text('Payment Method: ${_paymentMethod.toUpperCase()}'),
                pw.Text('Status: CONFIRMED'),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

