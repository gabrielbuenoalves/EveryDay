import '../../../care/domain/entities/care_models.dart';
import '../repositories/plans_repository.dart';

export '../repositories/plans_repository.dart';

class GetMyPlans {
  const GetMyPlans(this._repository);

  final PlansRepository _repository;

  Future<List<MemberCarePlan>> call() => _repository.listMyPlans();
}

class ListPlanComments {
  const ListPlanComments(this._repository);

  final PlansRepository _repository;

  Future<List<PassageComment>> call({
    required String groupId,
    required String passageLabel,
  }) {
    return _repository.listComments(
      groupId: groupId,
      passageLabel: passageLabel,
    );
  }
}

class AddPlanComment {
  const AddPlanComment(this._repository);

  final PlansRepository _repository;

  Future<void> call({
    required String groupId,
    String? planId,
    required String passageLabel,
    required String body,
  }) {
    return _repository.addComment(
      groupId: groupId,
      planId: planId,
      passageLabel: passageLabel,
      body: body,
    );
  }
}

class CreateGroupPlan {
  const CreateGroupPlan(this._repository);

  final PlansRepository _repository;

  Future<void> call({
    required String groupId,
    required String title,
    required List<String> passages,
  }) {
    return _repository.createGroupPlan(
      groupId: groupId,
      title: title,
      passages: passages,
    );
  }
}

class ListGroupPlans {
  const ListGroupPlans(this._repository);

  final PlansRepository _repository;

  Future<List<MemberCarePlan>> call(String groupId) =>
      _repository.listGroupPlans(groupId);
}

class CompleteGroupPlan {
  const CompleteGroupPlan(this._repository);

  final PlansRepository _repository;

  Future<void> call({
    required String groupId,
    required String planId,
    required PlanReflection reflection,
  }) {
    return _repository.completeGroupPlan(
      groupId: groupId,
      planId: planId,
      reflection: reflection,
    );
  }
}

class MinutesForPassages {
  const MinutesForPassages(this._repository);

  final PlansRepository _repository;

  Future<int> call(List<String> labels) => _repository.minutesForPassages(labels);
}
