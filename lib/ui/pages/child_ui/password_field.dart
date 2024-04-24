import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  PasswordFieldState createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _toggleVisibility(bool visible) {
    setState(() {
      _obscureText = !visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: 'App-Password',
        suffixIcon: GestureDetector(
          onLongPressStart: (_) => _toggleVisibility(true),
          onLongPressEnd: (_) => _toggleVisibility(false),
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }
}
