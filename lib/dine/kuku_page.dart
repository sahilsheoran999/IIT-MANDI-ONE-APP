import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart'; // Assuming same style file as GriffinPage

class KukuPage extends StatefulWidget {
  const KukuPage({Key? key}) : super(key: key);

  @override
  _KukuPageState createState() => _KukuPageState();
}

class _KukuPageState extends State<KukuPage> {
  final Map<String, List<Map<String, String>>> menu = {
    "Momos": [
      {"Veg Steamed Momos (Full/Half)": "80/40"},
      {"Veg Fried Momos (Full/Half)": "100/50"},
      {"Paneer Steamed Momos (Full/Half)": "80/40"},
      {"Paneer Fried Momos (Full/Half)": "100/50"},
    ],
    "Siddu": [
      {"Siddu (Pulse) with Ghee": "40+20"},
      {"Siddu (Poppy Seeds) with Ghee": "50+20"},
      {"Siddu (Walnut)": "60+20"},
    ],
    "Snacks": [
      {"Kachori": "35"},
      {"Chowmin (Full/Half)": "80/40"},
      {"Thupka (Full/Half)": "80/40"},
      {"Maggi Plain": "30"},
      {"Maggi Veg": "40"},
    ],
    "Beverages": [
      {"Tea": "10"},
      {"Coffee": "15"},
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
        title: Text('Kuku Canteen', style: mainHeadingStyle(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/kuku_photo.jpg', fit: BoxFit.cover),
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
                            'Location: Next to Alder Mess',
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
                            'Timing: Monday to Sunday, 10 AM - 11 PM',
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
                          'Contact: +91 7876221096',
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
    if (category.contains('Momos')) {
      return Icon(Icons.ramen_dining, color: accentColor);
    } else if (category.contains('Siddu')) {
      return Icon(Icons.donut_small, color: accentColor);
    } else if (category.contains('Snacks')) {
      return Icon(Icons.fastfood, color: accentColor);
    } else if (category.contains('Beverages')) {
      return Icon(Icons.local_cafe, color: accentColor);
    } else {
      return Icon(Icons.restaurant_menu, color: accentColor);
    }
  }
}
