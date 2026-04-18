import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message.dart';
import '../constants.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isSpeaking;
  final VoidCallback onSpeak;
  final VoidCallback onStop;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSpeaking,
    required this.onSpeak,
    required this.onStop,
  });

  bool get isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: isUser
            ? [_bubble(), const SizedBox(width: 10), _avatar()]
            : [_avatar(), const SizedBox(width: 10), _bubble()],
      ),
    );
  }

  Widget _avatar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 40, height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUser
            ? null
            : const RadialGradient(colors: [Color(0xFF1A5030), Color(0xFF0A2015)]),
        color: isUser ? Colors.purple.withOpacity(0.25) : null,
        border: Border.all(
          color: isUser
              ? Colors.purple.withOpacity(0.35)
              : isSpeaking
                  ? AppConstants.gold.withOpacity(0.9)
                  : AppConstants.gold.withOpacity(0.45),
          width: isSpeaking && !isUser ? 2.5 : 2,
        ),
        boxShadow: !isUser ? [
          BoxShadow(
            color: isSpeaking
                ? AppConstants.gold.withOpacity(0.7)
                : AppConstants.orange.withOpacity(0.2),
            blurRadius: isSpeaking ? 28 : 18,
            spreadRadius: isSpeaking ? 4 : 0,
          ),
        ] : null,
      ),
      child: Center(child: Text(isUser ? '🙏' : '🦚', style: const TextStyle(fontSize: 18))),
    );
  }

  Widget _bubble() {
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.purple.withOpacity(0.12)
              : AppConstants.gold.withOpacity(0.045),
          borderRadius: BorderRadius.only(
            topLeft:     Radius.circular(isUser ? 18 : 5),
            topRight:    Radius.circular(isUser ? 5 : 18),
            bottomLeft:  const Radius.circular(18),
            bottomRight: const Radius.circular(18),
          ),
          border: Border.all(
            color: isUser
                ? Colors.purple.withOpacity(0.18)
                : isSpeaking
                    ? AppConstants.gold.withOpacity(0.3)
                    : AppConstants.gold.withOpacity(0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) _uvachaLabel(),
            if (message.sections != null && !isUser)
              _sections()
            else
              _plainText(),
            if (!isUser) _voiceControls(),
          ],
        ),
      ),
    );
  }

  Widget _uvachaLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Text('ॐ', style: TextStyle(
          fontSize: 15, color: AppConstants.gold.withOpacity(0.6),
          shadows: [Shadow(color: AppConstants.orange.withOpacity(0.5), blurRadius: 8)],
        )),
        const SizedBox(width: 6),
        Text('श्री कृष्ण उवाच',
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 10, color: AppConstants.gold.withOpacity(0.52), letterSpacing: 1.5,
          )),
      ]),
    );
  }

  Widget _sections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: message.sections!.map((s) {
        final isShloka = s.key == 'shloka';
        final isSutra  = s.key == 'sutra';
        final isSandesh= s.key == 'sandesh';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: (isShloka || isSutra)
                ? const EdgeInsets.fromLTRB(12, 7, 8, 7)
                : isSandesh
                    ? const EdgeInsets.all(10)
                    : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: isSandesh ? AppConstants.gold.withOpacity(0.04) : null,
              borderRadius: isSandesh ? BorderRadius.circular(12) : null,
              border: (isShloka || isSutra)
                  ? Border(left: BorderSide(
                      color: AppConstants.orange.withOpacity(0.45), width: 2.5))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${s.icon}  ${s.label}',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 11, color: const Color(0xFFFFC85A).withOpacity(0.65),
                  )),
                const SizedBox(height: 5),
                Text(s.content,
                  style: GoogleFonts.notoSerifDevanagari(
                    fontSize: isShloka ? 13 : 14,
                    fontStyle: isShloka ? FontStyle.italic : FontStyle.normal,
                    color: isSutra
                        ? AppConstants.gold
                        : isShloka
                            ? const Color(0xFFFFEBA8).withOpacity(0.9)
                            : AppConstants.textMain.withOpacity(0.88),
                    height: 1.9,
                    shadows: isSutra ? [Shadow(
                      color: AppConstants.gold.withOpacity(0.3), blurRadius: 12,
                    )] : null,
                  )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _plainText() {
    return Text(message.content,
      style: GoogleFonts.notoSerifDevanagari(
        fontSize: 14,
        color: isUser
            ? const Color(0xFFD5C5F5)
            : AppConstants.textMain.withOpacity(0.88),
        height: 1.9,
      ));
  }

  Widget _voiceControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(children: [
        // Waveform
        _Waveform(active: isSpeaking),
        const SizedBox(width: 10),
        // Button
        GestureDetector(
          onTap: isSpeaking ? onStop : onSpeak,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isSpeaking
                  ? Colors.red.withOpacity(0.15)
                  : AppConstants.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSpeaking
                    ? Colors.red.withOpacity(0.38)
                    : AppConstants.gold.withOpacity(0.32),
              ),
            ),
            child: Text(isSpeaking ? '⏹  रोकें' : '🔊  दिव्य वाणी सुनें',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 12,
                color: isSpeaking ? const Color(0xFFFF9999) : AppConstants.gold,
              )),
          ),
        ),
        if (isSpeaking) ...[
          const SizedBox(width: 8),
          Text('बोल रहे हैं...',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 11, fontStyle: FontStyle.italic,
              color: AppConstants.gold.withOpacity(0.45),
            )),
        ],
      ]),
    );
  }
}

// ── Animated Waveform ──────────────────────────────────────────────────────────
class _Waveform extends StatefulWidget {
  final bool active;
  const _Waveform({required this.active});

  @override
  State<_Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<_Waveform> with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(20, (i) => AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 320 + (i % 7) * 90),
    )..repeat(reverse: true));
    _anims = _ctrls.asMap().entries.map((e) =>
      Tween<double>(begin: 4, end: 22).animate(
        CurvedAnimation(parent: e.value, curve: Curves.easeInOut)
      )..addListener(() {})
    ).toList();
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(20, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.2),
            child: AnimatedBuilder(
              animation: _ctrls[i],
              builder: (_, __) => Container(
                width: 3,
                height: widget.active ? _anims[i].value : 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: widget.active
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFD700), Color(0xFFFF6B00)],
                        )
                      : null,
                  color: widget.active ? null : AppConstants.gold.withOpacity(0.18),
                  boxShadow: widget.active ? [BoxShadow(
                    color: AppConstants.orange.withOpacity(0.45), blurRadius: 5,
                  )] : null,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
