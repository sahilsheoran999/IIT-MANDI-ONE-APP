import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart'; // Import your custom font styles

class BakeOMochaPage extends StatefulWidget {
  const BakeOMochaPage({Key? key}) : super(key: key);

  @override
  State<BakeOMochaPage> createState() => _BakeOMochaPageState();
}

class _BakeOMochaPageState extends State<BakeOMochaPage> {
  final Map<String, List<Map<String, String>>> menu = {
    "Beverages": [
      {"Regular Cold Coffee (150ml)": "40"},
      {"Classic Cold Coffee (245ml)": "80"},
      {"Iced Americano (245ml)": "95"},
      {"Iced Latte (245ml)": "95"},
      {"Iced Caramel Frappe (245ml)": "105"},
      {"Iced Spanish Latte (245ml)": "90"},
      {"Iced Mocha Frappe (245ml)": "95"},
      {"Mocha Chillo (245ml)": "95"},
      {"Iced Lemon Tea (245ml)": "55"},
      {"Iced Peach Tea (245ml)": "55"},
      {"Iced Green Apple Tea (245ml)": "55"},
    ],
    "Shakes": [
      {"Banana Shake (245ml)": "80"},
      {"Strawberry Shake (245ml)": "80"},
      {"Blueberry Shake (245ml)": "80"},
      {"Chocolate Shake (245ml)": "80"},
      {"Mango Shake (245ml)": "80"},
      {"Peanut Butter Shake (245ml)": "105"},
      {"Oreo Shake (245ml)": "80"},
      {"Kitkat Shake (245ml)": "80"},
    ],
    "Smoothies": [
      {"Blueberry Smoothies (245ml)": "95"},
      {"Chocolate Smoothies (245ml)": "95"},
      {"Strawberry Smoothies (245ml)": "95"},
      {"Mango Smoothies (245ml)": "95"},
      {"Black Current Smoothies (245ml)": "95"},
    ],
    "Mojito": [
      {"Fresh Lime Soda": "60"},
      {"Virgin Mojito (245ml)": "80"},
      {"Strawberry Mojito (245ml)": "80"},
      {"Green Apple Mojito (245ml)": "80"},
      {"Blue Lagoon Mojito (245ml)": "80"},
      {"Sunset Mojito (245ml)": "80"},
      {"Red Kiss Mojito (245ml)": "80"},
      {"Orange Bliss Mojito (245ml)": "120"},
    ],
    "Add On": [
      {"Ice Cream (1 Scoop)": "30"},
      {"Whipped Cream (1 Scoop)": "30"},
    ],
    "Burger": [
      {"Aloo Tikki Burger": "35"},
      {"Veggie Burger": "50"},
      {"Schezwan Burger": "50"},
      {"Paneer Tikka Burger": "70"},
    ],
    "Pizza (Veg)": [
      {"Classic Cheese Pizza": "80"},
      {"Onion Capsicum Pizza": "80"},
      {"Cheese Corn Pizza": "80"},
      {"Red Ford Pizza": "125"},
      {"Mushroom, Onion, Red Chilli/Peprika": "125"},
      {"Red Devil Pizza": "125"},
      {"Paneer, Onion, Red Chilli/Peprika": "125"},
      {"Veggie Delight Pizza": "125"},
      {"Country Feast Pizza": "125"},
      {"Capsicum, Onion, Mushroom, Tomato, Corn": "125"},
      {"Eastwood Pizza": "125"},
      {"Olive, Capsicum, Tomato, Corn": "125"},
      {"Indiana Pizza - Paneer Tikka Pizza": "125"},
      {"Paneer Tikka, Onion, Green Chillies": "125"},
    ],
    "Pasta (Veg)": [
      {"Classic Veg Pasta": "90"},
    ],
    "Wraps (Veg)": [
      {"Potato Kathi Wrap": "49"},
      {"Veggies Kathi Wrap": "49"},
      {"Cheese Corn Wrap": "49"},
      {"Paneer Masala Kathi Wrap": "49"},
    ],
    "Snacks": [
      {"French Fries": "40"},
      {"Chilli Potato Balls (6pcs)": "40"},
      {"Cheese Balls (6pcs)": "70"},
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
        title: Text('Bake-O-Mocha Cafe', style: mainHeadingStyle(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image banner
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/bake_o_mocha_photo.jpg', fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),

            // Info card with location, timing, contact
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
                            'Location: North Campus (Near CV Raman Guest House)',
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
    if (cat.contains('beverage')) {
      return Icon(Icons.local_cafe, color: accentColor);
    } else if (cat.contains('shake')) {
      return Icon(Icons.icecream, color: accentColor);
    } else if (cat.contains('smoothie')) {
      return Icon(Icons.local_drink, color: accentColor);
    } else if (cat.contains('mojito')) {
      return Icon(Icons.spa, color: accentColor);
    } else if (cat.contains('burger')) {
      return Icon(Icons.fastfood, color: accentColor);
    } else if (cat.contains('pizza')) {
      return Icon(Icons.local_pizza, color: accentColor);
    } else if (cat.contains('pasta')) {
      return Icon(Icons.ramen_dining, color: accentColor);
    } else if (cat.contains('wrap')) {
      return Icon(Icons.wrap_text, color: accentColor);
    } else if (cat.contains('snack')) {
      return Icon(Icons.food_bank, color: accentColor);
    } else {
      return Icon(Icons.restaurant_menu, color: accentColor);
    }
  }
}
