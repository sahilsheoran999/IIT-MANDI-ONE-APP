import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart'; // Import your custom font styles

class BulbulCanteenMenu extends StatefulWidget {
  const BulbulCanteenMenu({Key? key}) : super(key: key);

  @override
  State<BulbulCanteenMenu> createState() => _BulbulCanteenMenuState();
}

class _BulbulCanteenMenuState extends State<BulbulCanteenMenu> {
  final Map<String, List<Map<String, String>>> menu = {
    "Snacks": [
      {"Manchurian Dry": "80/150"},
      {"Chilli Paneer": "150/300"},
      {"Chilli Mushroom": "120/220"},
      {"Chilli Momos": "60/100"},
      {"Fried Momos": "50/100"},
      {"Chilli Garlic Noodles": "50/100"},
      {"Cheese Noodles": "70/140"},
      {"Veg Thupka (Non Veg)": "40/70"},
      {"Veg Soup (Non Veg)": "25/60"},
    ],
    "Egg Items": [
      {"Omelette / Bread Omelette": "30/35"},
      {"Cheese Omelette": "40"},
      {"Half Fry": "30"},
      {"Egg Bhurji": "80/150"},
      {"Egg Curry": "120/200"},
    ],
    "Chicken Items": [
      {"Fried Chicken": "150/300"},
      {"Chilli Chicken": "160/300"},
      {"Rarda Chicken": "200/400"},
      {"Butter Chicken": "200/400"},
    ],
    "Main Course": [
      {"Kadhi Paneer": "200/400"},
      {"Paneer Butter Masala": "200/400"},
      {"Mix Veg": "100/180"},
      {"Aloo Jeera": "80/150"},
      {"Paneer Bhurji": "120/200"},
    ],
    "Rice": [
      {"Fried Rice (Veg)": "70/140"},
      {"Fried Rice (Non Veg)": "100/200"},
      {"Plain Rice": "50/100"},
      {"Egg Fried Rice": "80/160"},
    ],
    "Roti": [
      {"Plain Roti": "10"},
      {"Butter Roti": "12"},
      {"Lachha Paratha": "25"},
      {"Plain Paratha": "15"},
    ],
    "Shakes and Beverages": [
      {"Vanilla Shake": "50"},
      {"Butterscotch Shake": "60"},
      {"Strawberry Shake": "60"},
      {"Chocolate Shake": "60"},
      {"Cold Coffee": "50"},
      {"Lassi": "30"},
      {"Nimbu Pani": "20"},
    ],
    "Beverages": [
      {"Tea 150ml": "8"},
      {"Masala Tea 150ml": "10/12"},
      {"Ginger Tea 150ml": "12"},
      {"Lemon Tea 200ml": "10"},
      {"Ginger Honey Tea 200ml": "15"},
      {"Black Tea": "8"},
      {"Doodh Pati": "15"},
      {"Coffee 200ml": "15"},
      {"Plain Milk 200ml": "20"},
      {"Bournvita Milk 200ml": "25"},
    ],
    "Fast Food": [
      {"Veg Momos 5pc/10pc": "40/80"},
      {"Pav Bhaji (2 pav)": "40"},
      {"Samosa 1pc": "15"},
      {"Spring Roll Veg 2pc": "40"},
      {"Jumbo Cheese Grill Sandwich (Veg)": "35"},
      {"Honey Chilli Potato 200g": "60/110"},
      {"French Fries 90g/200g": "40/90"},
      {"Veg Noodles 100g": "40/80"},
      {"Aloo Paratha": "35"},
      {"Paneer Paratha": "35"},
      {"Mix Veg Paratha": "25"},
      {"Pyaz Paratha": "25"},
      {"Plain Maggi": "20"},
      {"Masala Maggi": "25"},
      {"Veg Noodles": "40"},
    ],
  };

  String searchQuery = '';
  final Color cardColor = const Color(0xFF283021);
  final Color accentColor = const Color(0xFF7a9064);

  List<Map<String, String>> get menuItems {
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
    List<Map<String, String>> filteredItems = menuItems.where((item) {
      return item['item']!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Bulbul Canteen', style: mainHeadingStyle(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Canteen Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/bulbul_photo.jpg', fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),

            // Info Card with location, timing, contact
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
                            'Location: In front of B1 hostel beside volleyball court',
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
                            'Timing: Monday to Sunday, 11 AM - 11 PM',
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
                          'Contact: +91 9817525752',
                          style: normalsize(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Menu heading
            Text('Menu', style: subheadingStyle(context)),
            const SizedBox(height: 16),

            // Search bar
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

            // Menu list (filtered or full)
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
    if (cat.contains('snack')) {
      return Icon(Icons.fastfood, color: accentColor);
    } else if (cat.contains('egg')) {
      return Icon(Icons.egg, color: accentColor);
    } else if (cat.contains('chicken')) {
      return Icon(Icons.set_meal, color: accentColor);
    } else if (cat.contains('main')) {
      return Icon(Icons.restaurant_menu, color: accentColor);
    } else if (cat.contains('rice')) {
      return Icon(Icons.rice_bowl, color: accentColor);
    } else if (cat.contains('roti')) {
      return Icon(Icons.circle, color: accentColor);
    } else if (cat.contains('shake') || cat.contains('beverage')) {
      return Icon(Icons.local_drink, color: accentColor);
    } else if (cat.contains('fast food')) {
      return Icon(Icons.local_pizza, color: accentColor);
    } else {
      return Icon(Icons.restaurant, color: accentColor);
    }
  }
}
