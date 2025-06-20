import 'package:flutter/material.dart';

class StegLogo extends StatelessWidget {
  final double size;
  final Color color;

  const StegLogo({
    Key? key,
    this.size = 80,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.electric_bolt,
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }
}
