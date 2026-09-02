import 'package:flutter/material.dart';

import 'community_state.dart';

class CommunityScope extends InheritedNotifier<CommunityState> {
  const CommunityScope({
    super.key,
    required CommunityState state,
    required super.child,
  }) : super(notifier: state);
  static CommunityState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CommunityScope>()!.notifier!;
}
