import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart'; // Reuse styles like in KukuPage

class MagpieCanteenMenu extends StatefulWidget {
  const MagpieCanteenMenu({Key? key}) : super(key: key);

  @override
  State<MagpieCanteenMenu> createState() => _MagpieCanteenMenuState();
}

class _MagpieCanteenMenuState extends State<MagpieCanteenMenu> {
  final Map<String, List<Map<String, String>>> menu = {
    "Roti": [
      {"Tawa Roti": "10"},
      {"Butter Roti": "15"},
    ],
    "Veg": [
      {"Chilli Cheese": "150/300"},
      {"Chilli Mushroom": "120/220"},
      {"Chilli Garlic Noodles": "80"},
      {"Kadai Paneer": "150/300"},
      {"Butter Paneer": "150/300"},
      {"Aloo Zeera": "80/150"},
      {"Paneer Bhurji": "150"},
    ],
    "Rice": [
      {"Rice": "50/80"},
      {"Jeera Rice": "60/100"},
      {"Fried Rice": "90/160"},
      {"Chicken Fried Rice": "100/180"},
      {"Paneer Fried Rice": "80/160"},
      {"Egg Fried Rice": "75/140"},
    ],
    "Fast Food": [
      {"Veg Momos": "30/60"},
      {"Veg Momos Fried": "50/90"},
      {"Non Veg Momos": "70/120"},
      {"Veg Thupka": "40"},
      {"Non Veg Thupka": "50"},
      {"Noodles": "60"},
      {"Chilli Momos": "140"},
      {"Mixed Pakoda": "150"},
    ],
    "Snacks": [
      {"Spring Roll Veg": "40"},
      {"Spring Roll Non Veg": "60"},
      {"Jumbo Cheese Grill Sandwich (Veg)": "50"},
      {"Jumbo Cheese Grill Sandwich (Non Veg)": "70"},
      {"Veg Manchurian Dry": "65"},
      {"Honey Chilli Potato": "65"},
      {"French Fries": "40"},
      {"Kadhai Masala Pizza": "70"},
      {"Mexican Pizza": "80"},
      {"Margarita Pizza": "70"},
      {"Mushroom Pizza": "80"},
      {"Corn Pizza": "90"},
      {"Chicken Corn Pollo Pizza": "110"},
      {"Chicken Farm Pizza": "110"},
      {"Grill Chicken Pizza": "110"},
      {"Spice Chicken Pizza": "110"},
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
        title: Text('Magpie Canteen', style: mainHeadingStyle(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/magpie_photo.jpg', fit: BoxFit.cover),
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
                            'Location: Below D2 Mess',
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
                            'Timing: Monday to Sunday, 9 AM - 11 PM',
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
                          'Contact: +91 9317800578',
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
                }).toList(),)
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    if (category.contains('Roti')) {
      return Icon(Icons.circle, color: accentColor);
    } else if (category.contains('Veg')) {
      return Icon(Icons.eco, color: accentColor);
    } else if (category.contains('Rice')) {
      return Icon(Icons.rice_bowl, color: accentColor);
    } else if (category.contains('Fast Food')) {
      return Icon(Icons.fastfood, color: accentColor);
    } else if (category.contains('Snacks')) {
      return Icon(Icons.local_pizza, color: accentColor);
    } else {
      return Icon(Icons.restaurant_menu, color: accentColor);
    }
  }
}
