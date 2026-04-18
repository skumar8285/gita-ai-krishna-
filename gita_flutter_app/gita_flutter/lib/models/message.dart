class Message {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime time;
  final List<MessageSection>? sections;

  Message({
    required this.id,
    required this.role,
    required this.content,
    required this.time,
    this.sections,
  });
}

class MessageSection {
  final String key;
  final String icon;
  final String label;
  final String content;

  const MessageSection({
    required this.key,
    required this.icon,
    required this.label,
    required this.content,
  });
}

List<MessageSection>? parseGitaResponse(String text) {
  final patterns = [
    {'key': 'shloka',  'icon': '🔱', 'label': 'श्लोक',              'rx': RegExp(r'श्लोक:\s*([\s\S]*?)(?=अध्याय:|अर्थ:|संदेश:|सूत्र:|$)', caseSensitive: false)},
    {'key': 'adhyay',  'icon': '📖', 'label': 'अध्याय एवं श्लोक',   'rx': RegExp(r'अध्याय:\s*([\s\S]*?)(?=श्लोक:|अर्थ:|संदेश:|सूत्र:|$)', caseSensitive: false)},
    {'key': 'arth',    'icon': '💛', 'label': 'अर्थ',                'rx': RegExp(r'अर्थ:\s*([\s\S]*?)(?=श्लोक:|अध्याय:|संदेश:|सूत्र:|$)', caseSensitive: false)},
    {'key': 'sandesh', 'icon': '🌸', 'label': 'श्री कृष्ण का संदेश', 'rx': RegExp(r'संदेश:\s*([\s\S]*?)(?=श्लोक:|अध्याय:|अर्थ:|सूत्र:|$)', caseSensitive: false)},
    {'key': 'sutra',   'icon': '✨', 'label': 'जीवन सूत्र',           'rx': RegExp(r'सूत्र:\s*([\s\S]*?)(?=श्लोक:|अध्याय:|अर्थ:|संदेश:|$)', caseSensitive: false)},
  ];

  final sections = <MessageSection>[];
  for (final p in patterns) {
    final rx = p['rx'] as RegExp;
    final m = rx.firstMatch(text);
    if (m != null && m.group(1)!.trim().isNotEmpty) {
      sections.add(MessageSection(
        key: p['key'] as String,
        icon: p['icon'] as String,
        label: p['label'] as String,
        content: m.group(1)!.trim(),
      ));
    }
  }
  return sections.isNotEmpty ? sections : null;
}

String cleanForSpeech(String text) {
  return text
      .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
      .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')
      .replaceAll(RegExp(r'श्लोक:|अध्याय:|अर्थ:|संदेश:|सूत्र:'), '. ')
      .replaceAll(RegExp(r'[🔱📖💛🌸✨🙏🦚ॐ✦—►""#*]'), '')
      .replaceAll(RegExp(r'\n+'), '. ')
      .replaceAll(RegExp(r'\s{2,}'), ' ')
      .trim();
}
