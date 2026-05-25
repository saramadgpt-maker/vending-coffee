import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:venidng_coffee/theme/app_theme.dart';

/// سناریوی «انتظار شیرین» — ۳۸ ثانیه، کاملاً انیمیشنی
class SweetWaitCinema extends StatefulWidget {
  const SweetWaitCinema({
    super.key,
    this.onFinished,
    this.onProgress,
    this.duration = const Duration(milliseconds: 38000),
  });

  final VoidCallback? onFinished;
  final ValueChanged<double>? onProgress;
  final Duration duration;

  @override
  State<SweetWaitCinema> createState() => _SweetWaitCinemaState();
}

class _SweetWaitCinemaState extends State<SweetWaitCinema>
    with TickerProviderStateMixin {
  late final AnimationController _master;
  late final AnimationController _wiggle;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _master = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onFinished?.call();
      });
    _wiggle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..repeat(reverse: true);
    _t = CurvedAnimation(parent: _master, curve: Curves.linear);
    _master.addListener(() => widget.onProgress?.call(_t.value));
    _master.forward();
  }

  @override
  void dispose() {
    _master.dispose();
    _wiggle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_master, _wiggle]),
      builder: (context, _) {
        return CustomPaint(
          painter: _SweetWaitPainter(t: _t.value, wiggle: _wiggle.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

/// زمان‌بندی سناریو (۰ تا ۱)
class _Scenario {
  _Scenario(this.t);

  final double t;

  bool get isPhase1 => t < 10 / 38;
  bool get isPhase2 => t >= 10 / 38 && t < 30 / 38;
  bool get isPhase3 => t >= 30 / 38;

  double get phase1Local => (t / (10 / 38)).clamp(0.0, 1.0);
  double get phase2Local => ((t - 10 / 38) / (20 / 38)).clamp(0.0, 1.0);
  double get phase3Local => ((t - 30 / 38) / (8 / 38)).clamp(0.0, 1.0);

  double get cameraZoom => isPhase1 ? ui.lerpDouble(1.18, 1.0, phase1Local)! : 1.0;

  bool get showHand => t < 0.12;
  double get handOpacity => t < 0.06 ? 1 : (1 - (t - 0.06) / 0.06).clamp(0.0, 1.0);

  /// فنر — خیلی آرام بالا می‌رود و گیر می‌کند
  double get springT {
    if (t < 0.08) return 0;
    if (t < 0.78) {
      final crawl = ((t - 0.08) / 0.7);
      return Curves.easeOut.transform(crawl) * 0.92;
    }
    return 0.92;
  }

  bool get cupDropped => t >= 0.86;
  double get dropProgress =>
      cupDropped ? Curves.easeIn.transform(((t - 0.86) / 0.08).clamp(0.0, 1.0)) : 0;

  bool get showThud => t >= 0.86 && t < 0.94;
  double get thudOpacity =>
      showThud ? (1 - ((t - 0.86) / 0.08)).clamp(0.0, 1.0) : 0;

  bool get isDancing => t >= 0.72 && t < 0.9;
  bool get isCelebrating => t >= 0.9;

  double get footTap => isPhase2 ? math.sin(t * math.pi * 14) * 4 : 0;
  bool get lookWatch => isPhase2 && phase2Local > 0.15 && phase2Local < 0.35;
  bool get leanMachine => isPhase2 && phase2Local > 0.35 && phase2Local < 0.55;
  bool get faceOnGlass => isPhase2 && phase2Local > 0.55 && phase2Local < 0.85;
  bool get isDrumming => isDancing && phase3Local < 0.5;
  bool get isFullDance => isDancing && phase3Local >= 0.5;

  double get dancePhase => isDancing ? t * math.pi * 8 : 0;
  double get machineShake =>
      isDancing ? math.sin(t * math.pi * 20) * 3 * (1 - dropProgress) : 0;
}

class _SweetWaitPainter extends CustomPainter {
  _SweetWaitPainter({required this.t, required this.wiggle});

  final double t;
  final double wiggle;

  @override
  void paint(Canvas canvas, Size size) {
    final s = _Scenario(t);
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(s.cameraZoom);
    canvas.translate(-cx, -cy);

    _drawFloor(canvas, size);
    _drawMachine(canvas, size, s);
    if (s.showHand) _drawPaymentHand(canvas, size, s);
    _drawCharacter(canvas, size, s);
    if (s.isDrumming || s.isFullDance) _drawMusicNotes(canvas, size, s);
    if (s.showThud) _drawThud(canvas, size, s);
    if (s.isCelebrating) _drawCelebration(canvas, size, s);

    canvas.restore();
  }

  void _drawFloor(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.84, size.width, size.height * 0.16),
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );
  }

  _Layout _layout(Size size, _Scenario s) {
    final mx = size.width * 0.48 + s.machineShake;
    final my = size.height * 0.12;
    final mw = size.width * 0.46;
    final mh = size.height * 0.68;
    final springTop = my + mh * 0.22;
    final springBottom = my + mh * 0.58;
    final cupY = ui.lerpDouble(
      springBottom,
      springTop,
      s.springT,
    )!;
    final slotY = my + mh * 0.72;
    final finalCupY = s.cupDropped ? ui.lerpDouble(cupY, slotY, s.dropProgress)! : cupY;

    return _Layout(
      machine: Rect.fromLTWH(mx, my, mw, mh),
      cupPos: Offset(mx + mw * 0.52, finalCupY),
      slotY: slotY,
      springTop: springTop,
      springBottom: springBottom,
    );
  }

  void _drawMachine(Canvas canvas, Size size, _Scenario s) {
    final l = _layout(size, s);
    final r = l.machine;

    // بدنه
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(14)),
      Paint()
        ..shader = ui.Gradient.linear(
          r.topLeft,
          r.bottomRight,
          [const Color(0xFF3A3A3A), const Color(0xFF1A1A1A)],
        ),
    );

    // شیشه
    final glass = Rect.fromLTWH(r.left + 12, r.top + 14, r.width - 24, r.height * 0.62);
    canvas.drawRRect(
      RRect.fromRectAndRadius(glass, const Radius.circular(8)),
      Paint()..color = const Color(0xFF87CEEB).withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(glass, const Radius.circular(8)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.25),
    );

    // فنر مارپیچ
    _drawSpring(canvas, Offset(glass.center.dx, l.springTop), l.springBottom - l.springTop, s);

    // لیوان روی فنر
    if (!s.isCelebrating || s.dropProgress < 1) {
      _drawCoffeeCup(canvas, l.cupPos, s.cupDropped && s.dropProgress > 0.5 ? 1.1 : 1.0);
    }

    // دریچه تحویل
    final slot = Rect.fromLTWH(r.left + r.width * 0.25, l.slotY, r.width * 0.5, 28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(slot, const Radius.circular(6)),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(slot, const Radius.circular(6)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = AppColors.accent.withValues(alpha: 0.5)
        ..strokeWidth = 2,
    );

    // چراغ روشن
    final lightOn = s.t > 0.04;
    canvas.drawCircle(
      Offset(r.right - 22, r.top + 22),
      8,
      Paint()
        ..color = lightOn
            ? AppColors.success.withValues(alpha: 0.9 + wiggle * 0.1)
            : Colors.grey.withValues(alpha: 0.3),
    );

  if (s.isPhase1 && s.t > 0.05) {
      _drawBeepWaves(canvas, Offset(r.right - 22, r.top + 22), s.phase1Local);
    }

    // برچسب
    final label = TextPainter(
      text: TextSpan(
        text: 'COFFEE',
        style: TextStyle(
          color: AppColors.accent.withValues(alpha: 0.8),
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, Offset(r.left + 16, r.top + 12));
  }

  void _drawSpring(Canvas canvas, Offset top, double height, _Scenario s) {
    final path = Path()..moveTo(top.dx, top.dy);
    final coils = 8;
    for (var i = 0; i <= coils; i++) {
      final y = top.dy + (height / coils) * i;
      final x = top.dx + math.sin(i * 1.2 + (s.isPhase2 ? wiggle * 2 : 0)) * 10;
      path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawCoffeeCup(Canvas canvas, Offset c, double scale) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(scale);
    final w = 28.0;
    final h = 34.0;
    final cup = RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );
    canvas.drawRRect(cup, Paint()..color = Colors.white.withValues(alpha: 0.2));
    canvas.drawRRect(
      cup,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.6),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(center: const Offset(0, 6), width: w - 6, height: h * 0.5),
        bottomLeft: const Radius.circular(6),
        bottomRight: const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF5D4037),
    );
    canvas.restore();
  }

  void _drawPaymentHand(Canvas canvas, Size size, _Scenario s) {
    final opacity = s.handOpacity;
    final handY = ui.lerpDouble(size.height * 0.7, size.height * 0.45, s.phase1Local)!;
    final handX = size.width * 0.55;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(handX + 30, handY - 20), width: 50, height: 32),
        const Radius.circular(6),
      ),
      Paint()..color = AppColors.accent.withValues(alpha: 0.8 * opacity),
    );

    // دست
    canvas.drawOval(
      Rect.fromCenter(center: Offset(handX, handY), width: 70, height: 40),
      Paint()..color = const Color(0xFFE8B89A).withValues(alpha: opacity),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(handX + 40, handY + 5), width: 36, height: 50),
      Paint()..color = const Color(0xFFE8B89A).withValues(alpha: opacity),
    );

    // دکمه
    canvas.drawCircle(
      Offset(handX - 20, handY - 30),
      14,
      Paint()..color = AppColors.accent.withValues(alpha: opacity),
    );
  }

  void _drawCharacter(Canvas canvas, Size size, _Scenario s) {
    final baseX = size.width * 0.22;
    final baseY = size.height * 0.82;
    final lean = s.leanMachine ? 0.15 : 0.0;
    final facePress = s.faceOnGlass ? 28.0 : 0.0;

    canvas.save();
    canvas.translate(baseX + lean * 40, baseY);
    canvas.rotate(lean);

    if (s.isFullDance) {
      canvas.rotate(math.sin(s.dancePhase) * 0.12);
      canvas.translate(0, math.sin(s.dancePhase * 2) * 8);
    }

    final mood = _characterMood(s);
    final headX = facePress;
    final headY = -95.0;

    // پاها
    final footL = Offset(-14 + s.footTap, 0);
    final footR = Offset(14 - s.footTap, 0);
    _drawLimb(canvas, Offset(0, -42), footL, 4);
    _drawLimb(canvas, Offset(0, -42), footR, 4);

    // بدن
    canvas.drawLine(
      const Offset(0, -42),
      Offset(headX * 0.3, headY + 22),
      Paint()
        ..color = AppColors.cream
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // بازوها
    if (s.isDrumming) {
      final drumY = math.sin(s.dancePhase * 3) * 12;
      _drawLimb(canvas, Offset(0, -70), Offset(35, -50 + drumY), 4);
      _drawLimb(canvas, Offset(0, -70), Offset(-20, -45 - drumY), 4);
    } else if (s.isFullDance) {
      _drawLimb(canvas, Offset(0, -70), Offset(40 * math.cos(s.dancePhase), -80), 4);
      _drawLimb(canvas, Offset(0, -70), Offset(-40 * math.sin(s.dancePhase), -75), 4);
    } else if (s.leanMachine) {
      _drawLimb(canvas, Offset(0, -70), Offset(45, -55), 4);
    } else if (s.isCelebrating) {
      _drawLimb(canvas, Offset(0, -75), const Offset(-38, -100), 4);
      _drawLimb(canvas, Offset(0, -75), const Offset(38, -100), 4);
    } else {
      _drawLimb(canvas, Offset(0, -70), const Offset(25, -55), 4);
      _drawLimb(canvas, Offset(0, -70), const Offset(-25, -50), 4);
    }

    // سر
    canvas.drawCircle(
      Offset(headX, headY),
      22,
      Paint()..color = const Color(0xFFE8B89A),
    );

  if (s.lookWatch) {
      // دست ساعت
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(32, -68), width: 16, height: 10),
          const Radius.circular(3),
        ),
        Paint()..color = AppColors.cream.withValues(alpha: 0.8),
      );
    }

    _drawFace(canvas, Offset(headX, headY), mood);

    canvas.restore();

    // سایه
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(baseX + lean * 20, baseY + 4),
        width: 60,
        height: 10,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.3),
    );
  }

  _Mood _characterMood(_Scenario s) {
    if (s.isCelebrating) return _Mood.happy;
    if (s.isDancing) return _Mood.silly;
    if (s.faceOnGlass) return _Mood.pleading;
    if (s.leanMachine) return _Mood.tired;
    if (s.isPhase2) return _Mood.impatient;
    return _Mood.excited;
  }

  void _drawFace(Canvas canvas, Offset c, _Mood mood) {
    // چشم‌ها
    final eyeY = c.dy - 4;
    if (mood == _Mood.pleading) {
      canvas.drawCircle(Offset(c.dx - 8, eyeY), 5, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(c.dx + 8, eyeY), 5, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(c.dx - 8, eyeY + 2), 2.5, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(c.dx + 8, eyeY + 2), 2.5, Paint()..color = Colors.black);
    } else {
      for (final dx in [-8.0, 8.0]) {
        canvas.drawArc(
          Rect.fromCenter(center: Offset(c.dx + dx, eyeY), width: 10, height: 6),
          0,
          math.pi,
          false,
          Paint()
            ..color = Colors.black87
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    // دهان
    final mouth = Path();
    switch (mood) {
      case _Mood.happy:
      case _Mood.excited:
        mouth.addArc(
          Rect.fromCenter(center: Offset(c.dx, c.dy + 8), width: 20, height: 14),
          0,
          math.pi,
        );
      case _Mood.silly:
        mouth.addOval(Rect.fromCenter(center: Offset(c.dx, c.dy + 10), width: 12, height: 10));
      case _Mood.impatient:
      case _Mood.tired:
        mouth.moveTo(c.dx - 8, c.dy + 10);
        mouth.lineTo(c.dx + 8, c.dy + 10);
      case _Mood.pleading:
        mouth.addOval(Rect.fromCenter(center: Offset(c.dx, c.dy + 12), width: 8, height: 10));
    }
    canvas.drawPath(
      mouth,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawLimb(Canvas canvas, Offset from, Offset to, double width) {
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = AppColors.cream
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawBeepWaves(Canvas canvas, Offset c, double progress) {
    for (var i = 0; i < 3; i++) {
      final r = 12 + i * 10 + progress * 15;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.3 * (1 - i * 0.3))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawMusicNotes(Canvas canvas, Size size, _Scenario s) {
    for (var i = 0; i < 4; i++) {
      final x = size.width * 0.35 + i * 22 + math.sin(s.dancePhase + i) * 8;
      final y = size.height * 0.35 - i * 15 - math.cos(s.dancePhase) * 10;
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()..color = AppColors.accent.withValues(alpha: 0.7),
      );
      canvas.drawLine(
        Offset(x + 4, y - 4),
        Offset(x + 4, y - 18),
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.7)
          ..strokeWidth = 2,
      );
    }
  }

  void _drawThud(Canvas canvas, Size size, _Scenario s) {
    final l = _layout(size, s);
    final opacity = s.thudOpacity;
    final tp = TextPainter(
      text: TextSpan(
        text: 'تِـق!',
        style: TextStyle(
          color: AppColors.cream.withValues(alpha: opacity),
          fontSize: 42 + (1 - opacity) * 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(
      canvas,
      Offset(l.cupPos.dx - tp.width / 2, l.slotY - 50),
    );
  }

  void _drawCelebration(Canvas canvas, Size size, _Scenario s) {
    for (var i = 0; i < 10; i++) {
      final angle = i * math.pi / 5 + s.t * math.pi;
      final r = 50 + math.sin(s.t * 20 + i) * 15;
      final c = Offset(size.width * 0.5, size.height * 0.45);
      canvas.drawCircle(
        Offset(c.dx + math.cos(angle) * r, c.dy + math.sin(angle) * r * 0.5),
        3,
        Paint()..color = AppColors.accent.withValues(alpha: 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SweetWaitPainter old) =>
      old.t != t || old.wiggle != wiggle;
}

class _Layout {
  _Layout({
    required this.machine,
    required this.cupPos,
    required this.slotY,
    required this.springTop,
    required this.springBottom,
  });

  final Rect machine;
  final Offset cupPos;
  final double slotY;
  final double springTop;
  final double springBottom;
}

enum _Mood { excited, impatient, tired, pleading, silly, happy }

/// متن سناریو بر اساس زمان
String sweetWaitCaption(double t) {
  if (t < 0.06) return 'پرداخت موفق!';
  if (t < 0.12) return 'دستگاه روشن شد…';
  if (t < 0.22) return 'بی‌صبرانه منتظر قهوه‌ات';
  if (t < 0.35) return 'فنر آروم آروم می‌چرخه…';
  if (t < 0.45) return 'چرا نمی‌افته؟!';
  if (t < 0.55) return 'گیر کرده!';
  if (t < 0.65) return 'بی‌حوصلگی حداکثر…';
  if (t < 0.72) return 'التماس به قهوه…';
  if (t < 0.78) return 'بیا خودمون درستش کنیم!';
  if (t < 0.86) return 'رقص و ضربه!';
  if (t < 0.92) return 'تِـق! افتاد!';
  return 'نوش جان! ☕';
}
