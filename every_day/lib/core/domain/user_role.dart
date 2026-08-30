enum UserRole { member, leader, pastor }

enum AppPermission {
  viewGroupPulse,
  nudgeGroup,
  moderateGroup,
  createGroup,
  assignGroupPlan,
  inviteToGroup,
  inviteToChurch,
  editChurchPlan,
  viewChurchPulse,
  moderateChurch,
  promoteLeader,
  removeFromChurch,
  viewCareInbox,
  actOnCareReport,
}

extension UserRoleX on UserRole {
  String get label => switch (this) {
    UserRole.member => 'Membro',
    UserRole.leader => 'Líder',
    UserRole.pastor => 'Pastor',
  };

  bool get canLead => this == UserRole.leader || this == UserRole.pastor;
  bool get isPastor => this == UserRole.pastor;
  bool get isLeader => this == UserRole.leader;

  String get loginBlurb => switch (this) {
    UserRole.member => 'Leia com a igreja. Use o código de convite do culto.',
    UserRole.leader => 'Cuide do seu grupo. Use o código que o pastor compartilhou.',
    UserRole.pastor => 'Crie a igreja, gere o convite e acompanhe a comunidade.',
  };

  String get setupTitle => switch (this) {
    UserRole.member => 'Entrar na igreja',
    UserRole.leader => 'Entrar como líder',
    UserRole.pastor => 'Cadastrar igreja',
  };

  String get setupCopy => switch (this) {
    UserRole.member => 'Peça o código de 6 caracteres à liderança ou escaneie o QR do culto.',
    UserRole.leader => 'Use o código do grupo ou da igreja. Você entra como líder, não como pastor.',
    UserRole.pastor => 'Prepare a comunidade. Depois você recebe o código para convidar membros e líderes.',
  };

  bool allows(AppPermission permission) {
    if (this == UserRole.pastor) return true;
    if (this == UserRole.member) return false;
    return switch (permission) {
      AppPermission.viewGroupPulse ||
      AppPermission.nudgeGroup ||
      AppPermission.moderateGroup ||
      AppPermission.createGroup ||
      AppPermission.assignGroupPlan ||
      AppPermission.inviteToGroup => true,
      AppPermission.inviteToChurch ||
      AppPermission.editChurchPlan ||
      AppPermission.viewChurchPulse ||
      AppPermission.moderateChurch ||
      AppPermission.promoteLeader ||
      AppPermission.removeFromChurch ||
      AppPermission.viewCareInbox ||
      AppPermission.actOnCareReport => false,
    };
  }

  static UserRole fromName(String? value) {
    return switch (value) {
      'pastor' => UserRole.pastor,
      'leader' => UserRole.leader,
      _ => UserRole.member,
    };
  }
}
