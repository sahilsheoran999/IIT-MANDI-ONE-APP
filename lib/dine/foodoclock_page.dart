import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart';

class FoodOClockMenu extends StatefulWidget {
  const FoodOClockMenu({Key? key}) : super(key: key);

  @override
  State<FoodOClockMenu> createState() => _FoodOClockMenuState();
}

class _FoodOClockMenuState extends State<FoodOClockMenu> {
  final Map<String, List<Map<String, String>>> menu = {
    "Snacks": [
      {"Plain Maggie": "₹25"},
      {"Veg Maggie": "₹35"},
      {"Egg Maggie": "₹35"},
      {"Cheese Maggie": "₹40"},
      {"Samosa": "₹15"},
      {"Chana Samosa": "₹30/₹60"},
      {"Veg Noodles": "₹50/₹100"},
      {"Egg Noodles": "₹50/₹100"},
      {"Paneer Noodles": "₹50/₹100"},
      {"Bun Maska": "₹20"},
      {"Butter Toast": "₹20"},
      {"Pakora": "₹60/₹120"},
      {"French Fries": "₹60"},
      {"Peri Peri Fries": "₹80"},
      {"Aloo Tikki Burger": "₹40"},
      {"Cheese Burger": "₹50"},
      {"Paneer Burger": "₹50"},
      {"Veg Roll": "₹50"},
      {"Egg Roll": "₹70"},
      {"Paneer Roll": "₹70"},
      {"Veg Sandwich": "₹30/₹60"},
      {"Aloo Sandwich": "₹30/₹60"},
      {"Egg Sandwich": "₹40/₹80"},
      {"Paneer Sandwich": "₹40/₹80"},
      {"Paneer Corn Sandwich": "₹45/₹90"},
      {"Aloo Patty": "₹30"},
      {"Veg Patty": "₹35"},
      {"Paneer Patty": "₹40"},
      {"Paneer Corn Patty": "₹45"},
    ],
    "Fried Rice": [
      {"Veg Fried Rice": "₹80"},
      {"Egg Fried Rice": "₹100"},
      {"Paneer Fried Rice": "₹110"},
    ],
    "Paratha": [
      {"Plain Paratha": "₹15"},
      {"Aloo Paratha": "₹25"},
      {"Mix Paratha": "₹30"},
      {"Paneer Paratha": "₹35"},
    ],
    "Tea/Coffee": [
      {"Adrak-Elaichi Tea": "₹13"},
      {"Lemon Tea": "₹15"},
      {"Masala Tea": "₹15"},
      {"Black Tea": "₹10"},
      {"Doodh Patti": "₹15"},
      {"Coffee": "₹20"},
      {"Black Coffee": "₹15"},
      {"Cold Coffee": "₹40"},
    ],
    "Omelette": [
      {"Plain Omelette": "₹25"},
      {"Veg Omelette": "₹35"},
      {"Bread Omelette": "₹25"},
      {"Boiled Egg": "₹12"},
    ],
    "Milk": [
      {"Plain Milk": "₹25"},
      {"Bournvita Milk": "₹30"},
      {"Chocolate Milk": "₹30"},
      {"Haldi Milk": "₹25"},
    ],
    "Shakes": [
      {"Mango Shake": "₹60"},
      {"Papaya Shake": "₹50"},
      {"Banana Shake": "₹50"},
      {"Strawberry Shake": "₹50"},
      {"Oreo Shake": "₹50"},
    ],
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
        title: Text('Food O\'Clock', style: mainHeadingStyle(context)),
        // Keeping the original app bar color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/foodoclock_photo.jpg'),
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
                        Text('Location: Below yoga mess', style: normalsize(context)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: accentColor),
                        SizedBox(width: 8),
                        Text('Timing: Monday to Sunday, 11 AM - 11 PM', style: normalsize(context)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.phone, color: accentColor),
                        SizedBox(width: 8),
                        Text('Contact: +91 -', style: normalsize(context)),
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
                                    style: normalsize(context),
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