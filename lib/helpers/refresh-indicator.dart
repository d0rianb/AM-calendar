import 'package:flutter/material.dart';

class ShadowedRefreshIndicator extends StatelessWidget {
  final Color color;

  const ShadowedRefreshIndicator({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) => Theme(
        // custom theme for allowing elevation shadow despite material3 in the app theme
        data: Theme.of(context).copyWith(useMaterial3: false),
        child: RefreshProgressIndicator(
          color: color,
          strokeWidth: 2.5,
        ),
      );
}
