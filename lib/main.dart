
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'branch manage/branchmobile.dart';
import 'branch manage/clinictable.dart';
import 'firebase_options.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Responsive Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ResponsiveDashboard(),
    );
  }
}

class ResponsiveDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ResponsiveLayout(
        mobileBody: MobileDashboard(),
        tabletBody: TabletDashboard(),
        desktopBody: TabletDashboard(),
      ),
    );
  }
}






class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget tabletBody;
  final Widget desktopBody;

  ResponsiveLayout({
    required this.mobileBody,
    required this.tabletBody,
    required this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          // Mobile layout
          return mobileBody;
        } else if (constraints.maxWidth < 1100) {
          // Tablet layout
          return tabletBody;
        } else {
          // Desktop layout
          return desktopBody;
        }
      },
    );
  }
}