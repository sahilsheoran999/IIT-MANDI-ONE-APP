import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart'; // Use your custom font styles here

class TragopanPage extends StatefulWidget {
  const TragopanPage({Key? key}) : super(key: key);

  @override
  State<TragopanPage> createState() => _TragopanPageState();
}

class _TragopanPageState extends State<TragopanPage> {
  final Map<String, List<Map<String, String>>> menu = {
    "Hot Beverages": [
      {"Tea": "₹10"},
      {"Masala Tea": "₹13"},
      {"Special Tea": "₹18"},
      {"Special Herbal Tea": "₹20"},
      {"Lemon Tea": "₹15"},
      {"Black Tea": "₹15"},
      {"Coffee": "₹15"},
      {"Black Coffee": "₹20"},
      {"Milk (200 ml)": "₹20"},
      {"Turmeric Milk": "₹30"},
      {"Bourn Vita Milk": "₹35"},
      {"Hot Chocolate Milk": "₹40"},
    ],
    "Cold Beverages": [
      {"Mineral Water": "MRP"},
      {"Fresh Lemon Water": "₹25"},
      {"Fresh Lime Soda": "₹40"},
      {"Virgin Mint Mojito": "₹70"},
      {"Green Apple": "₹70"},
      {"Blue Lagoon": "₹80"},
      {"Fresh Sweet Lassi": "₹40"},
      {"Fresh Butter Milk": "₹35"},
      {"Peach Ice Tea": "₹60"},
      {"Pinny Paan Mojito": "₹90"},
    ],
    "Fresh Juice Shakes": [
      {"Mosambi Juice (Seasonal)": "₹60"},
      {"Pineapple Juice (Seasonal)": "₹60"},
      {"Pomegranate Juice": "₹90"},
      {"Mix Juice": "₹70"},
      {"Banana Shakes": "₹50"},
      {"Papaya Shakes": "₹50"},
      {"Mango Shakes (Seasonal)": "₹50"},
    ],
    "Shakes & Drinks": [
      {"Butter Scotch": "₹70"},
      {"Pineapple": "₹70"},
      {"Strawberry": "₹70"},
      {"Blueberry Shake": "₹70"},
      {"Black Currant": "₹70"},
      {"Chocolate": "₹80"},
      {"Oreo": "₹80"},
    ],
    "Cold Coffee": [
      {"Lotus Biscoff": "₹70"},
      {"Cold Coffee": "₹60"},
      {"Vintage Cold Coffee": "₹70"},
      {"Irish Cold Coffee": "₹70"},
      {"Hazelnut Cold Coffee": "₹70"},
      {"Caramel Cold Coffee": "₹70 (+₹20 with Ice Cream)"},
    ],
    "Parathas": [
      {"Plain Paratha": "₹20"},
      {"Aloo Paratha": "₹30"},
      {"Sattu Paratha": "₹30"},
      {"Mix Paratha": "₹35"},
      {"Gobhi Paratha (Seasonal)": "₹35"},
      {"Paneer Paratha": "₹40"},
    ],
    "Paratha with Desi Ghee": [
      {"Plain Paratha": "₹30"},
      {"Aloo Paratha": "₹45"},
      {"Mix Paratha": "₹50"},
      {"Sattu Paratha": "₹50"},
      {"Paneer Paratha": "₹55"},
    ],
    "Rolls & Snacks": [
      {"Veg. Roll": "₹50"},
      {"Paneer Roll": "₹60"},
      {"Samosa": "₹15"},
      {"Spl. Samosa (Ghee)": "₹20"},
      {"Bread Pakoda": "₹20"},
      {"Chhole Samosa": "₹60"},
      {"Chhole Kulcha": "₹60"},
      {"Chhole Bhature": "₹70"},
      {"Poha": "₹50"},
    ],
    "Maggi": [
      {"Plain Maggi": "₹30"},
      {"Veg. Maggi": "₹45"},
      {"Paneer Maggi": "₹50"},
      {"Cheese Maggi": "₹50"},
    ],
    "South Indian": [
      {"Plain Dosa": "₹59"},
      {"Butter Plain Dosa": "₹70"},
      {"Masala Dosa": "₹75"},
      {"Butter Masala Dosa": "₹90"},
      {"Paneer Dosa": "₹90"},
      {"Butter Paneer Dosa": "₹110"},
      {"Idli Sambhar": "₹49"},
      {"Vada Sambhar": "₹59"},
      {"Uttapam": "₹60"},
      {"Fried Idli": "₹60"},
    ],
    "Sandwiches & Burgers": [
      {"Bread Butter Toast": "₹30"},
      {"Cold Sandwich": "₹40"},
      {"Veg. Grilled Sandwich": "₹45"},
      {"Jumbo Corn Cheese Sandwich": "₹70"},
      {"Jumbo Paneer Cheese Sandwich": "₹110"},
      {"Aloo Tikki Burger": "₹40"},
      {"Veg. Burger": "₹45"},
      {"Cheese Burger": "₹50"},
      {"Paneer Burger": "₹70"},
      {"Vada Pav": "₹40"},
      {"Pav Bhaji": "₹60"},
      {"Aloo Patties": "₹30"},
      {"Paneer Patties": "₹35"},
    ],
    "Chaat & Momos": [
      {"Samosa Chaat": "₹60"},
      {"Dahi Samosa": "₹50"},
      {"Papdi Chaat": "₹60"},
      {"Aloo Tikki Chaat": "₹60"},
      {"Dahi Bhalla Chaat": "₹60"},
      {"Aloo Peanut Chaat": "₹70"},
      {"Paneer Peanut Chaat": "₹170"},
      {"Pani Puri (6 pcs)": "₹30"},
      {"Veg. Momo (8 pcs)": "₹70"},
      {"Fried Momo (8 pcs)": "₹80"},
      {"Paneer Momo (8 pcs)": "₹99"},
      {"Chilli Momo (8 pcs)": "₹110"},
      {"Peri Peri Momos": "₹80"},
    ],
    "Chinese & Continental": [
      {"Veg Noodles": "₹70"},
      {"Hakka Noodles": "₹90"},
      {"Plain Macaroni": "₹70"},
      {"Cheese Macaroni": "₹100"},
    ],
    "Pasta": [
      {"Red Sauce Pasta": "₹110"},
      {"White Sauce Pasta": "₹120"},
      {"Mix Sauce Pasta": "₹130"},
    ],
    "Pizzas": [
      {"Margherita": "₹120/230/340"},
      {"Cheese & Corn": "₹110/220/330"},
      {"Cheese & Tomato": "₹110/220/330"},
      {"Farm House Fresh": "₹120/230/340"},
      {"Paneer Makhani": "₹140/260/370"},
    ],
    "Cakes (Half/Full Kg)": [
      {"Butter Scotch": "₹350/600"},
      {"Pineapple": "₹350/600"},
      {"Strawberry": "₹350/600"},
      {"Black Forest": "₹350/600"},
      {"Chocolate": "₹400/700"},
      {"Red Velvet": "₹450/800"},
    ],
    "Soup": [
      {"Lemon Coriander": "₹50"},
      {"Veg Soup": "₹50"},
      {"Hot & Sour Soup": "₹60"},
      {"Manchow Soup": "₹60"},
      {"Tomato Soup": "₹70"},
    ],
    "Rice": [
      {"Plain Rice": "₹40/60"},
      {"Jeera Rice": "₹60"},
      {"Peas Pulao": "₹70"},
      {"Veg Pulao": "₹80"},
      {"Shahi Pulao": "₹90"},
      {"Veg Biryani": "₹60/110"},
      {"Paneer Biryani": "₹100/140"},
    ],
    "Rice Bowls": [
      {"Yellow Dal Rice": "₹70"},
      {"Chhole Rice": "₹80"},
      {"Rajma Rice": "₹80"},
      {"Dal Makhani Rice": "₹70"},
      {"Kadhi Pakoda Rice": "₹70"},
      {"Curd Rice": "₹60"},
      {"Dal Khichdi": "₹80"},
      {"Veg. Khichdi": "₹80"},
      {"Sambhar Rice": "₹70"},
      {"Lemon Rice": "₹90"},
    ],
    "Roti": [
      {"Tawa Roti": "₹9"},
      {"Butter Roti": "₹13"},
      {"Tandoori Roti": "₹20"},
      {"Tandoori Butter Roti": "₹25"},
      {"Plain Naan": "₹30"},
      {"Butter Naan": "₹40"},
      {"Stuffed Naan": "₹50"},
      {"Paneer Naan": "₹60"},
      {"Lachha Paratha": "₹40"},
      {"Missi Roti": "₹30"},
    ],
    "Raita & Salad": [
      {"Boondi Raita": "₹40"},
      {"Veg Raita": "₹40"},
      {"Green Salad": "₹50"},
      {"Masala Papad": "₹20"},
      {"Dahi Bowl": "₹29"},
    ],
    "Main Course": [
      {"Dal Fry": "₹55/100"},
      {"Dal Tadka": "₹60/110"},
      {"Dal Makhani": "₹70/130"},
      {"Chhole Special": "₹60/110"},
      {"Rajma Special": "₹60/110"},
      {"Kadhi Pakoda": "₹60/110"},
      {"Aloo Jeera": "₹60/110"},
      {"Aloo Matar": "₹60/110"},
      {"Ghar Wali Sabji": "₹60/110"},
      {"Aloo Palak (Seasonal)": "₹70/130"},
      {"Mix Veg": "₹70/130"},
      {"Gobhi Masala (Seasonal)": "₹70/130"},
      {"Bhindi Masala (Seasonal)": "₹70/130"},
      {"Channa Masala": "₹70/130"},
      {"Veg Kofta": "₹80/140"},
      {"Palak Paneer (Seasonal)": "₹80/140"},
      {"Matar Paneer": "₹80/140"},
      {"Kadhi Paneer": "₹90/150"},
      {"Shahi Paneer": "₹90/150"},
      {"Paneer Butter Masala": "₹90/150"},
      {"Paneer Lababdar": "₹90/150"},
      {"Paneer Bhurji": "₹90/150"},
      {"Malai Kofta": "₹100/150"},
      {"Cheese Tomato": "₹100/150"},
    ],
    "Thalis": [
      {"Ghar Ki Thali": "₹89"},
      {"Maa Wali Thali": "₹99"},
      {"Mini Deluxe Thali": "₹149"},
      {"Special Thali": "₹199"},
      {"Deluxe Thali": "₹249"},
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
        title: Text('Tragopan Canteen', style: mainHeadingStyle(context)),
      
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image banner
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/tragopan_photo.jpg', fit: BoxFit.cover),
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
                            'Location: Near Main Library',
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
                            'Timing: Monday to Sunday, 8 AM - 10 PM',
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
                          'Contact: +91 9876543210',
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
            // Display filtered or full menu
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
    if (category.toLowerCase().contains('starter')) {
      return Icon(Icons.local_dining, color: accentColor);
    } else if (category.toLowerCase().contains('main')) {
      return Icon(Icons.restaurant_menu, color: accentColor);
    } else if (category.toLowerCase().contains('beverage')) {
      return Icon(Icons.local_cafe, color: accentColor);
    } else if (category.toLowerCase().contains('dessert')) {
      return Icon(Icons.icecream, color: accentColor);
    } else {
      return Icon(Icons.fastfood, color: accentColor);
    }
  }
}
