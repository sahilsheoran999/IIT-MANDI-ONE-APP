import 'package:project/dine/treepie_page.dart';
import 'package:flutter/material.dart';
import 'monal_page.dart';
import 'daig_page.dart';
import 'drongo.dart';
import 'kuku_page.dart';
import 'magpie_page.dart';
import 'tragopan_page.dart';
import 'bulbul_page.dart';
import 'foodoclock_page.dart';
import 'bakeomocha_page.dart';
import 'griffin_page.dart';
import 'package:project/styles/fontstyle.dart';

// Define custom color scheme
class AppColors {
  static const Color primaryGreen = Color(0xFF7A9064);
  static const Color darkGreen = Color(0xFF283021);
  static const Color background = Color(0xFF000000);
  static const Color cardBackground = Color(0xFF121212);
  static const Color textLight = Color(0xFFF0F0F0);
  static const Color dividerColor = Color(0xFF333333);
}

class CanteenPage extends StatelessWidget {
  const CanteenPage({Key? key}) : super(key: key);

  void navigateTo(BuildContext context, String title) {
    if (title == 'Mess Menu') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MessMenuPage()));
    } else if (title == 'Monal') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MonalPage()));
    } else if (title == 'Daig') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DaigPage()));
    } else if (title == 'Drongo') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DrongoPage()));
    } else if (title == 'Kuku Canteen') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const KukuPage()));
    } else if (title == 'Magpie') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MagpieCanteenMenu()));
    } else if (title == 'Bulbul') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BulbulCanteenMenu()));
    } else if (title == 'Tragopan') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TragopanPage()));
    } else if (title == 'Food O Clock') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const FoodOClockMenu()));
    } else if (title == 'Bake O Mocha') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BakeOMochaPage()));
    } else if (title == 'Griffin') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const GriffinPage()));
    } else if (title == 'Tree Pie') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TreepiePage()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PlaceholderPage(title: title)));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text(
            'Mess & Canteens',
            style: mainHeadingStyle(context),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                AppColors.background.withOpacity(0.8),
              ],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle(context, 'Mess'),
              _buildCanteenCard(context, 'Mess Menu', 'View today\'s menu', Icons.restaurant_menu),
              const SizedBox(height: 24),
              
              _buildSectionTitle(context, 'North Campus'),
              _buildCanteenGrid(context, [
                {'name': 'Drongo', 'icon': Icons.local_cafe},
                {'name': 'Monal', 'icon': Icons.lunch_dining},
                {'name': 'Bake O Mocha', 'icon': Icons.cake},
                {'name': 'Tragopan', 'icon': Icons.fastfood},
                {'name': 'Daig', 'icon': Icons.soup_kitchen},
                {'name': 'Tree Pie', 'icon': Icons.local_pizza},
                {'name': 'Kuku Canteen', 'icon': Icons.restaurant},
              ]),
              const SizedBox(height: 24),
              
              _buildSectionTitle(context, 'South Campus'),
              _buildCanteenGrid(context, [
                {'name': 'Bulbul', 'icon': Icons.local_dining},
                {'name': 'Griffin', 'icon': Icons.food_bank},
                {'name': 'Food O Clock', 'icon': Icons.access_time},
                {'name': 'Magpie', 'icon': Icons.egg_alt},
              ]),
            ],
          ),
        ),
      
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: mainHeadingStyle(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCanteenCard(BuildContext context, String title, String subtitle, IconData icon) {
    return Card(
      elevation: 4,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => navigateTo(context, title),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: subheadingStyle(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: normalsize(context),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primaryGreen,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCanteenGrid(BuildContext context, List<Map<String, dynamic>> canteens) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: canteens.length,
      itemBuilder: (context, index) {
        final canteen = canteens[index];
        return Card(
          elevation: 3,
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.darkGreen.withOpacity(0.3), width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => navigateTo(context, canteen['name']),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canteen['icon'],
                  size: 32,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 8),
                Text(
                  canteen['name'],
                  textAlign: TextAlign.center,
                  style: subheadingStyle(context)
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkGreen,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 24),
              Text(
                'Coming soon: $title',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'We are working on adding this canteen\'s menu. Check back soon!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessMenuPage extends StatelessWidget {
  const MessMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkGreen,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mess Menu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book,
                size: 80,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 24),
              Text(
                'Today\'s Mess Menu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'The PDF viewer will be implemented here soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}