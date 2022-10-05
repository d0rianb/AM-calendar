import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
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
}
