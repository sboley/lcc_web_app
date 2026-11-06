import 'package:flutter/material.dart';
import 'package:lcc_web_app/sessiontracker.dart';
import 'homepage.dart';
// import 'package:flutter_web_plugins/url_strategy.dart';

// Menu data is served by the Railway API; the web app is deployed on Cloudflare.

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Start tracking
  SessionTracker().startSession();

  //  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lake City Creamery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink),
      home: HomePage(), // <-- goes to homepage
    );
  }
}
