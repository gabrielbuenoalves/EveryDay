import '../entities/care_models.dart';
import '../repositories/care_repository.dart';

class SubmitMoodCheckin {
  const SubmitMoodCheckin(this._repository);

  final CareRepository _repository;

  Future<String> call({
    required int score,
    String? body,
    required bool lgpdAccepted,
  }) {
    return _repository.submitCheckin(
      score: score,
      body: body,
      lgpdAccepted: lgpdAccepted,
    );
  }
}

class AnalyzeCheckin {
  const AnalyzeCheckin(this._repository);

  final CareRepository _repository;

  Future<void> call(String checkinId) => _repository.analyzeCheckin(checkinId);
}

class GetCareInbox {
  const GetCareInbox(this._repository);

  final CareRepository _repository;

  Future<List<CareInboxItem>> call() => _repository.listInbox();
}

class ApproveCarePlan {
  const ApproveCarePlan(this._repository);

  final CareRepository _repository;

  Future<void> call({
    required String reportId,
    required String title,
    required String message,
    required List<String> passages,
    required int durationDays,
  }) {
    return _repository.approvePlan(
      reportId: reportId,
      title: title,
      message: message,
      passages: passages,
      durationDays: durationDays,
    );
  }
}

class ScheduleCareContact {
  const ScheduleCareContact(this._repository);

  final CareRepository _repository;

  Future<void> call({
    required String reportId,
    required String whenLabel,
    String? note,
  }) {
    return _repository.scheduleContact(
      reportId: reportId,
      whenLabel: whenLabel,
      note: note,
    );
  }
}

class HasCheckedInToday {
  const HasCheckedInToday(this._repository);

  final CareRepository _repository;

  Future<bool> call() => _repository.hasCheckedInToday();
}

class CompleteCarePlan {
  const CompleteCarePlan(this._repository);

  final CareRepository _repository;

  Future<void> call({
    required String planId,
    required PlanReflection reflection,
  }) {
    return _repository.completePlan(planId: planId, reflection: reflection);
  }
}

class GetCareReflections {
  const GetCareReflections(this._repository);

  final CareRepository _repository;

  Future<List<CarePlanInsight>> call({String? userId}) =>
      _repository.listReflections(userId: userId);
}
