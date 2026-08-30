import '../../../../core/domain/user_preview.dart';

class ReadingGroup {
  const ReadingGroup({
    required this.id,
    required this.name,
    required this.planLabel,
    required this.memberCount,
    required this.weekProgress,
    required this.members,
    this.inviteCode,
  });

  final String id;
  final String name;
  final String planLabel;
  final int memberCount;
  final double weekProgress;
  final List<UserPreview> members;
  final String? inviteCode;
}
