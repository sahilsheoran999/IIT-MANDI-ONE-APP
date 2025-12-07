import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart'; // Use your custom font styles

class MonalPage extends StatefulWidget {
  const MonalPage({Key? key}) : super(key: key);

  @override
  State<MonalPage> createState() => _MonalPageState();
}

class _MonalPageState extends State<MonalPage> {
  final Map<String, List<Map<String, String>>> menu = {
    "Beverages": [
      {"Adrak Elaichi Tea": "15"},
      {"Coffee": "20"},
    ],
    "Parathas": [
      {"Alu Pyaz Paratha": "25"},
      {"Paneer Paratha": "20"},
      {"Gobhi Paratha": "24"},
    ],
    "Chinese": [
      {"Honey Chilli Potato": "120"},
      {"Veg Noodles": "75"},
      {"Fried Rice": "90"},
      {"Veg Manchurian Dry": "65"},
      {"Veg Manchurian with Gravy": "100"},
      {"Chilli Paneer": "150"},
    ],
    "Momos & Rolls": [
      {"Paneer Momos": "110"},
      {"Veg Momos": "75"},
      {"Spring Roll": "49"},
      {"Veg Roll": "40"},
      {"Paneer Roll": "50"},
      {"Egg Roll": "50"},
      {"Chicken Salami Roll": "90"},
      {"Chicken Kabab Roll": "90"},
      {"Chicken Egg Roll": "120"},
    ],
    "Egg Dishes": [
      {"Plain Omelette": "30"},
      {"Masala Omelette": "40"},
      {"Bread Omelette": "45"},
    ],
    "Indian Meals": [
      {"Paneer Butter Masala": "130"},
      {"Kadhai Paneer": "150"},
      {"Dal Fry Rice": "80"},
      {"Rajma Rice": "80"},
      {"Chole Rice": "80"},
      {"Chole Kulche": "50"},
    ],
    "Snacks & Sandwiches": [
      {"Aloo Tikki Burger": "50"},
      {"Paneer Burger": "55"},
      {"All-In-One Sandwich": "49"},
      {"Veg Sandwich": "29"},
      {"French Fries": "60"},
      {"Chilli Oregano Toast": "33"},
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
        title: Text('Monal Canteen', style: mainHeadingStyle(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/monal_photo.jpg', fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
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
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Location: Below Oak Mess',
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
                            'Timing: Monday to Sunday, 10 AM - 12 PM',
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
                          'Contact: +91 7339716043',
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
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
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
              style: normalsize(context),
            ),
            const SizedBox(height: 16),
            if (searchQuery.isNotEmpty)
              Column(
                children: filteredItems.map((item) {
                  return Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
    if (category.contains('Beverages')) {
      return Icon(Icons.local_cafe, color: accentColor);
    } else if (category.contains('Parathas')) {
      return Icon(Icons.flatware, color: accentColor);
    } else if (category.contains('Chinese')) {
      return Icon(Icons.ramen_dining, color: accentColor);
    } else if (category.contains('Momos')) {
      return Icon(Icons.lunch_dining, color: accentColor);
    } else if (category.contains('Egg')) {
      return Icon(Icons.egg, color: accentColor);
    } else if (category.contains('Indian Meals')) {
      return Icon(Icons.rice_bowl, color: accentColor);
    } else if (category.contains('Snacks')) {
      return Icon(Icons.fastfood, color: accentColor);
    } else {
      return Icon(Icons.restaurant_menu, color: accentColor);
    }
  }
}
