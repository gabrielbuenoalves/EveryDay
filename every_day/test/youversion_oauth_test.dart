import 'package:every_day/core/auth/youversion_oauth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gera PKCE S256 sem padding', () {
    final pair = generatePkcePair();
    expect(pair.verifier.length, 64);
    expect(pair.challenge.contains('='), isFalse);
    expect(pair.challenge, isNot(pair.verifier));
  });

  test('authorize usa só scopes OIDC e PKCE', () {
    final uri = youVersionAuthorizeUri(
      clientId: 'app-key',
      redirectUri: 'everyday://youversion-auth',
      state: 'state-1',
      nonce: 'nonce-1',
      codeChallenge: 'challenge-1',
      requireUserInteraction: true,
    );
    expect(uri.path, '/auth/authorize');
    expect(uri.queryParameters['scope'], 'openid profile email');
    expect(uri.queryParameters['code_challenge_method'], 'S256');
    expect(uri.queryParameters['require_user_interaction'], 'true');
    expect(uri.queryParameters.containsKey('requested_permissions[]'), isFalse);
  });

  test('segundo hop reenvia só o state', () {
    final uri = youVersionStateReplayUri('state-1');
    expect(uri.path, '/auth/callback');
    expect(uri.queryParameters, {'state': 'state-1'});
  });
}
