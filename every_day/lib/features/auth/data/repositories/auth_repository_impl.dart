import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/domain/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../youversion_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client, {YouVersionSignIn? youVersionSignIn})
    : _youVersion = youVersionSignIn ?? YouVersionSignIn(_client);

  final SupabaseClient _client;
  final YouVersionSignIn _youVersion;
  UserRole _intendedRole = UserRole.member;
  var _intendedSet = false;

  @override
  UserRole get intendedRole {
    if (_intendedSet) return _intendedRole;
    final stored = _client.auth.currentUser?.userMetadata?['intended_role'];
    if (stored is String) return UserRoleX.fromName(stored);
    return _intendedRole;
  }

  @override
  set intendedRole(UserRole value) {
    _intendedRole = value;
    _intendedSet = true;
  }

  @override
  bool get youVersionSignInEnabled => _youVersion.isEnabled;

  @override
  Stream<bool> get authChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session != null);

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  @override
  Future<void> signIn({required String email, required String password}) {
    return _client.auth.signInWithPassword(email: email.trim(), password: password);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'display_name': displayName.trim(),
        'intended_role': intendedRole.name,
      },
    );
    if (response.session == null && response.user != null) {
      await signIn(email: email, password: password);
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<bool> hasChurch() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return false;
    for (var i = 0; i < 8; i++) {
      final row = await _client.from('profiles').select('church_id').eq('id', uid).maybeSingle();
      if (row != null) {
        return row['church_id'] != null;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    return false;
  }

  @override
  Future<void> createChurch(String name) async {
    await _client.rpc('create_church', params: {'p_name': name.trim()});
  }

  @override
  Future<void> joinChurch(String inviteCode) async {
    await _client.rpc('join_church', params: {'p_code': inviteCode.trim()});
  }

  @override
  Future<void> joinGroup(String inviteCode) async {
    await _client.rpc('join_group', params: {'p_code': inviteCode.trim()});
  }

  @override
  Future<void> joinAsLeader(String inviteCode) async {
    final code = inviteCode.trim();
    try {
      await joinChurch(code);
    } catch (_) {
      await joinGroup(code);
    }
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    await _client.from('profiles').update({'role': 'leader'}).eq('id', uid);
  }

  @override
  Future<void> signInWithYouVersion() => _youVersion();
}
