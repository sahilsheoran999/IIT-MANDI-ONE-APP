import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart';

class GriffinPage extends StatefulWidget {
  const GriffinPage({Key? key}) : super(key: key);

  @override
  State<GriffinPage> createState() => _GriffinPageState();
}

class _GriffinPageState extends State<GriffinPage> {
  final Map<String, List<Map<String, String>>> menu = {
    "Snacks": [
      {"Plain Maggi": "25"},
      {"Veg Maggi": "35"},
      {"Egg Maggi": "35"},
      {"Cheese Maggi": "40"},
      {"Samosa": "15"},
      {"Chana Samosa": "30/60"},
      {"Veg Noodles": "60/80"},
      {"Chilli Garlic Noodles": "60/100"},
      {"Egg Noodles": "50/100"},
      {"Paneer Noodles": "60/100"},
      {"Bun Maska": "20"},
      {"Butter Toast": "20"},
      {"Pakora": "60/120"},
      {"French Fries": "60"},
      {"Peri Peri Fries": "80"},
      {"Aloo Tikki Burger": "50"},
      {"Cheese Burger": "60"},
      {"Paneer Burger": "70"},
      {"Veg Roll": "40"},
      {"Egg Roll": "50"},
      {"Paneer Roll": "70/100"},
      {"Aloo Sandwich": "30/60"},
      {"Egg Sandwich": "40/80"},
      {"Paneer Corn Sandwich": "45/90"},
      {"Aloo Patty": "30"},
      {"Veg Patty": "35"},
      {"Paneer Corn Patty": "45"},
    ],
    "Breakfast": [
      {"Plain Paratha": "15"},
      {"Aloo Paratha": "25"},
      {"Mix Paratha": "30"},
      {"Paneer Paratha": "35"},
      {"Pyaaz Paratha": "25"},
      {"Bun Maska": "20"},
      {"Butter Toast": "20"},
      {"Plain Omelette": "30"},
      {"Veg Omelette": "35"},
      {"Bread Omelette": "40"},
      {"Boiled Egg": "20"},
      {"Half Fry": "25"},
    ],
    "Lunch": [
      {"Monday": "Rajma Rice"},
      {"Tuesday": "Black Chana Rice"},
      {"Wednesday": "Rongi Rice"},
      {"Thursday": "Kadhi Rice"},
      {"Friday": "Rajma Rice"},
      {"Saturday": "Mix Dal Rice"},
      {"Sunday": "Rajma Rice"},
    ],
    "Dinner": [
      {"Kadai Paneer": "120/240"},
      {"Shahi Paneer": "120/240"},
      {"Paneer Butter Masala": "120/240"},
      {"Masala Paneer": "120/240"},
      {"Matar Paneer": "90/180"},
      {"Paneer Bhurji": "80/160"},
      {"Chilli Paneer": "120/240"},
      {"Dal Makhni": "60/120"},
      {"Dal Tadka": "60/120"},
      {"Chana Masala": "60/120"},
      {"Mix Veg": "70/140"},
      {"Aloo Jeera": "40/80"},
      {"Aloo Matar": "60/120"},
      {"Aloo Tamatar Gravy": "50/100"},
      {"Matar Mushroom": "80/160"},
      {"Egg Curry": "80/160"},
      {"Palak Paneer": "80/160"},
    ],
    "Rice": [
      {"Plain Rice": "40"},
      {"Jeera Rice": "60"},
      {"Egg Fried Rice": "80"},
      {"Veg Fried Rice": "80"},
      {"Matar Fried Rice": "60"},
      {"Paneer Fried Rice": "100"},
    ],
    "Paneer Dishes": [
      {"Kadai Paneer": "120/240"},
      {"Shahi Paneer": "120/240"},
      {"Paneer Butter Masala": "120/240"},
      {"Masala Paneer": "120/240"},
      {"Matar Paneer": "90/180"},
      {"Paneer Bhurji": "80/160"},
      {"Chilli Paneer": "120/240"},
    ],
    "Dal": [
      {"Dal Makhni": "60/120"},
      {"Dal Tadka": "60/120"},
      {"Chana Masala": "60/120"},
    ],
    "Sabji": [
      {"Mix Veg": "70/140"},
      {"Aloo Jeera": "40/80"},
      {"Aloo Matar": "60/120"},
      {"Aloo Tamatar Gravy": "50/100"},
      {"Matar Mushroom": "80/160"},
      {"Egg Curry": "80/160"},
      {"Palak Paneer": "80/160"},
    ],
    "Tea/Coffee": [
      {"Adrak-Elaichi Tea": "13"},
      {"Lemon Tea": "15"},
      {"Masala Tea": "15"},
      {"Black Tea": "10"},
      {"Doodh Patti": "15"},
      {"Coffee": "20"},
      {"Black Coffee": "15"},
      {"Cold Coffee": "40"},
    ],
    "Milk": [
      {"Plain Milk": "25"},
      {"Bournvita Milk": "30"},
      {"Chocolate Milk": "30"},
      {"Haldi Milk": "30"},
    ],
    "Shakes": [
      {"Mango Shake": "60"},
      {"Papaya Shake": "50"},
      {"Banana Shake": "50"},
      {"Lassi": "30"},
    ],
  };

  String searchQuery = '';
  final Color cardColor = Color(0xFF283021);
  final Color accentColor = Color(0xFF7a9064);

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
        title: Text('Griffin Canteen', style: mainHeadingStyle(context)),
    // Keeping original app bar color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/griffin_photo.jpg', fit: BoxFit.cover),
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
                        Flexible(
                          child: Text(
                            'Location: Side of fish pond in front off south academic building',
                            style: normalsize(context),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: accentColor),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Timing: Monday to Sunday, 10 AM - 12 PM',
                            style: normalsize(context),
                          ),
                        ),
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
            SizedBox(height: 16),

            // Menu Items
            if (searchQuery.isNotEmpty)
              Column(
                children: filteredItems.map((item) {
                  return Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: _buildCategoryIcon(item['category'] ?? 'Other'),
                      title: Text(item['item']!, style: normalsize(context)),
                      trailing: Text(
                        '₹${item['price']}',
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
                                    '₹$price',
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

  Widget _buildCategoryIcon(String category) {
    if (category.contains('Snacks')) {
      return Icon(Icons.fastfood, color: accentColor);
    } else if (category.contains('Breakfast')) {
      return Icon(Icons.free_breakfast, color: accentColor);
    } else if (category.contains('Lunch') || category.contains('Dinner')) {
      return Icon(Icons.dinner_dining, color: accentColor);
    } else if (category.contains('Rice')) {
      return Icon(Icons.rice_bowl, color: accentColor);
    } else if (category.contains('Tea') || category.contains('Milk') || category.contains('Shakes')) {
      return Icon(Icons.local_cafe, color: accentColor);
    } else {
      return Icon(Icons.restaurant_menu, color: accentColor);
    }
  }
}