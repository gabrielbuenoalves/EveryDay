enum AppTab { home, plans, agenda, groups, care, notices, members, profile }

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
      const NavDestination(id: 'home', label: 'Início'),
      const NavDestination(id: 'groups', label: 'Grupos'),
      NavDestination(id: 'care', label: 'Cuidado', badge: careBadge),
      const NavDestination(id: 'agenda', label: 'Agenda'),
      const NavDestination(id: 'profile', label: 'Perfil'),
    ];
  }
  return const [
    NavDestination(id: 'home', label: 'Início'),
    NavDestination(id: 'groups', label: 'Grupos'),
    NavDestination(id: 'plans', label: 'Ler'),
    NavDestination(id: 'agenda', label: 'Agenda'),
    NavDestination(id: 'profile', label: 'Perfil'),
  ];
}
