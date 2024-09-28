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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: SizedBox(
          width: 300,
          height: 200,
          child: CardCascade(),
        ),
      ),
    );
  }
}

class CardCascade extends StatefulWidget {
  const CardCascade({super.key});

  @override
  State<CardCascade> createState() => _CardCascadeState();
}

class _CardCascadeState extends State<CardCascade> {
  late List<CardData> cards;

  @override
  void initState() {
    super.initState();

    cards = [
      CardData(key: GlobalKey(), color: Colors.red),
      CardData(key: GlobalKey(), color: Colors.green),
      CardData(key: GlobalKey(), color: Colors.blue),
      CardData(key: GlobalKey(), color: Colors.yellow),
      CardData(key: GlobalKey(), color: Colors.purple),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...cards.asMap().entries.map(
              (entry) => Card(
                key: entry.value.key,
                index: entry.key,
                color: entry.value.color,
                onTap: _onCardSwipe,
              ),
            )
      ],
    );
  }

  void _onCardSwipe(bool? isRight) {
    if (isRight == true) {
      setState(() {
        final temp = cards.removeLast();

        cards = [temp, ...cards];
      });
    }
  }
}

class CardData {
  const CardData({required this.key, required this.color});

  final GlobalKey key;
  final Color color;
}

class Card extends StatefulWidget {
  const Card({
    super.key,
    required this.index,
    required this.color,
    this.onCardSwipe,
    this.onTap,
  });

  final int index;
  final Color color;
  final Function(bool?)? onCardSwipe;
  final Function(bool?)? onTap;

  @override
  State<Card> createState() => _CardState();
}

class _CardState extends State<Card> with TickerProviderStateMixin {
  late Offset _initialPosition;
  late Offset _position;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  Animation<Offset>? _animation;

  late final AnimationController _zIndexController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  Animation<double>? _zIndexAnimation;

  @override
  void initState() {
    super.initState();

    _initialPosition = Offset.zero;
    _position = _initialPosition;

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animation = null;
      }
    });
  }

  @override
  void didUpdateWidget(covariant Card oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.index != oldWidget.index) {
      _zIndexAnimation = Tween(
        begin: oldWidget.index.toDouble(),
        end: widget.index.toDouble(),
      ).animate(_zIndexController);

      _initialPosition = Offset.zero;
      _position = _initialPosition;

      _zIndexController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
    _zIndexController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _zIndexController,
      builder: (context, child) {
        double index = _zIndexAnimation?.value.toDouble() ?? widget.index.toDouble();

        return Transform(
          transform: Matrix4.translationValues(-index * 16 + _position.dx, index * 8 + _position.dy, 0),
          alignment: FractionalOffset.center,
          child: GestureDetector(
            onTap: () {
              if (_zIndexController.isAnimating) return;
              widget.onTap?.call(true);
            },
            onPanUpdate: (details) {
              setState(() {
                _position += details.delta;
              });
            },
            onPanEnd: (details) {},
            child: Container(
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
