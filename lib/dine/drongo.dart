import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart';

class DrongoPage extends StatefulWidget {
  const DrongoPage({Key? key}) : super(key: key);

  @override
  State<DrongoPage> createState() => _DrongoPageState();
}

class _DrongoPageState extends State<DrongoPage> {
  final Map<String, List<Map<String, String>>> menu = {
    "Hot Beverages": [
      {"Tea": "₹10"},
      {"Lemon Tea": "₹15"},
      {"Adrak Elaichi Masala Tea": "₹15"},
      {"Coffee": "₹15"},
      {"Chocolate Coffee": "₹25"},
      {"Plain Milk (200ml)": "₹25"},
    ],
    "Cold Beverages": [
      {"Fresh Lime Soda": "₹35"},
      {"Lemon Shikanji": "₹25"},
      {"Ice Lemon Tea": "₹40"},
      {"Cold Coffee Plain": "₹50"},
      {"Cold Coffee with Ice Cream": "₹70"},
      {"Mocktails": "₹90"},
    ],
    "Paranthas": [
      {"Plain Parantha": "₹15"},
      {"Aloo Parantha": "₹30"},
      {"Gobi Parantha": "₹30"},
      {"Mix Parantha": "₹40"},
      {"Paneer Parantha": "₹50"},
    ],
    "Egg": [
      {"Boiled Egg": "₹25"},
      {"Omelette": "₹40"},
    ],
    "Chicken": [
      {"Chicken Momos": "₹100"},
      {"Chicken Fried Momos": "₹120"},
      {"Chilly Chicken Dry": "₹150"},
      {"Lemon Chicken": "₹120"},
      {"Chicken Nuggets": "₹90"},
    ],
    "Snacks": [
      {"Samosa": "₹15"},
      {"Bread Pakoda": "₹20"},
      {"Samosa Chat": "₹40"},
      {"Kachori Sabji": "₹40"},
      {"Idli Sambhar": "₹60"},
      {"Vada Sambhar": "₹60"},
      {"Pao Bhaji": "₹60"},
      {"Choley Kulche": "₹60"},
      {"Vada Pao": "₹50"},
    ],
    "Rice Bowl": [
      {"Kadhi Chawal": "₹70"},
      {"Rajma Chawal": "₹70"},
      {"Choley Chawal": "₹70"},
      {"Egg Curry Rice": "₹70"},
    ],
    "Maggi": [
      {"Plain Maggi": "₹25"},
      {"Veg Maggi": "₹40"},
      {"Egg Maggi": "₹50"},
    ],
    "Burger & Fries": [
      {"French Fries 300gms": "₹60"},
      {"Peri Peri Fries": "₹70"},
      {"Aloo Tikki Burger": "₹40"},
      {"Veg Burger": "₹50"},
      {"Paneer Burger": "₹60"},
      {"Grilled Veg Sandwich": "₹70"},
      {"Cheese Grilled Sandwich": "₹90"},
      {"Spicy Corn Paneer Sandwich": "₹90"},
    ],
    "Shakes": [
      {"Banana Shake": "₹50"},
      {"Mango Shake": "₹70"},
      {"Butter Scotch Shake": "₹75"},
      {"Pineapple Shake": "₹75"},
      {"Strawberry Shake": "₹75"},
      {"Black Current Shake": "₹75"},
      {"Blueberry Shake": "₹75"},
      {"Chocolate Shake": "₹75"},
      {"Oreo Shake": "₹85"},
    ],
    "Pasta": [
      {"Veg Red Pasta": "₹85"},
      {"Veg White Sauce Pasta": "₹90"},
    ],
    "Wrap": [
      {"Aloo Tikki Wrap": "₹60"},
      {"Paneer Wrap": "₹80"},
      {"Egg Wrap": "₹70"},
      {"Veg Roll": "₹40"},
      {"Paneer Roll": "₹50"},
      {"Egg Roll": "₹50"},
      {"Spring Roll": "₹50"},
    ],
    "Momos": [
      {"Veg Steamed Momos (10pcs)": "₹80"},
      {"Veg Fried Momos": "₹100"},
      {"Veg Peri Peri Momos": "₹110"},
      {"Veg Chilli Momos": "₹130"},
      {"Paneer Momos": "₹100"},
      {"Paneer Fried Momos": "₹120"},
    ],
    "Chinese": [
      {"Veg Noodles": "₹50"},
      {"Garlic Noodles": "₹65"},
      {"Sezwan Veg Noodles": "₹70"},
      {"Paneer Noodles": "₹90"},
      {"Veg Fried Rice": "₹70"},
      {"Egg Fried Rice": "₹70"},
      {"Paneer Fried Rice": "₹90"},
      {"Dry Veg Manchurian": "₹85"},
      {"Gravy Manchurian": "₹110"},
      {"Chilly Paneer": "₹110"},
    ],
    // ... (rest of your menu items remain the same)
  };

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Color(0xFF283021);
    final Color accentColor = Color(0xFF7a9064);

    List<Map<String, String>> allMenuItems = [];
    menu.forEach((category, items) {
      allMenuItems.addAll(items);
    });

    List<Map<String, String>> filteredItems = allMenuItems.where((item) {
      String itemName = item.keys.first;
      return itemName.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Drongo Canteen', style: mainHeadingStyle(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/drongo_photo.jpg'),
            ),
            const SizedBox(height: 20),

            // Info Section
            Card(
              color: cardColor,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: accentColor),
                        SizedBox(width: 8),
                        Text('Location: Below Pine mess', style: normalsize(context)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: accentColor),
                        SizedBox(width: 8),
                        Text('Timing: Monday to Sunday, 10 AM - 2 AM', style: normalsize(context)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.phone, color: accentColor),
                        SizedBox(width: 8),
                        Text('Contact: +91 9871999759', style: normalsize(context)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Menu Section
            Text(
              'Menu',
              style: subheadingStyle(context),
            ),
            SizedBox(height: 16),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search items...',
                hintStyle: normalsize(context),
                prefixIcon: Icon(Icons.search, color: accentColor),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: normalsize(context),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            SizedBox(height: 20),

            // Menu Items
            if (searchQuery.isNotEmpty)
              Column(
                children: filteredItems.map((item) {
                  String name = item.keys.first;
                  String price = item.values.first;
                  return Card(
                    color: cardColor,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.fastfood, color: accentColor),
                      title: Text(name, style: normalsize(context)),
                      trailing: Text(
                        price,
                        style: normalsize(context),
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Column(
                children: menu.entries.map((section) {
                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.key,
                            style: subheadingStyle(context),
                          ),
                          Divider(color: accentColor.withOpacity(0.3)),
                          ...section.value.map((item) {
                            String name = item.keys.first;
                            String price = item.values.first;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: normalsize(context),
                                    ),
                                  ),
                                  Text(
                                    price,
                                    style: normalsize(context)
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}