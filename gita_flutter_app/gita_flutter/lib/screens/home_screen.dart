import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/om_bell_service.dart';
import '../widgets/welcome_screen.dart';
import '../widgets/message_bubble.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<Message> _messages = [];
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading  = false;
  bool _autoSpeak  = true;
  bool _started    = false;
  String? _speakingId;
  int _msgCounter  = 0;

  // Animations
  late AnimationController _headerFloatCtrl;
  late AnimationController _headerPulseCtrl;
  late AnimationController _shimmerCtrl;
  late Animation<double> _headerFloatAnim;
  late Animation<double> _headerPulseAnim;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _headerFloatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
    _headerPulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    _headerFloatAnim = Tween<double>(begin: 0, end: -8).animate(CurvedAnimation(parent: _headerFloatCtrl, curve: Curves.easeInOut));
    _headerPulseAnim = Tween<double>(begin: 0.2, end: 0.6).animate(CurvedAnimation(parent: _headerPulseCtrl, curve: Curves.easeInOut));
    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _headerFloatCtrl.dispose();
    _headerPulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    AudioService.dispose();
    OmBellService.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? question]) async {
    final text = question ?? _inputCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;

    _stopSpeaking();
    _inputCtrl.clear();
    setState(() {
      _isLoading = true;
      _started = true;
      _messages.add(Message(
        id: '${++_msgCounter}',
        role: 'user',
        content: text,
        time: DateTime.now(),
      ));
    });
    _scrollToBottom();

    try {
      final reply = await ApiService.askKrishna(_messages);
      final sections = parseGitaResponse(reply);
      final aMsg = Message(
        id: '${++_msgCounter}',
        role: 'assistant',
        content: reply,
        time: DateTime.now(),
        sections: sections,
      );
      setState(() {
        _messages.add(aMsg);
        _isLoading = false;
      });
      _scrollToBottom();
      if (_autoSpeak) {
        await Future.delayed(const Duration(milliseconds: 300));
        await _speakMessage(aMsg);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(Message(
          id: '${++_msgCounter}',
          role: 'assistant',
          content: 'क्षमा करें, अभी जुड़ नहीं पा रहा। कृपया पुनः प्रयास करें।',
          time: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  Future<void> _speakMessage(Message msg) async {
    _stopSpeaking();
    setState(() => _speakingId = msg.id);

    try {
      await OmBellService.playOmBell();
      await Future.delayed(const Duration(milliseconds: 200));

      final audioBytes = await ApiService.getVoice(msg.content);
      if (audioBytes != null) {
        await AudioService.playAudioBytes(audioBytes);
      } else {
        final cleanText = cleanForSpeech(msg.content);
        await AudioService.speakTTS(cleanText);
      }
    } catch (e) {
      try {
        await AudioService.speakTTS(cleanForSpeech(msg.content));
      } catch (_) {}
    } finally {
      if (mounted) setState(() => _speakingId = null);
    }
  }

  void _stopSpeaking() {
    AudioService.stop();
    if (mounted) setState(() => _speakingId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          _buildBackground(),
          // Stars
          const _StarField(),
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _started ? _buildChat() : _buildWelcome(),
                ),
                _buildInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF03030F), Color(0xFF070720),
            Color(0xFF110816), Color(0xFF070720), Color(0xFF03030F),
          ],
          stops: [0, 0.3, 0.55, 0.8, 1],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isSpeaking = _speakingId != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF03030F).withOpacity(0.85),
        border: Border(bottom: BorderSide(color: AppConstants.gold.withOpacity(0.1))),
      ),
      child: Row(children: [
        // Krishna avatar
        AnimatedBuilder(
          animation: isSpeaking ? _headerPulseAnim : _headerFloatAnim,
          builder: (_, __) => Transform.translate(
            offset: isSpeaking ? Offset.zero : Offset(0, _headerFloatAnim.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(colors: [Color(0xFF1A5030), Color(0xFF0A2015)]),
                border: Border.all(
                  color: AppConstants.gold.withOpacity(isSpeaking ? 0.9 : 0.45),
                  width: 2,
                ),
                boxShadow: [BoxShadow(
                  color: AppConstants.orange.withOpacity(isSpeaking ? _headerPulseAnim.value : 0.2),
                  blurRadius: isSpeaking ? 28 : 16,
                  spreadRadius: isSpeaking ? 4 : 0,
                )],
              ),
              child: const Center(child: Text('🦚', style: TextStyle(fontSize: 22))),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: _shimmerAnim,
                builder: (_, __) => ShaderMask(
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment(_shimmerAnim.value - 1, 0),
                    end: Alignment(_shimmerAnim.value + 1, 0),
                    colors: const [Color(0xFFFFD700), Color(0xFFFF8C00), Color(0xFFFFE066), Color(0xFFFF8C00), Color(0xFFFFD700)],
                  ).createShader(rect),
                  child: Text('श्री कृष्ण गीता संवाद',
                    style: GoogleFonts.notoSerifDevanagari(
                      fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white,
                    )),
                ),
              ),
              Text('भगवद् गीता AI • हर प्रश्न का उत्तर',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 11, color: AppConstants.textSub.withOpacity(0.45),
                )),
            ],
          ),
        ),
        // Auto speak toggle
        GestureDetector(
          onTap: () { if (_autoSpeak) _stopSpeaking(); setState(() => _autoSpeak = !_autoSpeak); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _autoSpeak ? AppConstants.gold.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _autoSpeak ? AppConstants.gold.withOpacity(0.45) : Colors.white24,
              ),
            ),
            child: Text(_autoSpeak ? '🔊' : '🔇',
              style: GoogleFonts.notoSansDevanagari(fontSize: 14)),
          ),
        ),
      ]),
    );
  }

  Widget _buildWelcome() {
    return WelcomeScreen(onQuestion: _sendMessage);
  }

  Widget _buildChat() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(14),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == _messages.length) return _buildLoadingBubble();
        final msg = _messages[i];
        return MessageBubble(
          message: msg,
          isSpeaking: _speakingId == msg.id,
          onSpeak: () => _speakMessage(msg),
          onStop: _stopSpeaking,
        );
      },
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(colors: [Color(0xFF1A5030), Color(0xFF0A2015)]),
              border: Border.all(color: AppConstants.gold.withOpacity(0.45), width: 2),
              boxShadow: [BoxShadow(color: AppConstants.orange.withOpacity(0.22), blurRadius: 18)],
            ),
            child: const Center(child: Text('🦚', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppConstants.gold.withOpacity(0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: AppConstants.gold.withOpacity(0.11)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('ॐ', style: TextStyle(fontSize: 14, color: AppConstants.gold.withOpacity(0.5))),
                  const SizedBox(width: 6),
                  Text('श्री कृष्ण उवाच',
                    style: GoogleFonts.notoSansDevanagari(fontSize: 10, color: AppConstants.gold.withOpacity(0.5))),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  ...List.generate(4, (i) => _DotPulse(delay: Duration(milliseconds: i * 170))),
                  const SizedBox(width: 8),
                  Text('ज्ञान प्राप्त हो रहा है...',
                    style: GoogleFonts.notoSansDevanagari(fontSize: 12, color: AppConstants.textSub.withOpacity(0.5))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF03030F).withOpacity(0.92),
        border: Border(top: BorderSide(color: AppConstants.gold.withOpacity(0.09))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick chips (when chatting)
          if (_started) _buildQuickChips(),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 110),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppConstants.gold.withOpacity(0.24), width: 1.5),
                  ),
                  child: TextField(
                    controller: _inputCtrl,
                    focusNode: _focusNode,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: GoogleFonts.notoSansDevanagari(fontSize: 14, color: AppConstants.textMain),
                    decoration: InputDecoration(
                      hintText: 'अपना प्रश्न या कष्ट यहाँ लिखें...',
                      hintStyle: GoogleFonts.notoSansDevanagari(
                        fontSize: 13, color: AppConstants.textMain.withOpacity(0.28),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              GestureDetector(
                onTap: _isLoading ? null : _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isLoading ? null : const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                    ),
                    color: _isLoading ? Colors.white12 : null,
                    boxShadow: _isLoading ? null : [
                      BoxShadow(color: AppConstants.orange.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Center(
                    child: Text(_isLoading ? '⏳' : '🙏', style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text('✦  यतो धर्मस्ततो जयः  ✦',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 10, color: AppConstants.textSub.withOpacity(0.2),
            )),
        ],
      ),
    );
  }

  Widget _buildQuickChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: AppConstants.examples.take(3).map((q) => Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () => _sendMessage(q),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: AppConstants.gold.withOpacity(0.07),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppConstants.gold.withOpacity(0.2)),
              ),
              child: Text(q, style: GoogleFonts.notoSansDevanagari(
                fontSize: 11, color: const Color(0xFFF5D98B),
              )),
            ),
          ),
        )).toList(),
      ),
    );
  }
}

// ── Animated Dot ──────────────────────────────────────────────────────────────
class _DotPulse extends StatefulWidget {
  final Duration delay;
  const _DotPulse({required this.delay});

  @override
  State<_DotPulse> createState() => _DotPulseState();
}
class _DotPulseState extends State<_DotPulse> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.35, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Transform.scale(
          scale: 0.9 + 0.3 * _anim.value,
          child: Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppConstants.gold.withOpacity(_anim.value), AppConstants.orange.withOpacity(_anim.value)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Star Field ────────────────────────────────────────────────────────────────
class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    final rand = math.Random(42);
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _StarPainter(rand),
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final math.Random rand;
  _StarPainter(this.rand);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.6);
    for (int i = 0; i < 55; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final r = rand.nextDouble() > 0.8 ? 1.5 : rand.nextDouble() > 0.5 ? 1.0 : 0.75;
      paint.color = Colors.white.withOpacity(0.2 + rand.nextDouble() * 0.5);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
