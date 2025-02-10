import 'package:flutter/material.dart';

class UrlInputWidget extends StatelessWidget {
  final TextEditingController controller;

  const UrlInputWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'YouTube URL',
        border: OutlineInputBorder(),
      ),
    );
  }
}
