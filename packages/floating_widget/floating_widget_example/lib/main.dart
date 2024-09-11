import 'dart:async';

import 'package:floating_widget/floating_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return FloatingWidget(
      padding: const EdgeInsets.all(16),
      floatingWidget: TimerWidget(
        onTimerToggle: (value) {
          setState(() {});
        },
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerWidget extends StatefulWidget {
  const TimerWidget({
    super.key,
    this.onTimerToggle,
  });

  final Function(bool)? onTimerToggle;

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> with SingleTickerProviderStateMixin {
  Timer? _timer;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final Animation<Offset> _animation = Tween<Offset>(
    begin: const Offset(0, 1),
    end: const Offset(0, 0),
  ).animate(_controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              if (_timer == null) {
                widget.onTimerToggle?.call(true);
                _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                  if (!mounted) {
                    timer.cancel();
                    return;
                  }
                  setState(() {});
                });
              } else {
                widget.onTimerToggle?.call(false);
                _timer!.cancel();
                _timer = null;
              }
            },
            icon: const Icon(Icons.play_arrow),
          ),
          const SizedBox(width: 8),
          Text(_timer?.isActive == true ? _timer?.tick.toString() ?? '' : 'Timer is stopped'),
        ],
      ),
    );
  }
}
