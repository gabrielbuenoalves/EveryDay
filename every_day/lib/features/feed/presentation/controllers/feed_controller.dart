import 'package:flutter/foundation.dart';

import '../../domain/entities/feed_home.dart';
import '../../domain/usecases/get_feed_home.dart';

class FeedController extends ChangeNotifier {
  FeedController({required this.getFeedHome});

  final GetFeedHome getFeedHome;

  FeedHome? home;
  bool loading = true;
  Object? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      home = await getFeedHome();
    } catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
