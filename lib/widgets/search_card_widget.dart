import 'package:flutter/material.dart';

class SearchCard extends StatefulWidget {
  const SearchCard({super.key});

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  DateTime? _departureDate;
  DateTime? _returnDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF007BFF),
              unselectedLabelColor: const Color(0xFF666666),
              indicatorColor: const Color(0xFF007BFF),
              tabs: const [
                Tab(text: 'Flights'),
                Tab(text: 'Hotels'),
                Tab(text: 'Holiday Packages'),
                Tab(text: 'Trains'),
                Tab(text: 'Buses'),
                Tab(text: 'Cabs'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _fromController,
                        label: 'From',
                        icon: Icons.flight_takeoff,
                        hint: 'Enter city or airport',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _toController,
                        label: 'To',
                        icon: Icons.flight_land,
                        hint: 'Enter city or airport',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField(
                        label: 'Departure',
                        date: _departureDate,
                        onTap: () => _selectDate(true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField(
                        label: 'Return',
                        date: _returnDate,
                        onTap: () => _selectDate(false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Travelers & Class',
                        value: '1 Adult, Economy',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Semantics(
                  label: 'Search flights',
                  button: true,
                  hint: 'Search for available flights',
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/generate');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056b3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'SEARCH',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: '$label location',
          textField: true,
          child: SizedBox(
            height: 56,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: const Color(0xFF007BFF), size: 20),
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF007BFF)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: '$label: ${date != null ? "${date.day}/${date.month}/${date.year}" : "not selected"}',
          button: true,
          hint: 'Tap to select $label',
          child: Tooltip(
            message: 'Select $label',
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF007BFF), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      date != null ? '${date.day}/${date.month}/${date.year}' : 'Select Date',
                      style: TextStyle(
                        color: date != null ? const Color(0xFF333333) : const Color(0xFF999999),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Icon(Icons.person, color: Color(0xFF007BFF), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF666666)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isDeparture) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
        } else {
          _returnDate = picked;
        }
      });
    }
  }
}
