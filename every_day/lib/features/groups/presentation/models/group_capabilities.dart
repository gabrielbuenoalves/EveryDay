import '../../domain/entities/reading_group.dart';

/// Optional presentation data for group features which do not yet have a
/// repository capability. Keeping these at the edge prevents a UI state from
/// being mistaken for persisted membership data.
class GroupExploreItem {
  const GroupExploreItem({required this.group, this.description});

  final ReadingGroup group;
  final String? description;
}

class GroupHistoryItem {
  const GroupHistoryItem({required this.group, this.completedAtLabel});

  final ReadingGroup group;
  final String? completedAtLabel;
}

class GroupCapabilities {
  const GroupCapabilities({
    this.explore = const [],
    this.history = const [],
    this.onJoin,
    this.onLeave,
    this.onOpenTopics,
    this.onOpenPrayerRequests,
    this.onConfirmPrayer,
  });

  final List<GroupExploreItem>? explore;
  final List<GroupHistoryItem>? history;
  final Future<void> Function(ReadingGroup group)? onJoin;
  final Future<void> Function(ReadingGroup group)? onLeave;
  final Future<void> Function(ReadingGroup group)? onOpenTopics;
  final Future<void> Function(ReadingGroup group)? onOpenPrayerRequests;
  final Future<void> Function(ReadingGroup group)? onConfirmPrayer;
}
