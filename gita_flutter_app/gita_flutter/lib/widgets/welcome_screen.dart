import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class WelcomeScreen extends StatefulWidget {
  final Function(String) onQuestion;
  const WelcomeScreen({super.key, required this.onQuestion});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _spinCtrl;
  late AnimationController _spinRCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _glowCtrl;

  late Animation<double> _floatAnim;
  late Animation<double> _spinAnim;
  late Animation<double> _spinRAnim;
  late Animation<double> _shimmerAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _spinCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat();
    _spinRCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _glowCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);

    _floatAnim   = Tween<double>(begin: 0, end: -18).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _spinAnim    = Tween<double>(begin: 0, end: 2 * math.pi).animate(_spinCtrl);
    _spinRAnim   = Tween<double>(begin: 2 * math.pi, end: 0).animate(_spinRCtrl);
    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear));
    _glowAnim    = Tween<double>(begin: 0.18, end: 0.55).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose(); _spinCtrl.dispose(); _spinRCtrl.dispose();
    _shimmerCtrl.dispose(); _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          children: [
            // ── Krishna Orbit ─────────────────────────────────────────────
            _buildOrbit(),
            const SizedBox(height: 22),

            // ── Title ─────────────────────────────────────────────────────
            _buildTitle(),
            const SizedBox(height: 20),

            // ── Aaj Ka Shloka ─────────────────────────────────────────────
            _buildShlokaCard(),
            const SizedBox(height: 20),

            // ── Example Questions ─────────────────────────────────────────
            _buildExamples(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbit() {
    return SizedBox(
      width: 180, height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow background
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: AppConstants.gold.withOpacity(_glowAnim.value * 0.4),
                  blurRadius: 60, spreadRadius: 10,
                )],
              ),
            ),
          ),
          // Outer orbit ring
          AnimatedBuilder(
            animation: _spinAnim,
            builder: (_, __) => Transform.rotate(
              angle: _spinAnim.value,
              child: SizedBox(
                width: 172, height: 172,
                child: CustomPaint(painter: _OrbitPainter(4)),
              ),
            ),
          ),
          // Inner orbit ring
          AnimatedBuilder(
            animation: _spinRAnim,
            builder: (_, __) => Transform.rotate(
              angle: _spinRAnim.value,
              child: SizedBox(
                width: 132, height: 132,
                child: CustomPaint(painter: _OrbitDotPainter()),
              ),
            ),
          ),
          // Main Krishna avatar
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _floatAnim.value),
              child: Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.3, -0.3),
                    colors: [Color(0xFF1A5030), Color(0xFF0A2015)],
                  ),
                  border: Border.all(color: AppConstants.gold.withOpacity(0.55), width: 2.5),
                  boxShadow: [
                    BoxShadow(color: AppConstants.orange.withOpacity(0.3), blurRadius: 40),
                    BoxShadow(color: AppConstants.gold.withOpacity(0.15), blurRadius: 80),
                  ],
                ),
                child: const Center(
                  child: Text('🦚', style: TextStyle(fontSize: 52)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _shimmerAnim,
          builder: (_, __) => ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment(_shimmerAnim.value - 1, 0),
              end: Alignment(_shimmerAnim.value + 1, 0),
              colors: const [
                Color(0xFFFFD700), Color(0xFFFF8C00),
                Color(0xFFFFE066), Color(0xFFFF8C00), Color(0xFFFFD700),
              ],
            ).createShader(rect),
            child: Text(
              'भगवद् गीता',
              style: GoogleFonts.notoSerifDevanagari(
                fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'अपने मन की बात कहो —\nमैं केशव हूँ, गीता के ज्ञान से\nतुम्हारा मार्ग दिखाऊँगा 🙏',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 14, color: AppConstants.textSub.withOpacity(0.7), height: 1.85,
          ),
        ),
      ],
    );
  }

  Widget _buildShlokaCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppConstants.gold.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.gold.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text('✦  आज का श्लोक  ✦',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 11, color: AppConstants.gold.withOpacity(0.5), letterSpacing: 1.5,
            )),
          const SizedBox(height: 10),
          Text(
            '"कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥"',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifDevanagari(
              fontSize: 13, color: AppConstants.textMain.withOpacity(0.82),
              fontStyle: FontStyle.italic, height: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text('— भगवद् गीता, अध्याय २, श्लोक ४७',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 11, color: AppConstants.textSub.withOpacity(0.5),
            )),
        ],
      ),
    );
  }

  Widget _buildExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text('ये प्रश्न पूछें या अपना प्रश्न लिखें:',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 11, color: AppConstants.textMain.withOpacity(0.35),
            )),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          alignment: WrapAlignment.center,
          children: AppConstants.examples.map((q) => _ChipButton(
            text: q, onTap: () => widget.onQuestion(q),
          )).toList(),
        ),
      ],
    );
  }
}

// ── Orbit Painters ─────────────────────────────────────────────────────────────
class _OrbitPainter extends CustomPainter {
  final int dots;
  _OrbitPainter(this.dots);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2;
    final paint = Paint()
      ..color = AppConstants.gold.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(cx, cy), r, paint);
    final dotPaint = Paint()..color = AppConstants.gold.withOpacity(0.35);
    for (int i = 0; i < dots; i++) {
      final angle = (2 * math.pi / dots) * i;
      final dx = cx + r * math.cos(angle);
      final dy = cy + r * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _OrbitDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2;
    final paint = Paint()
      ..color = AppConstants.gold.withOpacity(0.14)
      ..style = PaintingStyle.stroke ..strokeWidth = 1;
    canvas.drawCircle(Offset(cx, cy), r, paint);
    final dotPaint = Paint()..color = AppConstants.gold
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(cx, cy - r), 4, dotPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ChipButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _ChipButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppConstants.gold.withOpacity(0.07),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppConstants.gold.withOpacity(0.22)),
        ),
        child: Text(text,
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 13, color: const Color(0xFFF5D98B),
          )),
      ),
    );
  }
}
