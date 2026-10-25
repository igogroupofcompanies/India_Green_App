import 'package:flutter/material.dart';

void showComingSoon(BuildContext context, String title) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('$title — coming soon'),
        duration: const Duration(seconds: 1),
      ),
    );
}
