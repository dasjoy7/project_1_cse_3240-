import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/admin%20panel/admin_panel.dart';
import 'package:project_1_cse_3240/main_wrapper.dart';
import 'package:project_1_cse_3240/common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isObscured = true;
  bool _isLoading = false;
  bool _isAdminMode = false; // <-- Tracks whether admin login is selected

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null && mounted) {
        if (_isAdminMode) {
          // Just check if the email exists in the admin table
          final adminCheck = await Supabase.instance.client
              .from('admin')
              .select('email')
              .eq('email', _emailController.text.trim())
              .maybeSingle();

          if (adminCheck != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminPanel()),
            );
          } else {
            await Supabase.instance.client.auth.signOut();
            if (mounted) {
              CommonUI.showSnackBar(
                context,
                "Access denied. You are not an admin.",
                isError: true,
              );
            }
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainWrapper()),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        CommonUI.showSnackBar(context, e.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        CommonUI.showSnackBar(
          context,
          "An unexpected error occurred",
          isError: true,
        );
      }
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
        title: Text(
          _isAdminMode ? "Admin Sign In" : "Sign In",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),

                // ── Dynamic heading based on mode ──
                Text(
                  _isAdminMode ? "Admin Portal" : "Welcome Back",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _isAdminMode
                      ? "Sign in with your administrator credentials."
                      : "Sharpen your skills for the next Olympiad.",
                  style: const TextStyle(color: Colors.grey),
                ),

                // ── Admin Mode Toggle Banner ──
                if (_isAdminMode)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Admin mode active. Only authorized admins can sign in here.",
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                CommonUI.buildLabel("Email"),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Email is required";
                    if (!value.contains('@'))
                      return "Enter a valid email address";
                    return null;
                  },
                  decoration: CommonUI.modernInputStyle(
                    hintText: "Enter your email",
                    prefixIcon: Icons.email_outlined,
                  ),
                ),

                CommonUI.buildLabel("Password"),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscured,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Password is required";
                    return null;
                  },
                  decoration: CommonUI.modernInputStyle(
                    hintText: "Enter Password",
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _isObscured = !_isObscured),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Future: Implementation for password reset
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Main Sign In Button ──
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAdminMode
                          ? Colors.orange
                          : Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isAdminMode ? "Sign In as Admin" : "Sign In",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Toggle: Sign in as Admin / Back to User ──
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isAdminMode = !_isAdminMode;
                        _emailController.clear();
                        _passwordController.clear();
                      });
                    },
                    icon: Icon(
                      _isAdminMode
                          ? Icons.person_outline
                          : Icons.admin_panel_settings_outlined,
                      color: _isAdminMode ? Colors.blue : Colors.orange,
                    ),
                    label: Text(
                      _isAdminMode
                          ? "Back to User Sign In"
                          : "Sign in as Admin",
                      style: TextStyle(
                        color: _isAdminMode ? Colors.blue : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _isAdminMode ? Colors.blue : Colors.orange,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                if (!_isAdminMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        ),
                        child: const Text(
                          "Register Now",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
