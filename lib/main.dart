import 'package:flutter/material.dart';
import 'homepage.dart'; // Make sure this path is correct
// import 'package:flutter_web_plugins/url_strategy.dart';

//This is the Web App only for Lake City Creamery.
//it is stored in the github repository lcc_web_app/gh-pages
//the flavors.txt that stores the hours and the flavors is in the github repository lakecity_app_buile_web. The only thing in the repository is the the flavors.txt. It has a github page assocated with it.


void main() {
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
