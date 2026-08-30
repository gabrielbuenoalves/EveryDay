class ReadingLog {
  const ReadingLog({
    required this.passageLabel,
    required this.minutes,
    this.note,
  });

  final String passageLabel;
  final int minutes;
  final String? note;
}
