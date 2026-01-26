import 'package:flutter/material.dart';

class CommonUI {
  // 1. Modern Input Style for TextFormFields
  // Added support for Error Borders to show validation messages
  static InputDecoration modernInputStyle({
    String? hintText, 
    IconData? prefixIcon, 
    Widget? suffixIcon
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon != null 
          ? Icon(prefixIcon, size: 20, color: Colors.grey[600]) 
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF1F5F9), // Light blue-grey background
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      
      // Default Border
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      
      // Border when user clicks the field
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
      ),

      // Border when validation fails
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
    );
  }

  // 2. Consistent Label Builder
  static Widget buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontSize: 14,
        ),
      ),
    );
  }

  // 3. Shared Button Style (Optional - Use for consistent elevation/radius)
  static ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1E88E5),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // 4. Custom SnackBar for Feedback
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    // Check if the context is still valid
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Clear existing ones
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}