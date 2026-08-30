import '../entities/care_models.dart';

abstract interface class CareRepository {
  Future<bool> hasCheckedInToday();
  Future<String> submitCheckin({
    required int score,
    String? body,
    required bool lgpdAccepted,
  });
  Future<void> analyzeCheckin(String checkinId);
  Future<List<CareInboxItem>> listInbox();
  Future<void> approvePlan({
    required String reportId,
    required String title,
    required String message,
    required List<String> passages,
    required int durationDays,
  });
  Future<void> scheduleContact({
    required String reportId,
    required String whenLabel,
    String? note,
  });
  Future<void> completePlan({
    required String planId,
    required PlanReflection reflection,
  });
  Future<List<CarePlanInsight>> listReflections({String? userId});
}
