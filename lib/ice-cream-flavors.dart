import 'package:flutter/material.dart';
import 'dart:math';
import 'services/menu_api.dart';

class FlavorScreen extends StatefulWidget {
  const FlavorScreen({Key? key}) : super(key: key);

  @override
  State<FlavorScreen> createState() => _FlavorScreenState();
}

class _FlavorScreenState extends State<FlavorScreen> {
  late Future<MenuData> _flavorData;

  @override
  void initState() {
    super.initState();
    _flavorData = MenuApi().getMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍨 Lake City Creamery'),
        backgroundColor: Colors.pink[100],
      ),
      body: FutureBuilder<MenuData>(
        future: _flavorData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load flavors and hours right now. Please try again later.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final menu = snapshot.data!;
          final flavors = menu.flavors;
          final today = DateTime.now();
          final seed = int.parse('${today.year}${today.month}${today.day}');
          final daily = flavors[Random(seed).nextInt(flavors.length)];
          final hours = menu.hours;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Daily flavor card
                  _buildCard(
                    width: 500, // max width
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.pink, size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Today's Flavor: $daily",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hours card
                  _buildCard(
                    width: 500, // max width
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Center(
                                child: Icon(
                                  Icons.schedule,
                                  color: Colors.pink,
                                  size: 36,
                                ),
                              ),
                              Center(child: SizedBox(width: 12)),
                              Center(
                                child: Text(
                                  "Hours",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...hours.map(
                          (h) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              h,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Flavors list
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Current Flavors:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: flavors.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final flavor = flavors[index];
                      final isDaily = flavor == daily;

                      // if (flavor.contains("SOLD OUT!") && flavor.contains("Salty Caramel")) {
                      //   return Card(
                      //     color: isDaily ? Colors.pink[100] : Colors.white,
                      //     child: ListTile(
                      //       leading: const Icon(Icons.icecream, color: Colors.brown),
                      //       title: Text.rich(
                      //         TextSpan(
                      //           children: [
                      //             const TextSpan(text: "SOLD OUT! "),
                      //             const TextSpan(
                      //               text: "Salty Caramel",
                      //               style: TextStyle(
                      //                 decoration: TextDecoration.lineThrough,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       trailing: isDaily
                      //           ? const Icon(Icons.check_circle, color: Colors.pink)
                      //           : null,
                      //     ),
                      //   );
                      // }

                      return Card(
                        color: isDaily ? Colors.pink[100] : Colors.white,
                        child: ListTile(
                          leading: const Icon(
                            Icons.icecream,
                            color: Colors.brown,
                          ),
                          title: Text(flavor),
                          trailing: isDaily
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.pink,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required Widget child, double? width}) {
    return Container(
      width: width ?? double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50], // card background color
        borderRadius: BorderRadius.circular(20), // rounded corners
        boxShadow: const [
          BoxShadow(
            color: Colors.black45, // shadow color
            blurRadius: 6, // how blurry the shadow is
            offset: Offset(0, 3), // shadow position: horizontal, vertical
          ),
        ],
      ),
      child: child,
    );
  }
}
