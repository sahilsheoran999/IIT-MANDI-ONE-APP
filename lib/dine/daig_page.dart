import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart'; // Use your custom font styles

class DaigPage extends StatefulWidget {
  const DaigPage({Key? key}) : super(key: key);

  @override
  State<DaigPage> createState() => _DaigPageState();
}

class _DaigPageState extends State<DaigPage> {
  final Map<String, List<Map<String, String>>> menu = {
    "Drinks": [
      {"Tea (150ml)": "10"},
      {"Coffee (150ml)": "15"},
      {"Lassi": "35"},
      {"Cold Drinks": "MRP"},
      {"Veg Soup": "20"},
    ],
    "Tandoor Special": [
      {"Aloo Paratha": "25"},
      {"Paneer Paratha": "50"},
      {"Gobhi Paratha": "35"},
      {"Mix Paratha": "40"},
      {"Paneer Tikka": "120"},
      {"Malai Chaap": "100"},
      {"Masala Chaap": "90"},
      {"Chilly Chaap": "90"},
    ],
    "Snacks": [
      {"Veg Momos": "60"},
      {"Veg Crunchy Momos": "70"},
      {"Paneer Momos": "70"},
      {"Paneer Crunchy Momos": "90"},
      {"Spring Rolls": "100"},
      {"Veg Cutlets": "20"},
      {"Veg Burger": "40"},
      {"Cheese Burger": "70"},
      {"Daig Special Burger": "170"},
      {"Veg Pakora": "30"},
      {"Fried Rice": "80"},
      {"Kadhai Paneer": "200"},
      {"Chilly Mushroom": "120"},
      {"Chilly Paneer": "100"},
    ],
    "Sandwich": [
      {"Veg Sandwich": "40"},
      {"Veg Grilled Sandwich": "45"},
      {"Cheese Grilled Sandwich": "50"},
      {"Butter Toast": "35"},
      {"Bread Pakora": "20"},
      {"Bread Pakora Aloo Stuffed": "30"},
    ],
    "Maggi": [
      {"Maggi": "25"},
      {"Veg Maggi": "30"},
      {"Cheese Maggi": "40"},
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
        title: Text('Daig Canteen', style: mainHeadingStyle(context)),
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/daig_photo.jpg', fit: BoxFit.cover),
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
                            'Location: Near Bus Stop, North Campus',
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
                            'Timing: Monday to Sunday, 10 AM - 10 PM',
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
                          'Contact: +91 -',
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
                      trailing: Text(
                        item['price'] == 'MRP' ? 'MRP' : '₹${item['price']}',
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
                                  Text(
                                    price == 'MRP' ? 'MRP' : '₹$price',
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
    final cat = category.toLowerCase();
    if (cat.contains('drink')) {
      return Icon(Icons.local_cafe, color: accentColor);
    } else if (cat.contains('tandoor')) {
      return Icon(Icons.local_fire_department, color: accentColor);
    } else if (cat.contains('snack')) {
      return Icon(Icons.fastfood, color: accentColor);
    } else if (cat.contains('sandwich')) {
      return Icon(Icons.lunch_dining, color: accentColor);
    } else if (cat.contains('maggi')) {
      return Icon(Icons.ramen_dining, color: accentColor);
    } else {
      return Icon(Icons.restaurant_menu, color: accentColor);
    }
  }
}
