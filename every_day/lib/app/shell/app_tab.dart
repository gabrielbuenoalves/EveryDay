enum AppTab { feed, shelf, groups, profile }

extension AppTabX on AppTab {
  String get label => switch (this) {
    AppTab.feed => 'Feed',
    AppTab.shelf => 'Estante',
    AppTab.groups => 'Grupos',
    AppTab.profile => 'Perfil',
  };
}
