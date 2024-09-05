import 'dart:math';
import 'package:flutter/material.dart';

class Cube extends StatefulWidget {
  const Cube({super.key});

  @override
  State<Cube> createState() => _CubeState();
}

class _CubeState extends State<Cube> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  )..repeat();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  final size = 100.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_animation.value * 2 * pi)
            ..rotateY(_animation.value * 2 * pi),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                _side(xRot: pi / 4, yRot: pi / 4, color: Colors.yellow, moveZ: false),
                _side(xRot: -pi / 4, yRot: 0, zRot: pi / 4, color: Colors.purple, moveZ: false),
                _side(xRot: pi / 4, yRot: -pi / 4, color: Colors.orange, moveZ: false),
                _side(xRot: pi / 4, yRot: -pi / 4, color: Colors.red),
                _side(xRot: -pi / 4, yRot: 0, zRot: pi / 4, color: Colors.green),
                _side(xRot: pi / 4, yRot: pi / 4, color: Colors.blue),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _side({bool moveZ = true, double xRot = 0.0, double yRot = 0.0, double zRot = 0.0, double shadow = 0.0, Color? color}) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateX(xRot)
        ..rotateY(yRot)
        ..rotateZ(zRot)
        ..translate(0.0, 0.0, moveZ ? -size / 2 : size / 2),
      child: Container(
        alignment: Alignment.center,
        child: Container(
          constraints: BoxConstraints.expand(width: size, height: size),
          color: color?.withAlpha(0xaa),
          foregroundDecoration: BoxDecoration(
            color: Colors.black.withOpacity(shadow),
            border: Border.all(width: 0.8, color: Colors.black26),
          ),
        ),
      ),
    );
  }
}
