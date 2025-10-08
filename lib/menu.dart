import 'package:flutter/material.dart';
import 'package:lcc_web_app/utils/asset_path.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  // Replace with your actual menu images in assets/images/menu/
  final List<String> menuImages = const [
    'images/designer-30-.png',
    'images/designer-31-.png',
    'images/designer-32-.png',
    'images/designer-34-.png',
    'images/designer-35-.png',
    'images/designer-36-.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Menu'),
        backgroundColor: Colors.pink[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: menuImages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3 / 4, // adjust as needed
          ),
          itemBuilder: (context, index) {
            final imagePath = menuImages[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}
