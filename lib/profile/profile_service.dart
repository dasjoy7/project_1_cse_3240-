import 'package:supabase_flutter/supabase_flutter.dart';
import '../home/home_models.dart';

class ProfileService {
  static final _client = Supabase.instance.client;
  static String get _userId => _client.auth.currentUser!.id;

  static Future<UserProfile> fetchProfile() async {
    final data = await _client
        .from('profile')
        .select()
        .eq('id', _userId)
        .single();
    return UserProfile.fromMap(data);
  }

  static Future<void> updateProfile({
    required String fullName,
    required int studentClass,
    required String category,
    required String division,
    required String district,
    required String institution,
  }) async {
    await _client.from('profile').update({
      'full_name': fullName,
      'student_class': studentClass,
      'category': category,
      'division': division,
      'district': district,
      'institution': institution,
    }).eq('id', _userId);
  }
}