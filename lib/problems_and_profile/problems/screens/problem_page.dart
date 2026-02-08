import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }

    return FutureBuilder(
      future: Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final p = snapshot.data as Map<String, dynamic>;

        return Scaffold(
          body: Column(
            children: [
              Text(p['name'] ?? 'User'),
              Text('Rating: ${p['rating']}'),
            ],
          ),
        );
      },
    );
  }
}

