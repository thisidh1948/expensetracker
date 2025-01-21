// lib/utils/common_icons.dart
import 'package:flutter/material.dart';

class CommonIcons {
  static const Map<String, IconData> iconMap = {
    // Banking & Money
    'Bank': Icons.account_balance,
    'Wallet': Icons.account_balance_wallet,
    'Card': Icons.credit_card,
    'Savings': Icons.savings,
    'Payment': Icons.payment,
    'Money': Icons.attach_money,
    'Cash': Icons.money,
    'Exchange': Icons.currency_exchange,
    'ATM': Icons.local_atm,

    // Shopping
    'Shopping Cart': Icons.shopping_cart,
    'Shopping Bag': Icons.shopping_bag,
    'Store': Icons.store,
    'Grocery': Icons.local_grocery_store,
    'Mall': Icons.local_mall,
    'Gift': Icons.card_giftcard,
    'Receipt': Icons.receipt_long,

    // Food & Dining
    'Restaurant': Icons.restaurant,
    'Fast Food': Icons.fastfood,
    'Cafe': Icons.local_cafe,
    'Pizza': Icons.local_pizza,
    'Bar': Icons.local_bar,
    'Coffee': Icons.coffee,
    'Breakfast': Icons.breakfast_dining,
    'Lunch': Icons.lunch_dining,
    'Dinner': Icons.dinner_dining,

    // Transport
    'Car': Icons.directions_car,
    'Taxi': Icons.local_taxi,
    'Bus': Icons.directions_bus,
    'Train': Icons.train,
    'Flight': Icons.flight,
    'Bike': Icons.directions_bike,
    'Scooter': Icons.electric_scooter,
    'Gas Station': Icons.local_gas_station,

    // Bills & Utilities
    'Bill': Icons.receipt,
    'Water': Icons.water_drop,
    'Electricity': Icons.electric_bolt,
    'Phone': Icons.phone,
    'Mobile': Icons.smartphone,
    'Wifi': Icons.wifi,
    'Internet': Icons.router,
    'TV': Icons.tv,

    // Home
    'Home': Icons.home,
    'House': Icons.house,
    'Furniture': Icons.chair,
    'Appliances': Icons.kitchen,
    'Cleaning': Icons.cleaning_services,
    'Laundry': Icons.local_laundry_service,
    'Repair': Icons.handyman,

    // Health
    'Medical': Icons.medical_services,
    'Hospital': Icons.local_hospital,
    'Pharmacy': Icons.local_pharmacy,
    'Fitness': Icons.fitness_center,
    'Spa': Icons.spa,
    'Salon': Icons.face,

    // Entertainment
    'Movie': Icons.movie,
    'Games': Icons.sports_esports,
    'Music': Icons.music_note,
    'Sports': Icons.sports,
    'Book': Icons.book,
    'Party': Icons.celebration,

    // Education & Work
    'School': Icons.school,
    'Education': Icons.cast_for_education,
    'Work': Icons.work,
    'Business': Icons.business_center,
    'Office': Icons.import_contacts,
  };

  static IconData getIcon(String? label) {
    if (label == null || label.isEmpty) {
      print('No label provided, using default icon');
      return Icons.receipt; // Default icon
    }
    final icon = iconMap[label];
    if (icon == null) {
      print('No icon found for label: $label'); // Debug print
      return Icons.receipt;
    }
    return icon;
  }

  // Get icons by category
  static Map<String, List<String>> getCategoryIcons() {
    return {
      'Banking & Money': [
        'Bank', 'Wallet', 'Card', 'Savings', 'Payment',
        'Money', 'Cash', 'Exchange', 'ATM'
      ],
      'Shopping': [
        'Shopping Cart', 'Shopping Bag', 'Store', 'Grocery',
        'Mall', 'Gift', 'Receipt'
      ],
      'Food & Dining': [
        'Restaurant', 'Fast Food', 'Cafe', 'Pizza', 'Bar',
        'Coffee', 'Breakfast', 'Lunch', 'Dinner'
      ],
      'Transport': [
        'Car', 'Taxi', 'Bus', 'Train', 'Flight', 'Bike',
        'Scooter', 'Gas Station'
      ],
      'Bills & Utilities': [
        'Bill', 'Water', 'Electricity', 'Phone', 'Mobile',
        'Wifi', 'Internet', 'TV'
      ],
      'Home': [
        'Home', 'House', 'Furniture', 'Appliances', 'Cleaning',
        'Laundry', 'Repair'
      ],
      'Health': [
        'Medical', 'Hospital', 'Pharmacy', 'Fitness', 'Spa', 'Salon'
      ],
      'Entertainment': [
        'Movie', 'Games', 'Music', 'Sports', 'Book', 'Party'
      ],
      'Education & Work': [
        'School', 'Education', 'Work', 'Business', 'Office'
      ],
    };
  }
}

// lib/widgets/icon_picker_widget.dart
class IconPickerWidget extends StatelessWidget {
  final String currentLabel;
  final Function(String) onIconSelected;
  final double size;

  const IconPickerWidget({
    Key? key,
    required this.currentLabel,
    required this.onIconSelected,
    this.size = 40,
  }) : super(key: key);

  void _showIconPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text('Select Icon'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: CommonIcons.getCategoryIcons()
                            .entries
                            .map((category) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  category.key,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 4,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                children: category.value.map((label) {
                                  final isSelected = currentLabel == label;
                                  return InkWell(
                                    onTap: () {
                                      onIconSelected(label);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1)
                                            : null,
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey.withOpacity(0.3),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CommonIcons.getIcon(label),
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : null,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            label,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isSelected
                                                  ? Theme.of(context).primaryColor
                                                  : null,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showIconPicker(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          CommonIcons.getIcon(currentLabel),
          size: size * 0.6,
        ),
      ),
    );
  }
}
