

import 'package:flutter/material.dart';

class WavesOptions {

  final Color? waveColor;

  final Gradient? gradient;

  final Duration waveDuration;

  final bool isReverse;

  final Curve? curve;

  const WavesOptions ({
    this.waveColor,
    this.gradient,
    this.waveDuration = const Duration(seconds: 2),
    this.isReverse = false,
    this.curve
  });

}