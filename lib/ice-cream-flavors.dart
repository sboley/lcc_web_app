import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FlavorScreen extends StatefulWidget {
  final String flavorsUrl;

  const FlavorScreen({Key? key, required this.flavorsUrl}) : super(key: key);

  @override
  State<FlavorScreen> createState() => _FlavorScreenState();
}

class FlavorService {
  final String flavorsUrl;

  FlavorService(this.flavorsUrl);

  Future<Map<String, dynamic>> getFlavorData() async {
    const defaultFlavors = [
      "Vanilla",
      "Chocolate",
      "Strawberry",
      "Cookie Dough",
      "Dulce De Leche",
      "Buckeye"
    ];

    const defaultHours = [
      "Monday: 11am - 9pm",
      "Tuesday: 11am - 9pm",
      "Wednesday: Closed",
      "Thursday: 11am - 9pm",
      "Friday: 11am - 10pm",
      "Saturday: 11am - 10pm",
      "Sunday: 12pm - 8pm"
    ];

    try {
      final response = await http.get(Uri.parse(flavorsUrl));
      if (response.statusCode == 200) {
        final lines = response.body
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

        final hoursStart = lines.indexWhere((line) => line.toUpperCase().contains("# HOURS"));
        final flavorsStart = lines.indexWhere((line) => line.toUpperCase().contains("# FLAVORS"));

        List<String> hours = defaultHours;
        List<String> flavors = defaultFlavors;

        if (hoursStart != -1 && flavorsStart != -1 && hoursStart < flavorsStart) {
          hours = lines.sublist(hoursStart + 1, flavorsStart);
        }

        if (flavorsStart != -1) {
          flavors = lines.sublist(flavorsStart + 1);
        }

        final daily = getDailyFlavor(flavors.isNotEmpty ? flavors : defaultFlavors);

        return {"flavors": flavors, "daily": daily, "hours": hours};
      }
    } catch (_) {}

    final daily = getDailyFlavor(defaultFlavors);
    return {"flavors": defaultFlavors, "daily": daily, "hours": defaultHours};
  }

  String getDailyFlavor(List<String> flavors) {
    final today = DateTime.now();
    final seed = int.parse("${today.year}${today.month}${today.day}");
    final random = Random(seed);
    return flavors[random.nextInt(flavors.length)];
  }
}

class _FlavorScreenState extends State<FlavorScreen> {
  late Future<Map<String, dynamic>> _flavorData;

  @override
  void initState() {
    super.initState();
    final service = FlavorService(widget.flavorsUrl);
    _flavorData = service.getFlavorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍨 Lake City Creamery',),
        backgroundColor: Colors.pink[100],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _flavorData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final flavors = snapshot.data?["flavors"] as List<String>? ?? [];
          final daily = snapshot.data?["daily"] as String? ?? "Loading...";
          final hours = snapshot.data?["hours"] as List<String>? ?? ["Hours unavailable"];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Daily flavor card
                  _buildCard(
                    width: 500,  // max width
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
                                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink),
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
                    width: 500,  // max width
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Center(child: Icon(Icons.schedule, color: Colors.pink, size: 36)),
                              Center(child: SizedBox(width: 12)),
                              Center(
                                child: Text(
                                  "Hours",
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...hours.map((h) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            h,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        )),
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
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

                      return Card(
                        color: isDaily ? Colors.pink[100] : Colors.white,
                        child: ListTile(
                          leading:
                          const Icon(Icons.icecream, color: Colors.brown),
                          title: Text(flavor),
                          trailing: isDaily
                              ? const Icon(Icons.check_circle, color: Colors.pink)
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
        color: Colors.pink[50],                // card background color
        borderRadius: BorderRadius.circular(20), // rounded corners
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,  // shadow color
            blurRadius: 6,          // how blurry the shadow is
            offset: Offset(0, 3),   // shadow position: horizontal, vertical
          ),
        ],
      ),
      child: child,
    );
  }
}
