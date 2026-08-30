import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/auth/youversion_oauth.dart';
import '../../../core/config/youversion_config.dart';

class YouVersionSignIn {
  YouVersionSignIn(this._client, {YouVersionAuthConfig? config})
    : _config = config ?? YouVersionAuthConfig.fromEnvironment();

  final SupabaseClient _client;
  final YouVersionAuthConfig _config;

  bool get isEnabled => _config.isConfigured;

  Future<void> call() async {
    if (!_config.isConfigured) {
      throw StateError('YouVersion App Key não configurada.');
    }

    final pkce = generatePkcePair();
    final state = randomOAuthValue();
    final nonce = randomOAuthValue();
    final requireInteraction =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    final authorize = youVersionAuthorizeUri(
      clientId: _config.appKey,
      redirectUri: YouVersionAuthConfig.redirectUri,
      state: state,
      nonce: nonce,
      codeChallenge: pkce.challenge,
      requireUserInteraction: requireInteraction,
    );

    final first = await _open(authorize);
    _assertState(first, state);
    _assertNoError(first);

    var callback = first;
    if (!callback.queryParameters.containsKey('code')) {
      callback = await _open(youVersionStateReplayUri(state));
      _assertState(callback, state);
      _assertNoError(callback);
    }

    final code = callback.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw StateError('YouVersion não devolveu o código de autorização.');
    }

    final tokens = await _exchangeCode(code, pkce.verifier);
    final idToken = tokens['id_token'] as String?;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('YouVersion não devolveu o id_token.');
    }

    final session = await _client.functions.invoke(
      'youversion-session',
      body: {'id_token': idToken, 'nonce': nonce},
    );
    if (session.status >= 400) {
      throw StateError('Não foi possível entrar com a YouVersion.');
    }
    final data = Map<String, dynamic>.from(session.data as Map);
    final tokenHash = data['token_hash'] as String?;
    if (tokenHash == null || tokenHash.isEmpty) {
      throw StateError('Sessão YouVersion incompleta.');
    }

    await _client.auth.verifyOTP(
      type: OtpType.magiclink,
      tokenHash: tokenHash,
    );
  }

  Future<Uri> _open(Uri url) async {
    final result = await FlutterWebAuth2.authenticate(
      url: url.toString(),
      callbackUrlScheme: YouVersionAuthConfig.callbackScheme,
    );
    return Uri.parse(result);
  }

  Future<Map<String, dynamic>> _exchangeCode(
    String code,
    String verifier,
  ) async {
    final response = await http.post(
      Uri.parse(YouVersionAuthConfig.tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': YouVersionAuthConfig.redirectUri,
        'client_id': _config.appKey,
        'code_verifier': verifier,
      },
    );
    if (response.statusCode >= 400) {
      throw StateError('Falha ao trocar o código YouVersion.');
    }
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  void _assertState(Uri uri, String expected) {
    final returned = uri.queryParameters['state'];
    if (returned == null || returned != expected) {
      throw StateError('State YouVersion inválido.');
    }
  }

  void _assertNoError(Uri uri) {
    final error = uri.queryParameters['error'];
    if (error == null) return;
    final description = uri.queryParameters['error_description'] ?? '';
    throw StateError('YouVersion: $error $description'.trim());
  }
}
