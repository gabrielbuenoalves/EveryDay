import 'package:flutter/foundation.dart';

import '../../domain/entities/feed_home.dart';
import '../../domain/usecases/get_feed_home.dart';

class FeedController extends ChangeNotifier {
  FeedController({required this.getFeedHome, this.reload}) {
    reload?.addListener(_onReload);
  }

  final GetFeedHome getFeedHome;
  final Listenable? reload;

  FeedHome? home;
  bool loading = true;
  Object? error;

  void _onReload() {
    load();
  }

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

  @override
  void dispose() {
    reload?.removeListener(_onReload);
    super.dispose();
  }
}
