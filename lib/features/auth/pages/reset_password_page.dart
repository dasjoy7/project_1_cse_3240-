import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_1_cse_3240/common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _otpFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isNewObscured = true;
  bool _isConfirmObscured = true;
  bool _isLoading = false;
  bool _otpVerified = false;

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Step 1: Verify the OTP code
  Future<void> _verifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: _otpController.text.trim(),
        type: OtpType.recovery,
      );

      if (mounted) {
        setState(() => _otpVerified = true);
      }
    } on AuthException catch (e) {
      if (mounted) {
        CommonUI.showSnackBar(context, e.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        CommonUI.showSnackBar(
          context,
          "An unexpected error occurred.",
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Step 2: Update password after OTP verified
  Future<void> _updatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );

      if (mounted) {
        CommonUI.showSnackBar(
          context,
          "Password updated successfully! Please sign in.",
        );

        await Supabase.instance.client.auth.signOut();

        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
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
          "An unexpected error occurred.",
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Resend the OTP code
  Future<void> _resendCode() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(widget.email);
      if (mounted) {
        CommonUI.showSnackBar(context, "New code sent! Check your inbox.");
      }
    } on AuthException catch (e) {
      if (mounted) {
        CommonUI.showSnackBar(context, e.message, isError: true);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _otpVerified ? "Set New Password" : "Enter Reset Code",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: SingleChildScrollView(
          child: _otpVerified ? _buildPasswordStep() : _buildOtpStep(),
        ),
      ),
    );
  }

  // ── Step 1: Enter OTP ──
  Widget _buildOtpStep() {
    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),

          const Text(
            "Check Your Email",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              children: [
                const TextSpan(text: "We sent an 8-digit code to "),
                TextSpan(
                  text: widget.email,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Enter the 8-digit code from your email. It expires in 1 hour.",
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          CommonUI.buildLabel("8-Digit Code"),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 8,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Code is required";
              if (value.length != 8) return "Enter the full 8-digit code";
              return null;
            },
            decoration: CommonUI.modernInputStyle(
              hintText: "00000000",
              prefixIcon: Icons.pin_outlined,
            ).copyWith(counterText: ""),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Verify Code",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: TextButton(
              onPressed: _isLoading ? null : _resendCode,
              child: const Text(
                "Didn't receive a code? Resend",
                style: TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Enter New Password ──
  Widget _buildPasswordStep() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),

          const Text(
            "Set New Password",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const Text(
            "Choose a strong new password for your account.",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Code verified! Enter your new password below.",
                    style:
                        TextStyle(color: Colors.green.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          CommonUI.buildLabel("New Password"),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _isNewObscured,
            validator: (value) {
              if (value == null || value.isEmpty) return "Password is required";
              if (value.length < 6)
                return "Password must be at least 6 characters";
              return null;
            },
            decoration: CommonUI.modernInputStyle(
              hintText: "Enter new password",
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _isNewObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _isNewObscured = !_isNewObscured),
              ),
            ),
          ),

          CommonUI.buildLabel("Confirm Password"),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _isConfirmObscured,
            validator: (value) {
              if (value == null || value.isEmpty)
                return "Please confirm your password";
              if (value != _newPasswordController.text)
                return "Passwords do not match";
              return null;
            },
            decoration: CommonUI.modernInputStyle(
              hintText: "Confirm new password",
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmObscured
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _isConfirmObscured = !_isConfirmObscured),
              ),
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Update Password",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}