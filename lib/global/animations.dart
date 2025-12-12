
import 'package:flutter/material.dart';
import 'dart:async';

class BeatingCircleDemo extends StatefulWidget {
  const BeatingCircleDemo({Key? key}) : super(key: key);

  @override
  State<BeatingCircleDemo> createState() => _BeatingCircleDemoState();
}

class _BeatingCircleDemoState extends State<BeatingCircleDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  Color _color1 = Colors.blue;
  Color _color2 = Colors.pink;
  late Color _currentColor;
  late Timer _colorTimer;

  @override
  void initState() {
    super.initState();

    _currentColor = _color1;

    // Scale animation (heartbeat)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Change color every second
    _colorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentColor = _currentColor == _color1 ? _color2 : _color1;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _colorTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _currentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _currentColor.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
    );
  }
}
