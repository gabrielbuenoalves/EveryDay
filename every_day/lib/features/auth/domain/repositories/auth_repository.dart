import '../../../../core/domain/user_role.dart';

abstract interface class AuthRepository {
  Stream<bool> get authChanges;
  bool get isSignedIn;
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> signOut();
  Future<bool> hasChurch();
  Future<void> createChurch(String name);
  Future<void> joinChurch(String inviteCode);
  Future<void> joinGroup(String inviteCode);
  Future<void> joinAsLeader(String inviteCode);
  Future<void> signInWithYouVersion();
  bool get youVersionSignInEnabled;
  UserRole get intendedRole;
  set intendedRole(UserRole value);
}
