import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(InclinometerApp());
}

class InclinometerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InclinometerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InclinometerScreen extends StatefulWidget {
  @override
  _InclinometerScreenState createState() => _InclinometerScreenState();
}

class _InclinometerScreenState extends State<InclinometerScreen> {
  double pitch = 0;
  double roll = 0;

  @override
  void initState() {
    super.initState();

    // Fetch pitch and roll data from the accelerometer
    accelerometerEventStream().listen((AccelerometerEvent event) {
      setState(() {
        pitch = atan2(event.y, sqrt(event.x * event.x + event.z * event.z)) * (180 / pi);
        roll = atan2(-event.x, event.z) * (180 / pi);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular Dial
            CustomPaint(
              size: Size(300, 300),
              painter: DialPainter(pitch: pitch, roll: roll),
            ),
            // Vehicle Icon (Center)
            Positioned(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, color: Colors.white, size: 40),
                  Text(
                    'Pitch: ${pitch.toStringAsFixed(1)}°',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    'Roll: ${roll.toStringAsFixed(1)}°',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DialPainter extends CustomPainter {
  final double pitch;
  final double roll;

  DialPainter({required this.pitch, required this.roll});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw outer circle
    canvas.drawCircle(center, radius, paint);

    // Draw pitch angle indicator (left and right arcs)
    drawPitchIndicator(canvas, center, radius, pitch);

    // Draw roll angle indicator (top and bottom arcs)
    drawRollIndicator(canvas, center, radius, roll);

    // Draw markers
    drawMarkers(canvas, center, radius);
  }

  void drawPitchIndicator(Canvas canvas, Offset center, double radius, double pitch) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    // Convert pitch to an angle
    double pitchAngle = (pitch * pi) / 180;

    // Draw the arc
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi / 2, -pitchAngle, false, paint);
  }

  void drawRollIndicator(Canvas canvas, Offset center, double radius, double roll) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    // Convert roll to an angle
    double rollAngle = (roll * pi) / 180;

    // Draw the arc
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, -rollAngle, false, paint);
  }

  void drawMarkers(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw markers at intervals of 10 degrees
    for (double i = 0; i < 360; i += 10) {
      double x1 = center.dx + radius * cos(i * pi / 180);
      double y1 = center.dy + radius * sin(i * pi / 180);
      double x2 = center.dx + (radius - 10) * cos(i * pi / 180);
      double y2 = center.dy + (radius - 10) * sin(i * pi / 180);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw degrees
    final textStyle = TextStyle(color: Colors.white, fontSize: 12);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (double i = -40; i <= 40; i += 10) {
      double angle = i * pi / 180;
      double x = center.dx + (radius + 15) * cos(angle);
      double y = center.dy + (radius + 15) * sin(angle);

      textPainter.text = TextSpan(text: '${i.abs().toStringAsFixed(0)}', style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 10, y - 10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
