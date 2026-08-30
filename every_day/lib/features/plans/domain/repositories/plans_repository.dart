import '../../../../core/domain/user_preview.dart';
import '../../../care/domain/entities/care_models.dart';
import '../../../feed/domain/entities/feed_home.dart';

export '../../../feed/domain/entities/feed_home.dart';

class PassageComment {
  const PassageComment({
    required this.id,
    required this.author,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final UserPreview author;
  final String body;
  final DateTime createdAt;
}

abstract interface class PlansRepository {
  Future<List<MemberCarePlan>> listMyPlans();
  Future<List<PassageComment>> listComments({
    required String groupId,
    required String passageLabel,
  });
  Future<void> addComment({
    required String groupId,
    String? planId,
    required String passageLabel,
    required String body,
  });
  Future<void> createGroupPlan({
    required String groupId,
    required String title,
    required List<String> passages,
  });
  Future<List<MemberCarePlan>> listGroupPlans(String groupId);
  Future<void> completeGroupPlan({
    required String groupId,
    required String planId,
    required PlanReflection reflection,
  });
  Future<int> minutesForPassages(List<String> labels);
}
