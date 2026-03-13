import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  final List<String> menuImages = const [
    'images/CupsConesMenu.jpg',
    'images/SundaesMenu.jpg',
    'images/ShakesMenu.jpg',
    'images/MiscMenu.jpg',
    'images/CoffeeMenu.jpg',
    'images/CakesMenu.jpg',
    'images/PansMenu.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Adjusted logic:
    // - On mobile (< 600px wide), show 2 columns so they aren't too small.
    // - On laptop/web, show 3 columns so they are nice and large.
    int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 2; 
    } else {
      crossAxisCount = 3; 
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Menu'),
        backgroundColor: Colors.pink[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: menuImages.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75, // Keeps your 3/4 aspect ratio
          ),
          itemBuilder: (context, index) {
            final imagePath = menuImages[index];
            
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
