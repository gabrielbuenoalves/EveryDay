import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/care/data/repositories/care_repository_impl.dart';
import '../../features/care/domain/usecases/care_usecases.dart';
import '../../features/feed/data/repositories/feed_repository_impl.dart';
import '../../features/feed/domain/usecases/get_feed_home.dart';
import '../../features/groups/data/repositories/groups_repository_impl.dart';
import '../../features/groups/domain/usecases/get_groups.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/plans/data/plans_repository_impl.dart';
import '../../features/plans/domain/repositories/plans_repository.dart';
import '../../features/plans/domain/usecases/plans_usecases.dart';
import '../../features/reading/data/repositories/bible_repository_impl.dart';
import '../../features/reading/data/repositories/reading_repository_impl.dart';
import '../../features/reading/domain/usecases/get_bible_passage.dart';
import '../../features/reading/domain/usecases/log_reading.dart';
import '../../features/shelf/data/repositories/shelf_repository_impl.dart';
import '../../features/shelf/domain/usecases/get_bookshelf.dart';

class FeedReload extends ChangeNotifier {
  void ping() => notifyListeners();
}

class AppDependencies {
  AppDependencies({
    required this.auth,
    required this.getFeedHome,
    required this.getBookshelf,
    required this.getGroups,
    required this.getProfile,
    required this.logReading,
    required this.getBiblePassage,
    required this.submitMoodCheckin,
    required this.analyzeCheckin,
    required this.getCareInbox,
    required this.approveCarePlan,
    required this.scheduleCareContact,
    required this.hasCheckedInToday,
    required this.completeCarePlan,
    required this.getCareReflections,
    required this.getMyPlans,
    required this.feedReload,
  });

  final AuthRepository auth;
  final GetFeedHome getFeedHome;
  final GetBookshelf getBookshelf;
  final GetGroups getGroups;
  final GetProfile getProfile;
  final LogReading logReading;
  final GetBiblePassage getBiblePassage;
  final SubmitMoodCheckin submitMoodCheckin;
  final AnalyzeCheckin analyzeCheckin;
  final GetCareInbox getCareInbox;
  final ApproveCarePlan approveCarePlan;
  final ScheduleCareContact scheduleCareContact;
  final HasCheckedInToday hasCheckedInToday;
  final CompleteCarePlan completeCarePlan;
  final GetCareReflections getCareReflections;
  final GetMyPlans getMyPlans;
  final FeedReload feedReload;

  PlansRepository get plans => getMyPlans.repository;

  GetArchivedPlans get getArchivedPlans => GetArchivedPlans(plans);
  ListPlanComments get listPlanComments => ListPlanComments(plans);
  AddPlanComment get addPlanComment => AddPlanComment(plans);
  CreateGroupPlan get createGroupPlan => CreateGroupPlan(plans);
  CompleteGroupPlan get completeGroupPlan => CompleteGroupPlan(plans);
  ListGroupPlans get listGroupPlans => ListGroupPlans(plans);
  MinutesForPassages get minutesForPassages => MinutesForPassages(plans);
  GetMemberEngagement get getMemberEngagement =>
      GetMemberEngagement(getCareReflections.repository);
  GetChurchPulse get getChurchPulse =>
      GetChurchPulse(getCareReflections.repository);
  GetMemberCheckins get getMemberCheckins =>
      GetMemberCheckins(getCareReflections.repository);
  GenerateMemberBriefing get generateMemberBriefing =>
      GenerateMemberBriefing(getCareReflections.repository);

  factory AppDependencies.fromSupabase(SupabaseClient client) {
    final care = CareRepositoryImpl(client);
    final plans = PlansRepositoryImpl(client);
    return AppDependencies(
      auth: AuthRepositoryImpl(client),
      getFeedHome: GetFeedHome(FeedRepositoryImpl(client)),
      getBookshelf: GetBookshelf(ShelfRepositoryImpl(client)),
      getGroups: GetGroups(GroupsRepositoryImpl(client)),
      getProfile: GetProfile(ProfileRepositoryImpl(client)),
      logReading: LogReading(ReadingRepositoryImpl(client)),
      getBiblePassage: GetBiblePassage(BibleRepositoryImpl(client)),
      submitMoodCheckin: SubmitMoodCheckin(care),
      analyzeCheckin: AnalyzeCheckin(care),
      getCareInbox: GetCareInbox(care),
      approveCarePlan: ApproveCarePlan(care),
      scheduleCareContact: ScheduleCareContact(care),
      hasCheckedInToday: HasCheckedInToday(care),
      completeCarePlan: CompleteCarePlan(care),
      getCareReflections: GetCareReflections(care),
      getMyPlans: GetMyPlans(plans),
      feedReload: FeedReload(),
    );
  }
}
