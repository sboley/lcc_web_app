import 'package:flutter/material.dart';
import 'package:lcc_web_app/utils/asset_path.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ice-cream-flavors.dart';
import 'menu.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

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
      "Monday: 2pm - 9pm",
      "Tuesday: 2pm - 9pm",
      "Wednesday: 2pm - 9pm",
      "Thursday: 2pm - 9pm",
      "Friday: 12pm- 10pm",
      "Saturday: 12pm - 9pm",
      "Sunday: 12pm - 9pm"
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _flavorData;

  @override
  void initState() {
    super.initState();
    const flavorsUrl =
        "https://raw.githubusercontent.com/sboley/lakecity_app_build_web/main/flavors.txt";
    final service = FlavorService(flavorsUrl);
    _flavorData = service.getFlavorData();
  }

  void _launchFlavors(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const FlavorScreen(
          flavorsUrl:
          "https://raw.githubusercontent.com/sboley/lakecity_app_build_web/main/flavors.txt",
        ),
      ),
    );
  }

  void _launchMenu(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MenuScreen()),
    );
  }

  Future<void> _launchShare() async {
    final url = Uri.parse('https://www.facebook.com/LakeCityCreamery/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchMap() async {
    final url = Uri.parse(
        'https://www.google.com/search?q=lake+city+creamery&oq=lake+city+creamery');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.pink[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade200, Colors.pink.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  '🍨 Lake City Creamery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.icecream_outlined, color: Colors.pink),
              title: const Text('Flavors'),
              onTap: () => _launchFlavors(context),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu, color: Colors.pink),
              title: const Text('Menu'),
              onTap: () => _launchMenu(context),
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.pink),
              title: const Text('Location'),
              onTap: _launchMap,
            ),
            ListTile(
              leading: const Icon(Icons.facebook, color: Colors.pink),
              title: const Text('Facebook'),
              onTap: _launchShare,
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                '© 2025 Lake City Creamery',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Lake City Creamery & Coffee',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.pink[100],
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _flavorData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final flavors = snapshot.data?["flavors"] as List<String>? ?? [];
            final daily = snapshot.data?["daily"] as String? ?? "Loading...";
            final hours = snapshot.data?["hours"] as List<String>? ??
                ["Hours unavailable"];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
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
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink),
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
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.schedule, color: Colors.pink),
                                SizedBox(width: 8),
                                Text(
                                  "Hours",
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...hours.map((h) =>
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0),
                                child: Text(
                                  h,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                    textAlign: TextAlign.center,
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Logo
                    Image.asset(
                      'images/lcc-copy.png',
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The best homemade ice cream anywhere!',
                      style: TextStyle(
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Navigation icons
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      children: [
                        _HomeIcon(
                          icon: Icons.icecream,
                          color: Colors.deepPurpleAccent,
                          label: 'FLAVORS',
                          onTap: () => _launchFlavors(context),
                        ),
                        _HomeIcon(
                          icon: Icons.restaurant_menu,
                          color: Colors.pink[300]!,
                          label: 'MENU',
                          onTap: () => _launchMenu(context),
                        ),
                        _HomeIcon(
                          icon: Icons.share,
                          color: Colors.blueAccent,
                          label: 'FACEBOOK',
                          onTap: _launchShare,
                        ),
                        _HomeIcon(
                          icon: Icons.near_me,
                          color: Colors.green,
                          label: 'INFO',
                          onTap: _launchMap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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

class _HomeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _HomeIcon({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            icon: Icon(icon),
            iconSize: 36,
            color: color,
            onPressed: onTap,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
