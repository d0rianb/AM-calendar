import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoInformationWidget extends StatelessWidget {
  const NoInformationWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: const Text(
        'Pas d\'information disponible',
        style: TextStyle(
          color: Colors.blueGrey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
