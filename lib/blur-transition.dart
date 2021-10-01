import 'dart:ui';

import 'package:flutter/cupertino.dart';

class BlurTransition extends AnimatedWidget {
  final Animation<double> animation;
  final Widget child;

  BlurTransition({required this.animation, required this.child}) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: animation.value, sigmaY: animation.value),
        child: Container(
          child: child,
        ),
      );
}
