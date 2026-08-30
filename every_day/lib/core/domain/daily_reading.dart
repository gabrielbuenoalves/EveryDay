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
}
