String timeAgo(DateTime date, {DateTime? now}) {
  final elapsed = (now ?? DateTime.now()).difference(date);

  if (elapsed.inMinutes < 1) {
    return 'agora';
  }
  if (elapsed.inMinutes < 60) {
    return 'há ${elapsed.inMinutes} min';
  }
  if (elapsed.inHours < 24) {
    return 'há ${elapsed.inHours} h';
  }
  if (elapsed.inDays == 1) {
    return 'há 1 dia';
  }
  return 'há ${elapsed.inDays} dias';
}
