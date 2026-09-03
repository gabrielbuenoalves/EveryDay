import 'package:every_day/app/di/app_dependencies.dart';
import 'package:every_day/features/agenda/domain/entities/agenda_event.dart';
import 'package:every_day/features/agenda/domain/repositories/agenda_repository.dart';
import 'package:every_day/features/agenda/domain/usecases/agenda_usecases.dart';
import 'package:every_day/core/domain/daily_reading.dart';
import 'package:every_day/core/domain/user_preview.dart';
import 'package:every_day/core/domain/user_role.dart';
import 'package:every_day/features/auth/domain/repositories/auth_repository.dart';
import 'package:every_day/features/care/domain/entities/care_models.dart';
import 'package:every_day/features/care/domain/repositories/care_repository.dart';
import 'package:every_day/features/care/domain/usecases/care_usecases.dart';
import 'package:every_day/features/feed/domain/repositories/feed_repository.dart';
import 'package:every_day/features/feed/domain/usecases/get_feed_home.dart';
import 'package:every_day/features/groups/domain/entities/reading_group.dart';
import 'package:every_day/features/groups/domain/repositories/groups_repository.dart';
import 'package:every_day/features/groups/domain/usecases/get_groups.dart';
import 'package:every_day/features/plans/domain/usecases/plans_usecases.dart';
import 'package:every_day/features/profile/domain/entities/user_profile.dart';
import 'package:every_day/features/profile/domain/repositories/profile_repository.dart';
import 'package:every_day/features/profile/domain/usecases/get_profile.dart';
import 'package:every_day/features/reading/domain/entities/bible_passage.dart';
import 'package:every_day/features/reading/domain/entities/reading_log.dart';
import 'package:every_day/features/reading/domain/repositories/bible_repository.dart';
import 'package:every_day/features/reading/domain/repositories/reading_repository.dart';
import 'package:every_day/features/reading/domain/usecases/get_bible_passage.dart';
import 'package:every_day/features/reading/domain/usecases/log_reading.dart';
import 'package:every_day/features/shelf/domain/entities/bible_book.dart';
import 'package:every_day/features/shelf/domain/repositories/shelf_repository.dart';
import 'package:every_day/features/shelf/domain/usecases/get_bookshelf.dart';

AppDependencies testDependencies({
  UserRole role = UserRole.member,
  bool planDone = false,
}) {
  final care = _FakeCare();
  final plans = _FakePlans(planDone: planDone);
  return AppDependencies(
    auth: _FakeAuth(),
    getFeedHome: GetFeedHome(_FakeFeed()),
    getBookshelf: GetBookshelf(_FakeShelf()),
    getGroups: GetGroups(_FakeGroups()),
    getProfile: GetProfile(_FakeProfile(role: role)),
    logReading: LogReading(_FakeReading()),
    getBiblePassage: GetBiblePassage(_FakeBible()),
    submitMoodCheckin: SubmitMoodCheckin(care),
    analyzeCheckin: AnalyzeCheckin(care),
    getCareInbox: GetCareInbox(care),
    approveCarePlan: ApproveCarePlan(care),
    scheduleCareContact: ScheduleCareContact(care),
    hasCheckedInToday: HasCheckedInToday(care),
    completeCarePlan: CompleteCarePlan(care),
    getCareReflections: GetCareReflections(care),
    getMyPlans: GetMyPlans(plans),
    getAgenda: GetAgenda(_FakeAgenda()),
    feedReload: FeedReload(),
  );
}

class _FakeAgenda implements AgendaRepository {
  @override
  Future<List<AgendaEvent>> listEvents() async => const [];

  @override
  Future<String> createEvent(AgendaEventDraft draft) async => 'event-1';

  @override
  Future<void> updateEvent(String eventId, AgendaEventDraft draft) async {}

  @override
  Future<void> setStatus(String eventId, AgendaEventStatus status) async {}

  @override
  Future<void> setAttendance(String eventId, {required bool attending}) async {}
}

class _FakeAuth implements AuthRepository {
  @override
  Stream<bool> get authChanges => const Stream.empty();

  @override
  bool get isSignedIn => true;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> hasChurch() async => true;

  @override
  Future<void> createChurch(String name) async {}

  @override
  Future<void> joinChurch(String inviteCode) async {}

  @override
  Future<void> joinGroup(String inviteCode) async {}

  @override
  Future<void> joinAsLeader(String inviteCode) async {}

  @override
  Future<void> signInWithYouVersion() async {}

  @override
  bool get youVersionSignInEnabled => false;

  @override
  UserRole intendedRole = UserRole.member;
}

class _FakeFeed implements FeedRepository {
  @override
  Future<FeedHome> getHome() async {
    final now = DateTime.now();
    return FeedHome(
      streakDays: 17,
      items: [
        BookCompletedFeedItem(
          id: '1',
          occurredAt: now.subtract(const Duration(minutes: 12)),
          author: const UserPreview(
            id: 'lucas',
            displayName: 'Lucas',
            initials: 'LC',
            avatarColorValue: 0xFFB8B0A4,
          ),
          bookName: 'João',
          chapterCount: 21,
          quote: 'Cheguei ao fim e queria começar de novo. Que livro.',
          highFives: 12,
          comments: 3,
        ),
      ],
    );
  }
}

MemberCarePlan _samplePlan({required bool planDone}) {
  return MemberCarePlan(
    id: 'plan-1',
    title: 'Uma leitura para você',
    message: 'Seu pastor revisou estas passagens para este momento.',
    readings: [
      CareReading(
        reading: DailyReading.fromLabel('Salmos 23'),
        completed: planDone,
      ),
      CareReading(
        reading: const DailyReading(
          passageLabel: 'Salmos 28–30',
          book: 'Salmos',
          startChapter: 28,
          endChapter: 30,
        ),
        completed: planDone,
      ),
      CareReading(
        reading: DailyReading.fromLabel('João 14:1-6'),
        completed: planDone,
      ),
    ],
  );
}

class _FakePlans implements PlansRepository {
  _FakePlans({this.planDone = false});

  final bool planDone;

  @override
  Future<List<MemberCarePlan>> listMyPlans() async => [
    _samplePlan(planDone: planDone),
  ];

  @override
  Future<List<MemberCarePlan>> listArchivedPlans() async => [
    MemberCarePlan(
      id: 'arch-1',
      title: 'Leitura arquivada',
      readings: [
        CareReading(
          reading: DailyReading.fromLabel('Salmos 1'),
          completed: true,
        ),
      ],
      archived: true,
      sessionMinutes: 6,
      takeaway: 'Ficou a paz',
    ),
  ];

  @override
  Future<List<PassageComment>> listComments({
    required String groupId,
    required String passageLabel,
  }) async => const [];

  @override
  Future<void> addComment({
    required String groupId,
    String? planId,
    required String passageLabel,
    required String body,
  }) async {}

  @override
  Future<void> createGroupPlan({
    required String groupId,
    required String title,
    required List<String> passages,
  }) async {}

  @override
  Future<List<MemberCarePlan>> listGroupPlans(String groupId) async {
    return [
      MemberCarePlan(
        id: '1:gp-active',
        title: 'Salmos da semana',
        readings: [CareReading(reading: DailyReading.fromLabel('Salmos 1'))],
        sourceLabel: 'Grupo Salmos em 30 dias',
        groupId: '1',
        readingPlanId: 'gp-active',
        pastoral: false,
      ),
      MemberCarePlan(
        id: '1:gp-done',
        title: 'João 1',
        readings: [
          CareReading(
            reading: DailyReading.fromLabel('João 1'),
            completed: true,
          ),
        ],
        sourceLabel: 'Grupo Salmos em 30 dias',
        groupId: '1',
        readingPlanId: 'gp-done',
        pastoral: false,
        archived: true,
        sessionMinutes: 12,
        takeaway: 'O Verbo se fez carne',
      ),
    ];
  }

  @override
  Future<void> completeGroupPlan({
    required String groupId,
    required String planId,
    required PlanReflection reflection,
  }) async {}

  @override
  Future<int> minutesForPassages(List<String> labels) async => 8;
}

class _FakeShelf implements ShelfRepository {
  @override
  Future<Bookshelf> getBookshelf() async {
    return const Bookshelf(
      books: [
        BibleBook(
          id: 'gen',
          name: 'Gênesis',
          testament: BibleTestament.old,
          chapters: 50,
          readChapters: 50,
        ),
      ],
    );
  }
}

class _FakeGroups implements GroupsRepository {
  @override
  Future<List<ReadingGroup>> getGroups() async {
    return const [
      ReadingGroup(
        id: '1',
        name: 'Salmos em 30 dias',
        planLabel: 'Encontro · Quinta, 20h',
        memberCount: 2,
        weekProgress: 0.5,
        inviteCode: 'GRUPO1',
        members: [
          UserPreview(
            id: 'lucas',
            displayName: 'Lucas',
            initials: 'LC',
            avatarColorValue: 0xFFB8B0A4,
          ),
        ],
      ),
    ];
  }
}

class _FakeProfile implements ProfileRepository {
  _FakeProfile({this.role = UserRole.member});

  final UserRole role;

  @override
  Future<UserProfile> getProfile() async {
    return UserProfile(
      id: 'me',
      displayName: 'Você',
      initials: 'VC',
      avatarColorValue: 0xFFD95F33,
      streakDays: 17,
      longestStreak: 17,
      currentPlan: 'Salmos 28–30',
      role: role,
      churchName: 'Igreja',
      inviteCode: role.isPastor ? 'IGREJA' : null,
      stats: const UserStats(
        chaptersThisWeek: 18,
        booksCompleted: 4,
        minutesThisWeek: 96,
      ),
    );
  }
}

class _FakeReading implements ReadingRepository {
  @override
  Future<void> logReading(ReadingLog log) async {}
}

class _FakeBible implements BibleRepository {
  @override
  Future<BiblePassage> getPassage(DailyReading reading) async {
    return BiblePassage(
      abbreviation: 'NVI',
      copyright: 'Bíblia Sagrada, Nova Versão Internacional',
      chapters: [
        BibleChapterText(
          passageId: 'PSA.28',
          reference: reading.passageLabel,
          content: 'Ao Senhor clamo. Ele é a minha rocha.',
          verses: const [
            BibleVerse(
              number: '1',
              text: 'Ao Senhor clamo. Ele é a minha rocha.',
            ),
          ],
        ),
      ],
    );
  }
}

class _FakeCare implements CareRepository {
  @override
  Future<bool> hasCheckedInToday() async => true;

  @override
  Future<String> submitCheckin({
    required int score,
    String? body,
    required bool lgpdAccepted,
  }) async => 'checkin-1';

  @override
  Future<void> analyzeCheckin(String checkinId) async {}

  @override
  Future<List<CareInboxItem>> listInbox() async => const [];

  @override
  Future<void> approvePlan({
    required String reportId,
    required String title,
    required String message,
    required List<String> passages,
    required int durationDays,
  }) async {}

  @override
  Future<void> scheduleContact({
    required String reportId,
    required String whenLabel,
    String? note,
  }) async {}

  @override
  Future<void> completePlan({
    required String planId,
    required PlanReflection reflection,
  }) async {}

  @override
  Future<List<CarePlanInsight>> listReflections({String? userId}) async =>
      const [];

  @override
  Future<MemberEngagement> listEngagement(String userId) async {
    return const MemberEngagement(
      minutesTotal: 96,
      minutesWeek: 42,
      readingCount: 12,
      readingCountWeek: 5,
      commentCount: 3,
      commentCountWeek: 1,
      checkinCount: 4,
      plansCompleted: 2,
      activeDaysWeek: 4,
      lastPassage: 'Salmos 23',
    );
  }

  @override
  Future<ChurchPulse> listChurchPulse() async {
    return const ChurchPulse(
      minutesWeek: 120,
      readingsWeek: 18,
      commentsWeek: 7,
      completionsWeek: 3,
    );
  }

  @override
  Future<List<MoodCheckin>> listMemberCheckins(String userId) async => const [];

  @override
  Future<MemberAiReport> generateMemberBriefing(String userId) async {
    return const MemberAiReport(
      summary: 'Lucas tem lido com regularidade nesta semana e deixou um quiz de compreensão razoável.',
      prayerAttention: 'Nenhum pedido de oração recente.',
      readingPulse: '42 min nesta semana · última passagem Salmos 23.',
      nextStep: 'Afirme a constância e avance com calma na próxima leitura.',
      urgency: 'low',
    );
  }
}
