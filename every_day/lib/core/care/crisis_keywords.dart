const crisisKeywords = [
  'suicídio',
  'suicidio',
  'me matar',
  'quero morrer',
  'tirar minha vida',
  'automutilação',
  'automutilacao',
  'me cortar',
  'me ferir',
  'não aguento mais viver',
  'nao aguento mais viver',
  'ideação suicida',
  'ideacao suicida',
  'estupro',
  'me bateram',
  'violência doméstica',
  'violencia domestica',
];

bool containsCrisisLanguage(String? text) {
  if (text == null || text.trim().isEmpty) return false;
  final normalized = text.toLowerCase();
  return crisisKeywords.any(normalized.contains);
}
