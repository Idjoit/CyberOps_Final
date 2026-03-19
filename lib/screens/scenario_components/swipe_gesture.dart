import 'package:flutter/material.dart';

class SwipeGesture extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final String leftLabel;
  final String rightLabel;

  const SwipeGesture({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.leftLabel = "Choice B",
    this.rightLabel = "Choice A",
  });

  @override
  State<SwipeGesture> createState() => _SwipeGestureState();
}

class _SwipeGestureState extends State<SwipeGesture>
    with SingleTickerProviderStateMixin {
  double _dragX = 0.0;
  double _rotation = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
      _rotation = _dragX / 400; // subtle rotation
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.25; // 25% of width to trigger swipe

    if (_dragX > threshold) {
      _animateCardOut(screenWidth);
      widget.onSwipeRight();
    } else if (_dragX < -threshold) {
      _animateCardOut(-screenWidth);
      widget.onSwipeLeft();
    } else {
      _animateBackToCenter();
    }
  }

  void _animateBackToCenter() {
    _animation = Tween<double>(begin: _dragX, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller
      ..reset()
      ..addListener(() {
        setState(() {
          _dragX = _animation.value;
          _rotation = _dragX / 400;
        });
      })
      ..forward();
  }

  void _animateCardOut(double endOffset) {
    _animation = Tween<double>(begin: _dragX, end: endOffset)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller
      ..reset()
      ..addListener(() {
        setState(() {
          _dragX = _animation.value;
          _rotation = _dragX / 400;
        });
      })
      ..forward().whenComplete(() {
        setState(() {
          _dragX = 0;
          _rotation = 0;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dragPercent = (_dragX / (screenWidth * 0.25)).clamp(-1.0, 1.0);

    final leftOpacity =
        _dragX < 0 ? (_dragX.abs() / (screenWidth * 0.25)).clamp(0.0, 1.0) : 0.0;
    final rightOpacity =
        _dragX > 0 ? (_dragX / (screenWidth * 0.25)).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Card
          Transform.translate(
            offset: Offset(_dragX, 0),
            child: Transform.rotate(
              angle: _rotation,
              child: widget.child,
            ),
          ),

          // Right (Choice A)
          Positioned(
            right: 20,
            top: 60,
            child: Opacity(
              opacity: rightOpacity,
              child: Transform.scale(
                scale: 1 + rightOpacity * 0.1,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.5, // Prevent overflow
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown, // Auto-resizes text
                    child: Text(
                      widget.rightLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Left (Choice B)
          Positioned(
            left: 20,
            top: 60,
            child: Opacity(
              opacity: leftOpacity,
              child: Transform.scale(
                scale: 1 + leftOpacity * 0.1,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.5, // Prevent overflow
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown, // Auto-resizes text
                    child: Text(
                      widget.leftLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
