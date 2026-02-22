import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/features/splash/splash_screen.dart';
import 'package:project_1_cse_3240/main_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nhwgurshhxvgwauexdlw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5od2d1cnNoaHh2Z3dhdWV4ZGx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1OTYzMDQsImV4cCI6MjA4MjE3MjMwNH0.LlcfKbZgN2v5r9zZdmyBdT7aVYsCdLHK0GOomQllemw',
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  // Check if user is logged in
  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _isLoggedIn = session != null; // If session exists, user is logged in
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isLoggedIn ? MainWrapper() : SplashScreen(),
    );
  }
}
