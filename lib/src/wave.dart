import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class Wave extends StatefulWidget {
  final double value;
  final Color? color;
  final Axis direction;
  final WavesOptions? wavesOptions;

  const Wave({
    Key? key,
    required this.value,
    required this.color,
    required this.direction,
    this.wavesOptions
  }) : super(key: key);

  @override
  _WaveState createState() => _WaveState();
}

class _WaveState extends State<Wave> with TickerProviderStateMixin {

  late AnimationController _waveAnimationController;

  late AnimationController _valueAnimationController;

  @override
  void initState() {
    super.initState();
    _waveAnimationController = AnimationController(
        vsync: this
    );
    _valueAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300)
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant Wave oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() async {
    _valueAnimationController.animateTo(widget.value, duration: Duration(milliseconds: 300));
    _waveAnimationController..duration = widget.wavesOptions?.waveDuration;
    _waveAnimationController..reverseDuration = widget.wavesOptions?.waveDuration;
    await _waveAnimationController.forward();
    _waveAnimationController.repeat();
  }

  @override
  void dispose() {
    _valueAnimationController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(
        parent: _waveAnimationController,
        curve: Curves.elasticIn,
        reverseCurve: Curves.elasticOut,
      ),
      builder: (context, child) => Transform.scale(
        scaleX: (widget.wavesOptions?.isReverse ?? false) ? -1 : 1,
        child: ClipPath(
          child: Container(
              decoration: BoxDecoration(
                color: widget.wavesOptions?.waveColor,
                gradient: widget.wavesOptions?.gradient,
              )
          ),
          clipper: _WaveClipper(
            animationValue: _waveAnimationController.value,
            value: _valueAnimationController.value,
            direction: widget.direction,
          ),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double animationValue;
  final double? value;
  final Axis direction;

  _WaveClipper({
    required this.animationValue,
    required this.value,
    required this.direction,
  });

  @override
  Path getClip(Size size) {
    if (direction == Axis.horizontal) {
      Path path = Path()
        ..addPolygon(_generateHorizontalWavePath(size), false)
        ..lineTo(0.0, size.height)
        ..lineTo(0.0, 0.0)
        ..close();
      return path;
    }

    Path path = Path()
      ..addPolygon(_generateVerticalWavePath(size), false)
      ..lineTo(size.width, size.height)
      ..lineTo(0.0, size.height)
      ..close();
    return path;
  }

  List<Offset> _generateHorizontalWavePath(Size size) {
    final waveList = <Offset>[];
    for (int i = -2; i <= size.height.toInt() + 2; i++) {
      final waveHeight = (size.width / 20);
      final dx = math.sin((animationValue * 360 - i) % 360 * (math.pi / 180)) *
              waveHeight +
          (size.width * value!);
      waveList.add(Offset(dx, i.toDouble()));
    }
    return waveList;
  }

  List<Offset> _generateVerticalWavePath(Size size) {
    final waveList = <Offset>[];
    for (int i = -2; i <= size.width.toInt() + 2; i++) {
      final waveHeight = (size.height / 20);
      final dy = math.sin((animationValue * 360 - i) % 360 * (math.pi / 180)) *
              waveHeight +
          (size.height - (size.height * value!));
      waveList.add(Offset(i.toDouble(), dy));
    }
    return waveList;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) =>
      animationValue != oldClipper.animationValue;
}
