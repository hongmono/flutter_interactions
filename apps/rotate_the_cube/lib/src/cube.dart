import 'dart:math';
import 'package:flutter/material.dart';

enum CubeSide { front, right, left, back, top, bottom }

class Cube extends StatelessWidget {
  const Cube({
    super.key,
    this.size = 100.0,
    this.rotateX = 0.0,
    this.rotateY = 0.0,
    this.rotateZ = 0.0,
  });

  final double size;
  final double rotateX;
  final double rotateY;
  final double rotateZ;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(rotateX)
        ..rotateY(rotateY)
        ..rotateZ(rotateZ),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            ...CubeSide.values.where((side) => _isVisible(side, rotateX, rotateY, rotateZ)).map((side) => _buildSide(side)),
          ],
        ),
      ),
    );
  }

  Widget _buildSide(CubeSide side) {
    final sideConfig = _getSideConfig(side);
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateX(sideConfig.xRot)
        ..rotateY(sideConfig.yRot)
        ..rotateZ(sideConfig.zRot)
        ..translate(0.0, 0.0, sideConfig.moveZ ? -size / 2 : size / 2),
      child: Container(
        constraints: BoxConstraints.expand(width: size, height: size),
        color: sideConfig.color,
        foregroundDecoration: BoxDecoration(
          border: Border.all(width: 0.8, color: Colors.black26),
        ),
        alignment: Alignment.center,
        child: Transform.flip(flipY: side == CubeSide.front ? false : true, child: Text(side.name)),
      ),
    );
  }

  bool _isVisible(CubeSide side, double rotateX, double rotateY, double rotateZ) {
    // X축 회전에 대한 보정
    final cosX = cos(rotateX);
    final sinX = sin(rotateX);

    // Y축 회전에 대한 보정
    final cosY = cos(rotateY);
    final sinY = sin(rotateY);

    return switch (side) {
      CubeSide.front => cosX * cosY > 0,
      CubeSide.back => cosX * cosY < 0,
      CubeSide.right => cosX * sinY > 0,
      CubeSide.left => cosX * sinY < 0,
      CubeSide.top => sinX > 0,
      CubeSide.bottom => sinX < 0,
    };
  }

  _SideConfig _getSideConfig(CubeSide side) => switch (side) {
        CubeSide.front => const _SideConfig(color: Colors.red, moveZ: true),
        CubeSide.right => const _SideConfig(color: Colors.green, yRot: pi / 2),
        CubeSide.left => const _SideConfig(color: Colors.blue, yRot: -pi / 2),
        CubeSide.back => const _SideConfig(color: Colors.yellow),
        CubeSide.top => const _SideConfig(color: Colors.purple, xRot: pi / 2),
        CubeSide.bottom => const _SideConfig(color: Colors.orange, xRot: -pi / 2),
      };
}

class _SideConfig {
  final Color color;
  final bool moveZ;
  final double xRot;
  final double yRot;
  final double zRot;

  const _SideConfig({
    required this.color,
    this.moveZ = false,
    this.xRot = 0.0,
    this.yRot = 0.0,
    this.zRot = 0.0,
  });
}
