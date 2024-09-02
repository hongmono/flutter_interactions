import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BurstIconButton',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const App(title: 'BurstIconButton'),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key, required this.title});

  final String title;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: BurstIconButton(
          icon: const Icon(Icons.favorite),
          pressedIcon: const Icon(Icons.favorite_border),
          onPressed: () {},
        ),
      ),
    );
  }
}

class _IconData {
  final GlobalKey key;
  final AnimationController controller;
  final Animation<double> animation;
  final double shake;

  const _IconData({
    required this.key,
    required this.controller,
    required this.animation,
    required this.shake,
  });
}

class BurstIconButton extends StatefulWidget {
  const BurstIconButton({
    super.key,
    required this.icon,
    this.pressedIcon,
    this.duration = const Duration(milliseconds: 1500),
    this.throttleDuration = const Duration(milliseconds: 100),
    required this.onPressed,
  });

  final Icon icon;
  final Icon? pressedIcon;
  final Duration duration;
  final Duration throttleDuration;
  final VoidCallback? onPressed;

  @override
  State<BurstIconButton> createState() => _BurstIconButtonState();
}

class _BurstIconButtonState extends State<BurstIconButton> with TickerProviderStateMixin {
  late final Duration _duration = widget.duration;

  Timer? _timer;
  late final Duration _throttleDuration = widget.throttleDuration;

  WidgetState? _state;

  final List<_IconData> _icons = [];

  late final _iconSizeFactor = (widget.icon.size ?? Theme.of(context).iconTheme.size ?? 24.0) / (Theme.of(context).iconTheme.size ?? 24.0);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (final icon in _icons)
          AnimatedBuilder(
            animation: icon.controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  10 * sin(icon.animation.value * pi * icon.shake),
                  -100 * icon.animation.value * _iconSizeFactor,
                ),
                child: FadeTransition(
                  opacity: Tween(
                    begin: 1.0,
                    end: 0.0,
                  ).animate(icon.animation),
                  child: widget.icon,
                ),
              );
            },
          ),
        GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onLongPressStart: _onLongPressStart,
          onLongPressEnd: _onLongPressEnd,
          child: _state == WidgetState.pressed ? widget.pressedIcon ?? widget.icon : widget.icon,
        ),
      ],
    );
  }

  void _onTapDown(_) {
    setState(() {
      _state = WidgetState.pressed;
    });
  }

  void _onTapUp(_) {
    setState(() {
      _state = null;
      _createIcon();
    });

    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() {
      _state = null;
    });
  }

  void _onLongPressStart(_) {
    _timer?.cancel();
    _timer = Timer.periodic(_throttleDuration, (_) {
      _createIcon();
    });

    setState(() {
      _state = WidgetState.pressed;
    });
  }

  void _onLongPressEnd(_) {
    _timer?.cancel();
    setState(() {
      _state = null;
    });

    widget.onPressed?.call();
  }

  void _createIcon() {
    final key = GlobalKey();
    final controller = AnimationController(vsync: this, duration: _duration);
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final icon = _IconData(
      key: key,
      controller: controller,
      animation: animation,
      shake: Random().nextDouble() * 3 - 1.5,
    );
    _icons.add(icon);
    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _icons.remove(icon);
        controller.dispose();
      }
    });

    setState(() {});
  }
}
