import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final bool isLoading;

  const ProgressIndicatorWidget({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: LinearProgressIndicator(),
    )
        : const SizedBox.shrink();
  }
}
