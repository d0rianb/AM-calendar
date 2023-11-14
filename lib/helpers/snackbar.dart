import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  // The snackbar has to be delayed by one frame to not intersect with the build process
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
        elevation: 2.0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  });
}
