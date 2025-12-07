import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart'; // Use your custom font styles

class TreepiePage extends StatefulWidget {
  const TreepiePage({Key? key}) : super(key: key);

  @override
  State<TreepiePage> createState() => _TreepiePageState();
}

class _TreepiePageState extends State<TreepiePage> {
  final Map<String, List<Map<String, String>>> menu = {
    "Starters": [
      {"Stuffed Garlic Bread": "152.28"},
      {"Sweet Corn Stuffed": "152.28"},
      {"Paneer Tikka Stuffed": "158.45"},
    ],
    "Indian Tacos": [
      {"Paneer Tikka Taco": "141.75"},
      {"Mushroom Corn & Onion Taco": "141.75"},
    ],
    "Wraps": [
      {"Cheese Wrap": "40.98"},
      {"Paneer Wrap": "51.45"},
    ],
    "Sides": [
      {"French Fries": "51.45"},
      {"Cheese French Fries": "72.45"},
      {"Masala Potato": "72.45"},
      {"Cheese Bites": "61.95"},
    ],
    "Pizza (Deluxe)": [
      {"Veg Supreme Pizza": "-"},
      {"Exotic Veggie Pizza": "-"},
      {"Veg Extravaganza Pizza": "-"},
      {"4-Cheese Pizza": "-"},
      {"Mexican Green Wave": "-"},
      {"Peppy Paneer": "-"},
      {"Paneer Makhani": "-"},
      {"Farm House": "-"},
      {"Smokey Hot Corn": "-"},
      {"Paneer Tikka": "-"},
      {"Peri Peri Pepper": "-"},
      {"Jalapeno Passion": "-"},
      {"Jalapeno Treat": "-"},
      {"Cheese Heaven": "-"},
    ],
    "Pasta": [
      {"Plain White Sauce": "72.45"},
      {"Plain Red Sauce": "82.95"},
      {"Cheese Loaded White": "102.95"},
      {"Cheese Loaded Red": "102.95"},
      {"Veggie Loaded White": "99.00"},
      {"Veggie Loaded Red": "99.00"},
      {"Veggie Cheese Loaded White": "149.00"},
      {"Veggie Cheese Loaded Red": "149.00"},
      {"Mix Sauce": "156.45"},
      {"Indian Masala": "156.45"},
    ],
    "Macaroni": [
      {"Cheesy Macaroni": "156.45"},
      {"Cheesy Heat Macaroni": "156.45"},
    ],
    "Lasagna": [
      {"Pesto Lasagna": "145.95"},
      {"Creamy Lasagna": "156.45"},
      {"Red Sauce Lasagna": "156.45"},
    ],
    "Spaghetti": [
      {"Pesto": "126.00"},
      {"White Sauce": "120.00"},
      {"Red Sauce": "196.50"},
    ],
    "Burgers": [
      {"Aloo Tikki Burger": "150.00"},
      {"Veggie Burger": "26.75"},
      {"Aloo Achari Burger": "26.75"},
      {"Cheese Burger": "51.45"},
      {"Double Cheese Burger": "61.95"},
      {"Spicy Cheese Burger": "61.95"},
      {"Paneer Tikka Burger": "61.95"},
      {"Cheese & Cream Burger": "61.95"},
    ],
    "Stuffed Garlic Bread": [
      {"Cheese Garlic Bread": "121.25"},
      {"Garlic Bread Stick": "126.00"},
    ],
    "Dips": [
      {"Jalapeno Dip": "150.00"},
      {"Cheesy Dip": "150.00"},
      {"Peri Peri Dip": "150.00"},
      {"Hot Garlic Dip": "150.00"},
    ],
    "Combos": [
      {"Combo 1": "147.00"},
      {"Combo 2": "160.00"},
      {"French Fries Combo": "157.50"},
    ],
    "Beverages": [
      {"Cold Drink (250ml)": "20.00"},
      {"Cold Drink (750ml)": "40.00"},
      {"Kombucha Himalayan Brew": "150.00"},
      {"Jeera Tea": "10.00"},
    ],
  };

  String searchQuery = '';
  final Color cardColor = const Color(0xFF283021);
  final Color accentColor = const Color(0xFF7a9064);

  List<Map<String, String>> get allMenuItems {
    List<Map<String, String>> items = [];
    menu.forEach((category, itemList) {
      for (var item in itemList) {
        item.forEach((itemName, price) {
          items.add({
            'item': itemName,
            'price': price,
            'category': category,
          });
        });
      }
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredItems = allMenuItems.where((item) {
      return item['item']!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Treepie Canteen', style: mainHeadingStyle(context)),
      
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/treepie_photo.jpg', fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            // Info Card
            Card(
              color: cardColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: accentColor),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Location: Near Central Library',
                            style: normalsize(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: accentColor),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Timing: Monday to Sunday, 8 AM - 9 PM',
                            style: normalsize(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.phone, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          'Contact: +91 9123456789',
                          style: normalsize(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Menu', style: subheadingStyle(context)),
            const SizedBox(height: 16),
            // Search Bar
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              style: normalsize(context),
              decoration: InputDecoration(
                hintText: 'Search for an item...',
                hintStyle: normalsize(context),
                prefixIcon: Icon(Icons.search, color: accentColor),
                filled: true,
                fillColor: cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Menu List
            if (searchQuery.isNotEmpty)
              Column(
                children: filteredItems.map((item) {
                  return Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: _buildCategoryIcon(item['category'] ?? 'Other'),
                      title: Text(item['item']!, style: normalsize(context)),
                      trailing: Text('₹${item['price']}', style: normalsize(context)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(section.key, style: subheadingStyle(context)),
                          Divider(color: accentColor.withOpacity(0.3)),
                          ...section.value.map((item) {
                            String name = item.keys.first;
                            String price = item.values.first;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(name, style: normalsize(context))),
                                  Text('₹$price', style: normalsize(context)),
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

  Widget _buildCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('breakfast')) {
      return Icon(Icons.free_breakfast, color: accentColor);
    } else if (cat.contains('main')) {
      return Icon(Icons.restaurant_menu, color: accentColor);
    } else if (cat.contains('snacks')) {
      return Icon(Icons.fastfood, color: accentColor);
    } else if (cat.contains('beverages')) {
      return Icon(Icons.local_cafe, color: accentColor);
    } else if (cat.contains('desserts')) {
      return Icon(Icons.icecream, color: accentColor);
    } else {
      return Icon(Icons.restaurant, color: accentColor);
    }
  }
}
