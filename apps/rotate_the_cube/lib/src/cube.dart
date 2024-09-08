import 'dart:math';
import 'package:flutter/material.dart';

enum _CubeSide { front, right, left, back, top, bottom }

class Cube extends StatefulWidget {
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
  State<Cube> createState() => _CubeState();
}

class _CubeState extends State<Cube> {
  late double size;
  late double _rotateX;
  late double _rotateY;
  late double _rotateZ;

  @override
  void initState() {
    super.initState();

    size = widget.size;

    _rotateX = widget.rotateX;
    _rotateY = widget.rotateY;
    _rotateZ = widget.rotateZ;
  }

  @override
  void didUpdateWidget(covariant Cube oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.size != oldWidget.size) {
      size = widget.size;
    }

    if (widget.rotateX != oldWidget.rotateX) {
      _rotateX = normalizeAngle(widget.rotateX);
    }

    if (widget.rotateY != oldWidget.rotateY) {
      _rotateY = normalizeAngle(widget.rotateY);
    }

    if (widget.rotateZ != oldWidget.rotateZ) {
      _rotateZ = normalizeAngle(widget.rotateZ);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(widget.rotateX)
        ..rotateY(widget.rotateY)
        ..rotateZ(widget.rotateZ),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            if (_isVisible(_CubeSide.front)) _side(_CubeSide.front, color: Colors.red, moveZ: true),
            if (_isVisible(_CubeSide.right)) _side(_CubeSide.right, yRot: pi / 2, color: Colors.green),
            if (_isVisible(_CubeSide.left)) _side(_CubeSide.left, yRot: -pi / 2, color: Colors.blue),
            if (_isVisible(_CubeSide.back)) _side(_CubeSide.back, color: Colors.yellow),
            if (_isVisible(_CubeSide.top)) _side(_CubeSide.top, xRot: pi / 2, color: Colors.purple),
            if (_isVisible(_CubeSide.bottom)) _side(_CubeSide.bottom, xRot: -pi / 2, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _side(
    _CubeSide side, {
    bool moveZ = false,
    double xRot = 0.0,
    double yRot = 0.0,
    double zRot = 0.0,
    double shadow = 0.0,
    Color? color,
  }) {
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
          color: color,
          foregroundDecoration: BoxDecoration(border: Border.all(width: 0.8, color: Colors.black26)),
          alignment: Alignment.center,
          child: Text(side.name),
        ),
      ),
    );
  }

  bool _isVisible(_CubeSide side) {
    if (side == _CubeSide.front) {
      final x = _rotateX < pi / 2 && _rotateX > -pi / 2;
      final y = _rotateY < pi / 2 && _rotateY > -pi / 2;

      return x && y;
    } else if (side == _CubeSide.right) {
      final x = _rotateX < pi / 2 && _rotateX > -pi / 2;
      final y = _rotateY < 2 * pi / 2 && _rotateY > 0;

      return x && y;
    } else if (side == _CubeSide.left) {
      final x = _rotateX < pi / 2 && _rotateX > -pi / 2;
      final y = _rotateY < 0 && _rotateY > -pi;

      return x && y;
    } else if (side == _CubeSide.back) {
      final x = _rotateX < pi / 2 && _rotateX > -pi / 2;
      final y = _rotateY < -pi / 2 || _rotateY > pi / 2;

      return x && y;
    } else if (side == _CubeSide.top) {
      final x = _rotateX > 0 && _rotateX < pi;
      final z = _rotateZ > 0 && _rotateZ < pi;

      return x && z;
    } else if (side == _CubeSide.bottom) {
      final x = _rotateX > 0 && _rotateX < pi;
      final z = _rotateZ < 0 && _rotateZ > -pi;

      return x && z;
    }
    return false;
  }

  /// 각도를 -π에서 π 사이로 정규화합니다.
  double normalizeAngle(double angle) {
    // 2π로 나눈 나머지를 구합니다.
    angle = angle % (2 * pi);

    // -π에서 π 사이의 값으로 조정합니다.
    if (angle > pi) {
      angle -= 2 * pi;
    } else if (angle < -pi) {
      angle += 2 * pi;
    }

    return angle;
  }
}
