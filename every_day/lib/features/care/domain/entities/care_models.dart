import '../../../../core/domain/user_preview.dart';

enum CareUrgency { low, medium, high, critical }

enum CareStatus { logged, needsCare, analyzed, planSent, contactScheduled }

class MoodCheckin {
  const MoodCheckin({
    required this.id,
    required this.score,
    required this.day,
    required this.status,
    required this.crisis,
    this.body,
  });

  final String id;
  final int score;
  final DateTime day;
  final CareStatus status;
  final bool crisis;
  final String? body;
}

class PastoralReport {
  const PastoralReport({
    required this.id,
    required this.checkinId,
    required this.summary,
    required this.urgency,
    this.theme,
    this.durationDays,
    required this.passages,
    required this.approachNotes,
  });

  final String id;
  final String checkinId;
  final String summary;
  final CareUrgency urgency;
  final String? theme;
  final int? durationDays;
  final List<String> passages;
  final List<String> approachNotes;
}

class CareInboxItem {
  const CareInboxItem({
    required this.checkin,
    required this.member,
    this.report,
  });

  final MoodCheckin checkin;
  final UserPreview member;
  final PastoralReport? report;

  String get preview {
    final body = checkin.body?.trim();
    if (body != null && body.isNotEmpty) {
      return body.split('\n').where((line) => line.trim().isNotEmpty).join(' · ');
    }
    if (report != null && report!.summary.isNotEmpty) {
      return report!.summary;
    }
    return 'Pedido de oração · nota ${checkin.score}';
  }

  bool get hasAiReport {
    final summary = report?.summary.trim() ?? '';
    if (summary.isEmpty) return false;
    return !summary.contains('Aguardando análise') &&
        !summary.contains('Análise automática indisponível');
  }

  String get pastoralBriefing {
    if (hasAiReport) return report!.summary;
    final body = checkin.body?.trim();
    if (body != null && body.isNotEmpty) {
      return 'O membro compartilhou:\n$body\n\nA IA ainda não completou o relatório. Use o relato acima para o primeiro contato.';
    }
    return 'Membro pediu cuidado pastoral. Ainda sem análise automática.';
  }
}

CareStatus careStatusFrom(String? value) {
  return switch (value) {
    'needs_care' => CareStatus.needsCare,
    'analyzed' => CareStatus.analyzed,
    'plan_sent' => CareStatus.planSent,
    'contact_scheduled' => CareStatus.contactScheduled,
    _ => CareStatus.logged,
  };
}

CareUrgency careUrgencyFrom(String? value) {
  return switch (value) {
    'critical' => CareUrgency.critical,
    'high' => CareUrgency.high,
    'low' => CareUrgency.low,
    _ => CareUrgency.medium,
  };
}

extension CareUrgencyX on CareUrgency {
  String get label => switch (this) {
    CareUrgency.low => 'Baixo',
    CareUrgency.medium => 'Médio',
    CareUrgency.high => 'Alto',
    CareUrgency.critical => 'Crítico',
  };

  int get rank => switch (this) {
    CareUrgency.critical => 0,
    CareUrgency.high => 1,
    CareUrgency.medium => 2,
    CareUrgency.low => 3,
  };
}

class PlanReflection {
  const PlanReflection({
    required this.comment,
    required this.takeaway,
    required this.understanding,
    required this.reception,
    required this.minutes,
  });

  final String comment;
  final String takeaway;
  final int understanding;
  final String reception;
  final int minutes;
}

class CarePlanInsight {
  const CarePlanInsight({
    required this.id,
    required this.planId,
    required this.userId,
    required this.memberName,
    required this.planTitle,
    required this.understanding,
    required this.reception,
    required this.minutes,
    required this.completedAt,
    this.comment,
    this.takeaway,
  });

  final String id;
  final String planId;
  final String userId;
  final String memberName;
  final String planTitle;
  final int understanding;
  final String reception;
  final int minutes;
  final DateTime completedAt;
  final String? comment;
  final String? takeaway;

  String get understandingLabel => switch (understanding) {
        1 => 'Confuso',
        2 => 'Pouco',
        3 => 'Razoável',
        4 => 'Bom',
        _ => 'Claro',
      };

  String get receptionLabel => switch (reception) {
        'consolo' => 'Consolo',
        'esperanca' => 'Esperança',
        'encorajamento' => 'Encorajamento',
        'desafio' => 'Desafio',
        'ainda_pesado' => 'Ainda pesado',
        _ => 'Paz',
      };

  String get nextReadingHint {
    if (understanding <= 2 || reception == 'ainda_pesado') {
      return 'Na próxima, prefira um texto mais curto e de acolhimento.';
    }
    if (reception == 'desafio' && understanding >= 4) {
      return 'Pode aprofundar o tema com um texto um pouco mais desafiador.';
    }
    if (reception == 'paz' || reception == 'consolo' || reception == 'esperanca') {
      return 'O texto acolheu. Pode seguir no mesmo tom, ou avançar com calma.';
    }
    return 'Mantenha textos claros, ligados ao que essa ovelha está vivendo.';
  }
}

class MemberEngagement {
  const MemberEngagement({
    required this.minutesTotal,
    required this.minutesWeek,
    required this.readingCount,
    required this.readingCountWeek,
    required this.commentCount,
    required this.commentCountWeek,
    required this.checkinCount,
    required this.plansCompleted,
    required this.activeDaysWeek,
    this.lastReadAt,
    this.lastPassage,
  });

  final int minutesTotal;
  final int minutesWeek;
  final int readingCount;
  final int readingCountWeek;
  final int commentCount;
  final int commentCountWeek;
  final int checkinCount;
  final int plansCompleted;
  final int activeDaysWeek;
  final DateTime? lastReadAt;
  final String? lastPassage;
}

class ChurchPulse {
  const ChurchPulse({
    required this.minutesWeek,
    required this.readingsWeek,
    required this.commentsWeek,
    required this.completionsWeek,
  });

  final int minutesWeek;
  final int readingsWeek;
  final int commentsWeek;
  final int completionsWeek;
}

class MemberAiReport {
  const MemberAiReport({
    required this.summary,
    required this.prayerAttention,
    required this.readingPulse,
    required this.nextStep,
    required this.urgency,
  });

  final String summary;
  final String prayerAttention;
  final String readingPulse;
  final String nextStep;
  final String urgency;

  bool get needsAttention => urgency == 'high' || urgency == 'critical';
}

const kReceptionChoices = <({String id, String label})>[
  (id: 'paz', label: 'Paz'),
  (id: 'consolo', label: 'Consolo'),
  (id: 'esperanca', label: 'Esperança'),
  (id: 'encorajamento', label: 'Encorajamento'),
  (id: 'desafio', label: 'Desafio'),
  (id: 'ainda_pesado', label: 'Ainda pesado'),
];
