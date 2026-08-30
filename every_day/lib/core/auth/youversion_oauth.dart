import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PkcePair {
  const PkcePair({required this.verifier, required this.challenge});

  final String verifier;
  final String challenge;
}

PkcePair generatePkcePair([Random? random]) {
  final source = random ?? Random.secure();
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  final verifier = List.generate(
    64,
    (_) => chars[source.nextInt(chars.length)],
  ).join();
  final challenge = base64Url
      .encode(sha256.convert(utf8.encode(verifier)).bytes)
      .replaceAll('=', '');
  return PkcePair(verifier: verifier, challenge: challenge);
}

String randomOAuthValue([Random? random, int length = 32]) {
  final source = random ?? Random.secure();
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
  return List.generate(length, (_) => chars[source.nextInt(chars.length)]).join();
}

Uri youVersionAuthorizeUri({
  required String clientId,
  required String redirectUri,
  required String state,
  required String nonce,
  required String codeChallenge,
  required bool requireUserInteraction,
}) {
  return Uri.parse(YouVersionAuthorizePaths.authorize).replace(
    queryParameters: {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': 'openid profile email',
      'nonce': nonce,
      'state': state,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      if (requireUserInteraction) 'require_user_interaction': 'true',
    },
  );
}

Uri youVersionStateReplayUri(String state) {
  return Uri.parse(YouVersionAuthorizePaths.callback).replace(
    queryParameters: {'state': state},
  );
}

abstract final class YouVersionAuthorizePaths {
  static const authorize = 'https://api.youversion.com/auth/authorize';
  static const callback = 'https://api.youversion.com/auth/callback';
}
