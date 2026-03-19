import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'themes/theme_data.dart';
import 'styles.dart';

class WaveBackground extends StatefulWidget {
  final bool isDarkMode;
  final double distressLevel;
  final ThemeType currentTheme;
  final bool isHighPerformance;
  final bool isResistanceActive;
  final bool isPostCrisisLog; 

  const WaveBackground({
    super.key,
    required this.isDarkMode,
    this.distressLevel = 0.0,
    required this.currentTheme,
    this.isHighPerformance = true,
    this.isResistanceActive = false,
    this.isPostCrisisLog = false, 
  });

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _phase = 0.0;
  final List<OceanParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    _initParticles();
  }

  void _tick(Duration elapsed) {
    setState(() {
      double speedMult = widget.isResistanceActive
          ? 0.005
          : (0.008 + widget.distressLevel * 0.022);
      if (widget.isPostCrisisLog) {
        speedMult = 0.002; 
      }
      _phase += speedMult;
      _updateParticles();
    });
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < 50; i++) {
      _particles.add(OceanParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.0005 + _random.nextDouble() * 0.001,
        radius: 1.5 + _random.nextDouble() * 3.5,
        opacity: 0.3 + _random.nextDouble() * 0.7,
      ));
    }
  }

  void _updateParticles() {
    double speedMult =
        widget.isResistanceActive ? 0.2 : (0.5 + widget.distressLevel * 4.5);
    if (widget.isPostCrisisLog) speedMult = 0.1; 

    for (var p in _particles) {
      p.y -= p.speed * speedMult;
      p.x += sin(_phase * 2 + p.y * 10) * 0.001;

      if (p.y < -0.1) {
        p.y = 1.1;
        p.x = _random.nextDouble();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color themeAccent = getThemeData(widget.currentTheme).accentColor;

    Color topColor =
        widget.isDarkMode ? AppStyles.deepSpaceTop : AppStyles.lightTop;
    Color bottomColor =
        widget.isDarkMode ? AppStyles.deepSpaceBottom : AppStyles.lightBottom;

    if (widget.isPostCrisisLog) {
      topColor = widget.isDarkMode
          ? const Color(0xFF475569)
          : const Color(0xFFCBD5E1); 
      bottomColor = widget.isDarkMode
          ? const Color(0xFF334155)
          : const Color(0xFFE2E8F0); 
      themeAccent = const Color(0xFF94A3B8); 
    } else {
      topColor = Color.lerp(topColor, themeAccent, 0.05)!;
      bottomColor = Color.lerp(bottomColor, themeAccent, 0.1)!;

      if (widget.distressLevel > 0.5 && !widget.isResistanceActive) {
        bottomColor = Color.lerp(
            bottomColor, Colors.black, (widget.distressLevel - 0.5))!;
      }

      if (widget.isResistanceActive) {
        topColor = Color.lerp(topColor, AppStyles.resistanceWarmth, 0.4)!;
        bottomColor = Color.lerp(bottomColor, AppStyles.resistanceWarmth, 0.6)!;
      }
    }

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [topColor, bottomColor],
            ),
          ),
        ),
        CustomPaint(
          painter: OceanWavePainter(
            phase: _phase,
            isDarkMode: widget.isDarkMode,
            distressLevel: widget.distressLevel,
            accentColor: widget.isResistanceActive
                ? AppStyles.resistanceWarmth
                : themeAccent,
            isResistanceActive: widget.isResistanceActive,
            isPostCrisisLog: widget.isPostCrisisLog, 
          ),
          size: Size.infinite,
        ),
        CustomPaint(
          painter: BubblePainter(
            particles: _particles,
            isDarkMode: widget.isDarkMode,
            accentColor: widget.isResistanceActive
                ? AppStyles.resistanceWarmth
                : themeAccent,
          ),
          size: Size.infinite,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}

class OceanParticle {
  double x, y, speed, radius, opacity;
  OceanParticle(
      {required this.x,
      required this.y,
      required this.speed,
      required this.radius,
      required this.opacity});
}

class BubblePainter extends CustomPainter {
  final List<OceanParticle> particles;
  final bool isDarkMode;
  final Color accentColor;

  BubblePainter({
    required this.particles,
    required this.isDarkMode,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Color baseColor = isDarkMode ? const Color(0xFFB0BEC5) : const Color(0xFF64748B);
    baseColor = Color.lerp(baseColor, accentColor, 0.5)!;

    for (var p in particles) {
      final center = Offset(p.x * size.width, p.y * size.height);
      
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            baseColor.withValues(alpha: p.opacity),
            baseColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: p.radius * 1.5)); 

      canvas.drawCircle(center, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class OceanWavePainter extends CustomPainter {
  final double phase;
  final bool isDarkMode;
  final double distressLevel;
  final Color accentColor;
  final bool isResistanceActive;
  final bool isPostCrisisLog;

  OceanWavePainter({
    required this.phase,
    required this.isDarkMode,
    required this.distressLevel,
    required this.accentColor,
    required this.isResistanceActive,
    this.isPostCrisisLog = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // FIXED: Adjusted baseAmp calculations to safely accommodate the new aggregated metric
    double baseAmp = isResistanceActive ? 25.0 : 35.0 + (distressLevel * 85.0); 
    if (isPostCrisisLog) baseAmp = 15.0; 

    _drawWaveLayer(canvas, size,
        speed: 1.0,
        offset: 0,
        opacity: 0.1,
        heightFactor: 0.4,
        amp: baseAmp * 1.5);
    _drawWaveLayer(canvas, size,
        speed: 1.5,
        offset: pi,
        opacity: 0.15,
        heightFactor: 0.5,
        amp: baseAmp * 1.2);
    _drawWaveLayer(canvas, size,
        speed: 0.8,
        offset: pi / 2,
        opacity: 0.25,
        heightFactor: 0.6,
        amp: baseAmp);
    _drawWaveLayer(canvas, size,
        speed: 2.0,
        offset: 0,
        opacity: 0.4,
        heightFactor: 0.7,
        amp: baseAmp * 0.8,
        isFront: true);
  }

  void _drawWaveLayer(
    Canvas canvas,
    Size size, {
    required double speed,
    required double offset,
    required double opacity,
    required double heightFactor,
    required double amp,
    bool isFront = false,
  }) {
    final path = Path();
    double yBase = size.height * heightFactor;
    path.moveTo(0, yBase);

    for (double x = 0; x <= size.width; x += 5) {
      double y =
          sin((x / size.width * 2 * pi) + (phase * speed) + offset) * amp;
      y += sin((x / size.width * 5 * pi) - (phase * 2 * speed)) * (amp * 0.3);
      path.lineTo(x, yBase + y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    Color base = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);
    Color waveColor = isFront
        ? (isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9)) 
        : base;

    waveColor = Color.lerp(waveColor, accentColor, 0.20)!;

    if (distressLevel > 0.5 && !isResistanceActive && !isPostCrisisLog) {
      waveColor = Color.lerp(
          waveColor, const Color(0xFFE57373), (distressLevel - 0.5) * 0.5)!; 
    }

    canvas.drawShadow(path, Colors.black.withValues(alpha: opacity * 0.8), isFront ? 15.0 : 8.0, true);

    final Rect bounds = path.getBounds();
    final Gradient waveGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(waveColor, Colors.white, isDarkMode ? 0.1 : 0.4)!.withValues(alpha: opacity),
        waveColor.withValues(alpha: opacity),
        Color.lerp(waveColor, Colors.black, isDarkMode ? 0.3 : 0.1)!.withValues(alpha: opacity),
      ],
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = waveGradient.createShader(bounds);

    canvas.drawPath(path, paint);

    if (isFront) {
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: isDarkMode ? 0.15 : 0.5);
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}