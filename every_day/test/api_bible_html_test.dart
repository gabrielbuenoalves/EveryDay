import 'package:every_day/core/bible/api_bible_html.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lê versículos numerados do HTML da API.Bible', () {
    const html = '''
<p class="p"><span class="v">12</span>Eu sou a luz do mundo.</p>
<p class="p"><span data-number="31" class="v">31</span>Se vocês permanecerem firmes na minha palavra.</p>
''';
    final verses = parseApiBibleHtml(html);
    expect(verses.map((v) => v.number), ['12', '31']);
    expect(verses.first.text, contains('luz do mundo'));
  });
}
