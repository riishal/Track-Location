import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  const CustomTextField(
      {super.key,
      this.hintText,
      this.icon,
      this.keyboardType,
      this.controller,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.06,
      child: TextField(
          controller: controller,
          cursorColor: Colors.black,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Colors.black,
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.zero,
              hintText: hintText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ))),
    );
  }
}
