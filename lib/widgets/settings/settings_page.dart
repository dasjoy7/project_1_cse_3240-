import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_1_cse_3240/features/auth/pages/login_page.dart';

// IMPORTANT: Make sure these import paths are correct based on your folder structure
import 'profile_cards.dart';
import 'package:project_1_cse_3240/widgets/settings/settings_modal.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _supabase = Supabase.instance.client;
  
  Map<String, dynamic> _profileData = {};
  String _userEmail = "";
  bool _isLoading = true;

  // Personal Details Controllers
  final _classController = TextEditingController();
  final _categoryController = TextEditingController();
  final _divisionController = TextEditingController();
  final _districtController = TextEditingController();
  final _institutionController = TextEditingController();

  // Security Controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isPasswordVerified = false; 
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _loadAllUserData();
  }

  Future<void> _loadAllUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = await _supabase.from('profile').select().eq('id', user.id).maybeSingle();

      setState(() {
        _userEmail = user.email ?? "No Email";
        _profileData = data ?? {}; 
        _classController.text = _profileData['student_class']?.toString() ?? '';
        _categoryController.text = _profileData['category']?.toString() ?? '';
        _divisionController.text = _profileData['division']?.toString() ?? '';
        _districtController.text = _profileData['district']?.toString() ?? '';
        _institutionController.text = _profileData['institution']?.toString() ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // --- LOGIC ---

  Future<void> _verifyCurrentPassword(StateSetter setModalState) async {
    setModalState(() => _isVerifying = true);
    try {
      await _supabase.auth.signInWithPassword(
        email: _userEmail, 
        password: _currentPasswordController.text.trim()
      );
      setModalState(() { _isPasswordVerified = true; _isVerifying = false; });
    } catch (e) {
      setModalState(() => _isVerifying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect password"), backgroundColor: Colors.red)
        );
      }
    }
  }

  Future<void> _updatePassword() async {
    if (_newPasswordController.text.length < 6) return;
    try {
      await _supabase.auth.updateUser(UserAttributes(password: _newPasswordController.text.trim()));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Success!"), backgroundColor: Colors.green)
        );
      }
    } catch (e) { /* Error handling */ }
  }

  Future<void> _saveData() async {
    final user = _supabase.auth.currentUser;
    await _supabase.from('profile').update({
      'student_class': _classController.text,
      'category': _categoryController.text,
      'division': _divisionController.text,
      'district': _districtController.text,
      'institution': _institutionController.text,
    }).eq('id', user!.id);
    
    Navigator.pop(context);
    _loadAllUserData();
  }

  // --- MODAL TRIGGERS ---

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _supabase.auth.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPasswordModal() {
    _isPasswordVerified = false;
    _currentPasswordController.clear();
    _newPasswordController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Change Password", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  if (!_isPasswordVerified)
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Current Password", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  if (_isPasswordVerified)
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "New Password", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : () => _isPasswordVerified ? _updatePassword() : _verifyCurrentPassword(setModalState),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPasswordVerified ? Colors.green : Colors.blue, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: _isVerifying ? const CircularProgressIndicator(color: Colors.white) : Text(_isPasswordVerified ? "Update Password" : "Verify Current Password", style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Edit Details", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SettingsModals.buildTextField("Class", _classController),
            SettingsModals.buildTextField("Category", _categoryController),
            SettingsModals.buildTextField("Division", _divisionController),
            SettingsModals.buildTextField("District", _districtController),
            SettingsModals.buildTextField("Institution", _institutionController),
            const SizedBox(height: 20),
            SettingsModals.buildActionButton("Save Details", _saveData),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Account Settings", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ProfileIdentityCard(profileData: _profileData, userEmail: _userEmail),
                  const SizedBox(height: 20),
                  PersonalDetailsCard(profileData: _profileData, onEdit: _showEditModal),
                  const SizedBox(height: 20),
                  SecurityCard(onChangePassword: _showPasswordModal),
                  const SizedBox(height: 20),
                  LogoutCard(onLogout: _showLogoutDialog),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}