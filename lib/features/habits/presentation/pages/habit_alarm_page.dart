import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/habit_alarm_platform_service.dart';
import '../../../../core/services/notification_service.dart';

class HabitAlarmPage extends StatefulWidget {
  final int notificationId;
  final String title;
  final String description;
  final String payload;

  const HabitAlarmPage({
    required this.notificationId,
    required this.title,
    required this.description,
    required this.payload,
    super.key,
  });

  @override
  State<HabitAlarmPage> createState() => _HabitAlarmPageState();
}

class _HabitAlarmPageState extends State<HabitAlarmPage>
    with SingleTickerProviderStateMixin {
  static const _backgroundTop = Color(0xFF754044);
  static const _backgroundMiddle = Color(0xFF482B34);
  static const _backgroundBottom = Color(0xFF191922);
  static const _accent = Color(0xFFFFB18D);

  late DateTime _now;
  late final Timer _clockTimer;
  late final AnimationController _pulseController;
  double _dragDistance = 0;
  bool _isStopping = false;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _snooze() async {
    final body = widget.description.isEmpty
        ? 'It is time to work on your habit.'
        : widget.description;
    if (defaultTargetPlatform == TargetPlatform.android) {
      await HabitAlarmPlatformService.snoozeHabitAlarm(
        alarmId: widget.notificationId,
        title: widget.title,
        body: body,
        payload: widget.payload,
      );
      await HabitAlarmPlatformService.stopAlarmSound();
    } else {
      await NotificationService.instance.snoozeAlarm(
        notificationId: widget.notificationId,
        title: widget.title,
        body: body,
        payload: widget.payload,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _stop() async {
    if (_isStopping) return;
    setState(() => _isStopping = true);
    await NotificationService.instance.cancelNotification(
      widget.notificationId,
    );
    if (defaultTargetPlatform == TargetPlatform.android) {
      await HabitAlarmPlatformService.stopAlarmSound();
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDistance = (_dragDistance - details.delta.dy).clamp(0, 120);
    });
    if (_dragDistance >= 88) {
      _stop();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragDistance < 88) {
      setState(() => _dragDistance = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(_now);
    final date = DateFormat('EEEE, d MMMM').format(_now);

    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: _backgroundBottom,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _backgroundTop,
                      _backgroundMiddle,
                      _backgroundBottom,
                    ],
                    stops: [0, 0.48, 1],
                  ),
                ),
              ),
              CustomPaint(painter: _AlarmBackdropPainter()),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 700;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        compact ? 16 : 26,
                        24,
                        compact ? 14 : 22,
                      ),
                      child: Column(
                        children: [
                          _buildTopBar(),
                          SizedBox(height: compact ? 24 : 38),
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.76),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.25,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            time,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.97),
                              fontSize: compact ? 68 : 82,
                              height: 1.18,
                              fontWeight: FontWeight.w200,
                              letterSpacing: -4,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          SizedBox(height: compact ? 22 : 36),
                          Expanded(
                            child: Center(
                              child: _buildHabitCard(compact: compact),
                            ),
                          ),
                          SizedBox(height: compact ? 16 : 26),
                          _buildStopControl(),
                          const SizedBox(height: 16),
                          _buildSnoozeButton(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.13),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: const Icon(Icons.alarm_rounded, color: _accent, size: 20),
        ),
        const SizedBox(width: 11),
        const Text(
          'WAKELOCK',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'HABIT ALARM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHabitCard({required bool compact}) {
    final horizontalPadding = compact ? 20.0 : 30.0;
    final verticalPadding = compact ? 12.0 : 32.0;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = 0.1 + _pulseController.value * 0.08;
        return Container(
          constraints: BoxConstraints(
            maxWidth: 340,
            maxHeight: compact ? 290 : 340,
          ),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF241C26).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: glow),
                blurRadius: 42,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 22),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(33),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: child,
            ),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: compact ? 38 : 52,
            height: compact ? 38 : 52,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.13),
              shape: BoxShape.circle,
              border: Border.all(color: _accent.withValues(alpha: 0.24)),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: _accent,
              size: compact ? 19 : 24,
            ),
          ),
          SizedBox(height: compact ? 7 : 18),
          Text(
            "It's time!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: compact ? 12 : 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: compact ? 4 : 8),
          Text(
            widget.title,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 21 : 30,
              height: 1.13,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          if (widget.description.isNotEmpty) ...[
            SizedBox(height: compact ? 6 : 12),
            Text(
              widget.description,
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.67),
                fontSize: compact ? 11 : 14,
                height: 1.35,
              ),
            ),
          ],
          if (!compact) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'A small step, a stronger you',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStopControl() {
    final progress = (_dragDistance / 88).clamp(0.0, 1.0);
    return GestureDetector(
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      onTap: _stop,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.19),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (progress > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  heightFactor: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.17),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  transform: Matrix4.translationValues(
                    0,
                    -_dragDistance * 0.38,
                    0,
                  ),
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isStopping ? Icons.check_rounded : Icons.stop_rounded,
                    color: const Color(0xFF301D25),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SWIPE UP TO STOP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Turn off this alarm',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_double_arrow_up_rounded,
                  color: Colors.white70,
                  size: 25,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnoozeButton() {
    return SizedBox(
      height: 48,
      child: TextButton.icon(
        onPressed: _snooze,
        icon: const Icon(Icons.snooze_rounded, size: 18),
        label: const Text('Snooze 5 minutes'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white.withValues(alpha: 0.9),
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: const StadiumBorder(),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _AlarmBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.77);
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFFFA18A).withValues(alpha: 0.16),
              const Color(0xFFB05B62).withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.width * 0.75),
          );
    canvas.drawCircle(center, size.width * 0.75, glowPaint);

    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var index = 0; index < 5; index++) {
      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.86),
        size.width * (0.25 + index * 0.095),
        ringPaint,
      );
    }

    final path = Path()
      ..moveTo(0, size.height * 0.84)
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.76,
        size.width * 0.68,
        size.height * 0.96,
        size.width,
        size.height * 0.79,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.035)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
