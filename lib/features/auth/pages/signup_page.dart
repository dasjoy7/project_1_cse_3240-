import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_1_cse_3240/widgets/common_widgets.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _institutionController = TextEditingController();

  // Selection States
  int _selectedClass = 9; // Default class
  String? _selectedDivision;
  String? _selectedDistrict;

  // Logic: Map Class to Category
  String _getCategoryFromClass(int studentClass) {
    if (studentClass >= 6 && studentClass <= 8) return 'Junior';
    if (studentClass >= 9 && studentClass <= 10) return 'Secondary';
    if (studentClass >= 11 && studentClass <= 12) return 'Higher Sec';
    return 'General';
  }

  final Map<String, List<String>> _locations = {
    'Barishal': ['Barguna', 'Barishal', 'Bhola', 'Jhalokati', 'Patuakhali', 'Pirojpur'],
    'Chattogram': ['Bandarban', 'Brahmanbaria', 'Chandpur', 'Chattogram', 'Cumilla', "Cox's Bazar", 'Feni', 'Khagrachari', 'Lakshmipur', 'Noakhali', 'Rangamati'],
    'Dhaka': ['Dhaka', 'Faridpur', 'Gazipur', 'Gopalganj', 'Kishoreganj', 'Madaripur', 'Manikganj', 'Munshiganj', 'Narayanganj', 'Narsingdi', 'Rajbari', 'Shariatpur', 'Tangail'],
    'Khulna': ['Bagerhat', 'Chuadanga', 'Jashore', 'Jhenaidah', 'Khulna', 'Kushtia', 'Magura', 'Meherpur', 'Narail', 'Satkhira'],
    'Mymensingh': ['Jamalpur', 'Mymensingh', 'Netrokona', 'Sherpur'],
    'Rajshahi': ['Bogura', 'Joypurhat', 'Naogaon', 'Natore', 'Chapainawabganj', 'Pabna', 'Rajshahi', 'Sirajganj'],
    'Rangpur': ['Dinajpur', 'Gaibandha', 'Kurigram', 'Lalmonirhat', 'Nilphamari', 'Panchagarh', 'Rangpur', 'Thakurgaon'],
    'Sylhet': ['Habiganj', 'Moulvibazar', 'Sunamganj', 'Sylhet'],
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDivision == null || _selectedDistrict == null) {
      CommonUI.showSnackBar(context, "Please select Division and District", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      // 1. Auth Sign Up
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = res.user;
      if (user == null) throw Exception("User creation failed.");

      // 2. Insert Profile (Storing ALL Information)
      await supabase.from('profiles').insert({
        'id': user.id, // Links to auth.users UUID
        'full_name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'student_class': _selectedClass,
        'category': _getCategoryFromClass(_selectedClass),
        'division': _selectedDivision,
        'district': _selectedDistrict,
        'institution': _institutionController.text.trim(),
      });

      if (!mounted) return;

      CommonUI.showSnackBar(context, "Success! Check your email to verify account.");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } on PostgrestException catch (e) {
      if (mounted) CommonUI.showSnackBar(context, "Database Error: ${e.message}", isError: true);
    } on AuthException catch (e) {
      if (mounted) CommonUI.showSnackBar(context, e.message, isError: true);
    } catch (e) {
      if (mounted) CommonUI.showSnackBar(context, "Unexpected Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Join the Math Arena", 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Create your account and start solving problems",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
              
              const SizedBox(height: 20),

              CommonUI.buildLabel("Full Name"),
              TextFormField(
                controller: _nameController,
                validator: (v) => v!.isEmpty ? "Full name is required" : null,
                decoration: CommonUI.modernInputStyle(hintText: "Enter your full name", prefixIcon: Icons.person_outline),
              ),

              CommonUI.buildLabel("Username"),
              TextFormField(
                controller: _usernameController,
                validator: (v) => v!.length < 3 ? "Username must be 3+ chars" : null,
                decoration: CommonUI.modernInputStyle(hintText: "@username", prefixIcon: Icons.alternate_email),
              ),

              CommonUI.buildLabel("Email"),
              TextFormField(
                controller: _emailController,
                validator: (v) => !v!.contains('@') ? "Enter a valid email" : null,
                keyboardType: TextInputType.emailAddress,
                decoration: CommonUI.modernInputStyle(hintText: "your.email@example.com", prefixIcon: Icons.email_outlined),
              ),

              CommonUI.buildLabel("Institution"),
              TextFormField(
                controller: _institutionController,
                validator: (v) => v!.isEmpty ? "Institution is required" : null,
                decoration: CommonUI.modernInputStyle(hintText: "School/College name", prefixIcon: Icons.school_outlined),
              ),

              CommonUI.buildLabel("Select Class"),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7, // Classes 6 to 12
                  itemBuilder: (context, index) {
                    int classNum = index + 6;
                    bool selected = _selectedClass == classNum;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedClass = classNum),
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF1E88E5) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text("$classNum",
                            style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text("Category: ${_getCategoryFromClass(_selectedClass)}",
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w600)),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonUI.buildLabel("Division"),
                        DropdownButtonFormField<String>(
                          decoration: CommonUI.modernInputStyle(),
                          value: _selectedDivision,
                          items: _locations.keys.map((d) => DropdownMenuItem(value: d, 
                            child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
                          onChanged: (v) => setState(() {
                            _selectedDivision = v;
                            _selectedDistrict = null;
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonUI.buildLabel("District"),
                        DropdownButtonFormField<String>(
                          decoration: CommonUI.modernInputStyle(),
                          value: _selectedDistrict,
                          items: (_selectedDivision == null) ? [] : _locations[_selectedDivision]!.map((d) => 
                            DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
                          onChanged: (v) => setState(() => _selectedDistrict = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              CommonUI.buildLabel("Password"),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                validator: (v) => v!.length < 6 ? "Password must be 6+ chars" : null,
                decoration: CommonUI.modernInputStyle(
                  hintText: "Create a strong password",
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}