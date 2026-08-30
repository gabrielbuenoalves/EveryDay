class ApiBibleVerse {
  const ApiBibleVerse({required this.number, required this.text});

  final String number;
  final String text;
}

List<ApiBibleVerse> parseApiBibleHtml(String html) {
  final numbered = RegExp(
    r'<span[^>]*(?:class="[^"]*\bv\b[^"]*"|data-number="\d+")[^>]*>\s*(\d+)\s*</span>\s*',
    caseSensitive: false,
  );
  final matches = numbered.allMatches(html).toList();
  if (matches.isEmpty) {
    final text = stripHtml(html);
    return text.isEmpty ? const [] : [ApiBibleVerse(number: '', text: text)];
  }

  final verses = <ApiBibleVerse>[];
  for (var i = 0; i < matches.length; i++) {
    final match = matches[i];
    final start = match.end;
    final end = i + 1 < matches.length ? matches[i + 1].start : html.length;
    final text = stripHtml(html.substring(start, end));
    if (text.isEmpty) continue;
    verses.add(ApiBibleVerse(number: match.group(1) ?? '', text: text));
  }
  return verses;
}

String stripHtml(String html) {
  return html
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
