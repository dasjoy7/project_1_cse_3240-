import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/features/splash/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nhwgurshhxvgwauexdlw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5od2d1cnNoaHh2Z3dhdWV4ZGx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1OTYzMDQsImV4cCI6MjA4MjE3MjMwNH0.LlcfKbZgN2v5r9zZdmyBdT7aVYsCdLHK0GOomQllemw',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}