class BibleVerse {
  const BibleVerse({required this.number, required this.text});

  final String number;
  final String text;
}

class BibleChapterText {
  const BibleChapterText({
    required this.passageId,
    required this.reference,
    required this.content,
    this.verses = const [],
  });

  final String passageId;
  final String reference;
  final String content;
  final List<BibleVerse> verses;

  bool get isEmpty =>
      verses.every((verse) => verse.text.trim().isEmpty) && content.trim().isEmpty;
}

class BiblePassage {
  const BiblePassage({
    required this.abbreviation,
    required this.chapters,
    this.title,
    this.copyright,
    this.info,
  });

  final String abbreviation;
  final String? title;
  final String? copyright;
  final String? info;
  final List<BibleChapterText> chapters;

  bool get isEmpty => chapters.every((chapter) => chapter.isEmpty);
}
