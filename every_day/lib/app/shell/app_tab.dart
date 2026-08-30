enum AppTab { home, plans, groups, notices, members, profile }

class NavDestination {
  const NavDestination({
    required this.id,
    required this.label,
    this.create = false,
    this.badge = 0,
  });

  final String id;
  final String label;
  final bool create;
  final int badge;
}

List<NavDestination> navForPastor(bool pastor, {int careBadge = 0}) {
  if (pastor) {
    return [
      const NavDestination(id: 'home', label: 'Home'),
      const NavDestination(id: 'groups', label: 'Grupos'),
      const NavDestination(id: 'create', label: 'Criar', create: true),
      NavDestination(id: 'notices', label: 'Avisos', badge: careBadge),
      const NavDestination(id: 'members', label: 'Membros'),
      const NavDestination(id: 'profile', label: 'Perfil'),
    ];
  }
  return const [
    NavDestination(id: 'home', label: 'Home'),
    NavDestination(id: 'plans', label: 'Planos'),
    NavDestination(id: 'create', label: 'Criar', create: true),
    NavDestination(id: 'groups', label: 'Grupos'),
    NavDestination(id: 'profile', label: 'Perfil'),
  ];
}
