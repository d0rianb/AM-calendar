import 'package:flutter/material.dart';

class NoInformationWidget extends StatelessWidget {
  const NoInformationWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Pas d\'information disponible',
        style: TextStyle(
          color: Colors.blueGrey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
