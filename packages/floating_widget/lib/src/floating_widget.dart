import 'package:flutter/material.dart';

enum FloatingWidgetSnap { none, side, edge }

class FloatingWidget extends StatefulWidget {
  const FloatingWidget({
    super.key,
    required this.floatingWidget,
    this.initialPosition,
    this.padding = EdgeInsets.zero,
    this.snap = FloatingWidgetSnap.side,
    required this.child,
  });

  final Widget floatingWidget;
  final Offset? initialPosition;
  final Widget child;
  final EdgeInsets padding;
  final FloatingWidgetSnap snap;

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        _TargetWidget(
          floatingWidget: widget.floatingWidget,
          initialPosition: widget.initialPosition,
          padding: widget.padding,
          snap: widget.snap,
        ),
      ],
    );
  }
}

class _TargetWidget extends StatefulWidget {
  const _TargetWidget({
    required this.floatingWidget,
    this.initialPosition,
    this.padding = EdgeInsets.zero,
    required this.snap,
  });

  final Widget floatingWidget;
  final Offset? initialPosition;
  final EdgeInsets padding;
  final FloatingWidgetSnap snap;

  @override
  State<_TargetWidget> createState() => _TargetWidgetState();
}

class _TargetWidgetState extends State<_TargetWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  Animation<Offset> _animation = const AlwaysStoppedAnimation(Offset.zero);

  late Offset _position;
  late Size _floatingWidgetSize;
  final GlobalKey _floatingWidgetKey = GlobalKey();

  late Widget _draggableWidget;

  @override
  void initState() {
    super.initState();

    _position = widget.initialPosition ?? Offset(widget.padding.left, widget.padding.top);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = _floatingWidgetKey.currentContext?.findRenderObject() as RenderBox;
      _floatingWidgetSize = renderBox.size;
    });

    _draggableWidget = Material(
      key: _floatingWidgetKey,
      color: Colors.transparent,
      child: widget.floatingWidget,
    );
  }

  @override
  void didUpdateWidget(covariant _TargetWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.floatingWidget != widget.floatingWidget) {
      _draggableWidget = Material(
        key: _floatingWidgetKey,
        color: Colors.transparent,
        child: widget.floatingWidget,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = _floatingWidgetKey.currentContext?.findRenderObject() as RenderBox;
      _floatingWidgetSize = renderBox.size;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _position.dy,
      left: _position.dx,
      child: Draggable(
        feedback: _draggableWidget,
        childWhenDragging: const SizedBox.shrink(),
        onDraggableCanceled: _updatePosition,
        child: _draggableWidget,
      ),
    );
  }

  void _updatePosition(Velocity velocity, Offset position) {
    if (_controller.isAnimating) return;

    Offset newPosition = position;
    Size screenSize = MediaQuery.of(context).size;

    // 화면 경계 계산
    double leftBoundary = widget.padding.left;
    double rightBoundary = screenSize.width - _floatingWidgetSize.width - widget.padding.right;
    double topBoundary = widget.padding.top;
    double bottomBoundary = screenSize.height - _floatingWidgetSize.height - widget.padding.bottom;

    if (widget.snap == FloatingWidgetSnap.side) {
      // 가장 가까운 벽 찾기
      double distanceToLeft = (position.dx - leftBoundary).abs();
      double distanceToRight = (position.dx - rightBoundary).abs();
      double distanceToTop = (position.dy - topBoundary).abs();
      double distanceToBottom = (position.dy - bottomBoundary).abs();

      final min = [distanceToLeft, distanceToRight, distanceToTop, distanceToBottom].reduce((a, b) => a < b ? a : b);
      final minIndex = [distanceToLeft, distanceToRight, distanceToTop, distanceToBottom].indexOf(min);

      /// 가장 가까운 벽 선택
      newPosition = switch (minIndex) {
        0 => Offset(leftBoundary, position.dy),
        1 => Offset(rightBoundary, position.dy),
        2 => Offset(position.dx, topBoundary),
        3 => Offset(position.dx, bottomBoundary),
        _ => throw Exception('Invalid index: $minIndex'),
      };
    } else if (widget.snap == FloatingWidgetSnap.edge) {
      // 가장 가까운 모서리 찾기
      double distanceToTopLeft = (position - Offset(leftBoundary, topBoundary)).distance;
      double distanceToTopRight = (position - Offset(rightBoundary, topBoundary)).distance;
      double distanceToBottomLeft = (position - Offset(leftBoundary, bottomBoundary)).distance;
      double distanceToBottomRight = (position - Offset(rightBoundary, bottomBoundary)).distance;

      final min = [distanceToTopLeft, distanceToTopRight, distanceToBottomLeft, distanceToBottomRight].reduce((a, b) => a < b ? a : b);
      final minIndex = [distanceToTopLeft, distanceToTopRight, distanceToBottomLeft, distanceToBottomRight].indexOf(min);

      /// 가장 가까운 모서리 선택
      newPosition = switch (minIndex) {
        0 => Offset(leftBoundary, topBoundary),
        1 => Offset(rightBoundary, topBoundary),
        2 => Offset(leftBoundary, bottomBoundary),
        3 => Offset(rightBoundary, bottomBoundary),
        _ => throw Exception('Invalid index: $minIndex'),
      };
    } else {}

    newPosition = Offset(newPosition.dx.clamp(leftBoundary, rightBoundary), newPosition.dy.clamp(topBoundary, bottomBoundary));

    _animation = Tween<Offset>(
      begin: position,
      end: newPosition,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut))
      ..addListener(_update);

    _controller.forward();
  }

  void _update() {
    setState(() {
      _position = _animation.value;
    });

    if (_animation.isCompleted) {
      _animation.removeListener(_update);
      _controller.reset();
    }
  }
}
