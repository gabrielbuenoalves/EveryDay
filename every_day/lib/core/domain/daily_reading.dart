class DailyReading {
  const DailyReading({
    required this.passageLabel,
    required this.book,
    required this.startChapter,
    required this.endChapter,
  });

  final String passageLabel;
  final String book;
  final int startChapter;
  final int endChapter;

  factory DailyReading.fromLabel(
    String label, {
    String? book,
    int? startChapter,
    int? endChapter,
  }) {
    final trimmed = label.trim();
    final parsed = _parsePassage(trimmed);
    return DailyReading(
      passageLabel: trimmed.isEmpty ? 'Passagem' : trimmed,
      book: parsed.$1.isNotEmpty
          ? parsed.$1
          : (book != null && book.trim().isNotEmpty ? book.trim() : 'Bíblia'),
      startChapter: parsed.$2 > 0 ? parsed.$2 : (startChapter ?? 1),
      endChapter: parsed.$3 > 0
          ? parsed.$3
          : (endChapter ?? (parsed.$2 > 0 ? parsed.$2 : 1)),
    );
  }
}

(String, int, int) _parsePassage(String label) {
  final verse = RegExp(r'^(.+?)\s+(\d+):\d+').firstMatch(label);
  if (verse != null) {
    final chapter = int.parse(verse.group(2)!);
    return (verse.group(1)!.trim(), chapter, chapter);
  }
  final range = RegExp(r'^(.+?)\s+(\d+)\s*[-–]\s*(\d+)$').firstMatch(label);
  if (range != null) {
    return (
      range.group(1)!.trim(),
      int.parse(range.group(2)!),
      int.parse(range.group(3)!),
    );
  }
  final single = RegExp(r'^(.+?)\s+(\d+)$').firstMatch(label);
  if (single != null) {
    final chapter = int.parse(single.group(2)!);
    return (single.group(1)!.trim(), chapter, chapter);
  }
  return (label.trim(), 1, 1);
}
