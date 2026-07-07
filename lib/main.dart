import 'package:flutter/material.dart';

void main() => runApp(const CampusCafeApp());

class CampusCafeApp extends StatelessWidget {
  const CampusCafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusCafé',
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF002060),
        useMaterial3: true,
        // Adding a subtle off-white background to make white cards pop
        scaffoldBackgroundColor: Colors.grey.shade50, 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF002060),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const OrderPage(),
    );
  }
}

class MenuItem {
  final String name;
  final double price; // in GHS
  const MenuItem(this.name, this.price);
}

const menu = [
  MenuItem('Jollof Rice & Chicken', 35.00),
  MenuItem('Waakye Special', 30.00),
  MenuItem('Banku & Tilapia', 45.00),
  MenuItem('Meat Pie', 12.00),
  MenuItem('Sobolo (500 ml)', 8.00),
];

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final Map<int, int> _qty = {};
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    debugPrint('OrderPage: initState() — runs ONCE');
  }

  @override
  void dispose() {
    debugPrint('OrderPage: dispose() — cleaning up');
    _searchController.dispose();
    super.dispose();
  }

  double get _total {
    var sum = 0.0;
    _qty.forEach((i, q) => sum += menu[i].price * q);
    return sum;
  }

  int get _totalItems {
    return _qty.values.fold(0, (sum, quantity) => sum + quantity);
  }

  void _change(int index, int delta) {
    setState(() {
      final next = (_qty[index] ?? 0) + delta;
      if (next <= 0) {
        _qty.remove(index);
      } else {
        _qty[index] = next;
      }
    });
  }

  Future<void> _clearOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear order?'),
        content: const Text('All quantities will reset to zero.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _qty.clear());
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cleared'),
          behavior: SnackBarBehavior.floating, // Makes the snackbar float nicely
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('OrderPage: build() — drawing UI');
    
    final query = _searchController.text.toLowerCase();
    final filteredMenuEntries = menu.asMap().entries.where((entry) {
      return entry.value.name.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusCafé', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Badge(
              isLabelVisible: _totalItems > 0,
              label: Text('$_totalItems'),
              backgroundColor: Colors.orange.shade700, // Contrast color for the badge
              child: IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Clear order',
                onPressed: _qty.isEmpty ? null : _clearOrder,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Styled Search Area
          Container(
            color: const Color(0xFF002060),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search menu...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15), // Semi-transparent overlay
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // Pill-shaped search bar
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          
          // Upgraded Menu List using Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: filteredMenuEntries.length,
              itemBuilder: (context, i) {
                final originalIndex = filteredMenuEntries[i].key;
                final item = filteredMenuEntries[i].value;
                final q = _qty[originalIndex] ?? 0;
                
                return Card(
                  elevation: 2, // Gives a CSS-like drop shadow
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'GHS ${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      trailing: QuantityStepper(
                        quantity: q,
                        onDecrement: q == 0 ? null : () => _change(originalIndex, -1),
                        onIncrement: () => _change(originalIndex, 1),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Upgraded Bottom Total Bar
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF002060),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, -4),
                blurRadius: 12,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ORDER TOTAL',
                style: TextStyle(
                  color: Colors.white70, 
                  fontWeight: FontWeight.w600, 
                  letterSpacing: 1.2
                ),
              ),
              Text(
                'GHS ${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Refactored to include a styled container
class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Groups the buttons together visually
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            color: Colors.red.shade400,
            iconSize: 20,
            splashRadius: 20,
            onPressed: onDecrement,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            color: Colors.green.shade600,
            iconSize: 20,
            splashRadius: 20,
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}