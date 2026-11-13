import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'edge_ai_engine.dart';
import 'flutter_edge_ai_engine.dart';

/// The [EdgeAiEngine] that generates through the app's backend proxy
/// instead of an on-device model.
///
/// The proxy (a Cloudflare Worker in the reference setup) holds the
/// Groq API key server-side and exposes two endpoints:
///
/// - `GET <PROXY_URL>/health` → 200 when the service is up.
/// - `POST <PROXY_URL>/generate` with
///   `{"prompt": ..., "maxTokens": ...}` and an `x-app-token`
///   header → 200 with `{"text": ...}`.
///
/// Configuration comes only from compile-time environment, the same
/// `--dart-define` pattern the app previously used for `HF_TOKEN`:
///
/// - `--dart-define=PROXY_URL=https://<worker>.workers.dev`
/// - `--dart-define=APP_TOKEN=<the proxy's shared token>`
///
/// Never hard-code the URL or the token here. A build without both
/// defines reads as "service not configured" (`isModelReady` false,
/// `generateText` throws [EngineNoActiveModelException]) — the app
/// routes that to the missing-model state instead of crashing.
///
/// The prompts, parsers and repository above this seam are
/// unchanged: they only see the reply text this engine yields.
/// [deleteModel] is the one place that still touches the retired
/// on-device runtime — it removes the legacy model file, if one is
/// still on the device, so Settings can free that storage.
class ProxyGenerationEngine implements EdgeAiEngine {
  const ProxyGenerationEngine({
    this.proxyUrl = _defaultProxyUrl,
    this.appToken = _defaultAppToken,
    this.client,
  });

  static const String _defaultProxyUrl = String.fromEnvironment('PROXY_URL');
  static const String _defaultAppToken = String.fromEnvironment('APP_TOKEN');

  /// The proxy base URL (trailing slashes are stripped when used).
  /// Empty when the build defines no `PROXY_URL`.
  final String proxyUrl;

  /// The shared token the proxy requires on every call. Empty when
  /// the build defines no `APP_TOKEN`.
  final String appToken;

  /// Injected client (tests). Null in production, where each call
  /// builds and owns its own client.
  final http.Client? client;

  /// Health probes must answer quickly: a slow proxy reads as
  /// "not configured" rather than stalling the UI.
  static const Duration _healthTimeout = Duration(seconds: 10);

  /// Generations are long (a full deck or quiz from the proxy);
  /// 120s bounds the slowest case without cutting one off.
  static const Duration _generateTimeout = Duration(seconds: 120);

  /// The service is configured only when both defines are present.
  bool get _configured => proxyUrl.isNotEmpty && appToken.isNotEmpty;

  String get _baseUrl => proxyUrl.replaceAll(RegExp(r'/+$'), '');

  @override
  Future<bool> isModelReady() async {
    if (!_configured) return false;
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(_healthTimeout);
      return response.statusCode == 200;
    } catch (_) {
      // No connectivity, a timeout, a proxy error — all read as
      // "not ready", never as a throw (see the seam contract).
      return false;
    } finally {
      if (client == null) httpClient.close();
    }
  }

  @override
  Future<bool> isModelInstalled() => isModelReady();

  /// There is no download anymore: the "model" is the configured
  /// service, and it is ready as soon as the health probe passes.
  /// Completes immediately so the retired download flow (which
  /// nothing calls anymore) has nothing to wait on.
  @override
  Stream<double> downloadModel() => Stream.value(1.0);

  /// Removes the legacy on-device model file, if one is still on
  /// this device, through the retired engine. Best-effort only: a
  /// missing file — or no plugin at all, on the host — is not a
  /// failure, and this never throws.
  @override
  Future<void> deleteModel() async {
    try {
      await const FlutterEdgeAiEngine().deleteModel();
    } catch (_) {
      // Nothing to delete, or already gone.
    }
  }

  @override
  Stream<String> generateText(String prompt, {int maxOutputTokens = 1024}) {
    late final StreamController<String> controller;
    final httpClient = client ?? http.Client();
    // Closing the client aborts an in-flight request, so the
    // stream's cancellation really stops generation; it also
    // releases the connection when the call finishes. An injected
    // client (tests) is closed the same way — it is never reused.
    var clientClosed = false;
    void closeClient() {
      if (!clientClosed) {
        clientClosed = true;
        httpClient.close();
      }
    }

    Future<void> run() async {
      try {
        if (!_configured) {
          throw const EngineNoActiveModelException();
        }
        final response = await httpClient
            .post(
              Uri.parse('$_baseUrl/generate'),
              headers: {
                'Content-Type': 'application/json',
                'x-app-token': appToken,
              },
              body: jsonEncode({
                'prompt': prompt,
                'maxTokens': maxOutputTokens,
              }),
            )
            .timeout(_generateTimeout);
        if (controller.isClosed) return;
        switch (response.statusCode) {
          case 200:
            final text = _textFrom(response.body);
            if (text == null) {
              throw const EngineGenerationException(
                'The AI service returned an unexpected response.',
              );
            }
            _logReplyDetails(response.body);
            controller.add(text);
          case 400:
            throw const EngineGenerationException(
              'The AI service rejected the request.',
            );
          case 401:
            throw const EngineGenerationException(
              'proxy unauthorized / app token rejected',
            );
          case 429:
            throw const EngineGenerationException(
              'The AI service is rate-limiting requests right now. '
              'Try again in a bit.',
            );
          default:
            if (response.statusCode >= 500) {
              throw const EngineGenerationException(
                'The AI service is unavailable or overloaded right '
                'now. Try again later.',
              );
            }
            throw EngineGenerationException(
              'The AI service failed (HTTP ${response.statusCode}).',
            );
        }
      } on EngineNoActiveModelException {
        if (!controller.isClosed) {
          controller.addError(const EngineNoActiveModelException());
        }
      } on EngineGenerationException catch (e) {
        if (!controller.isClosed) controller.addError(e);
      } on TimeoutException {
        if (!controller.isClosed) {
          controller.addError(const EngineGenerationException(_noConnection));
        }
      } on SocketException {
        if (!controller.isClosed) {
          controller.addError(const EngineGenerationException(_noConnection));
        }
      } on http.ClientException {
        if (!controller.isClosed) {
          controller.addError(const EngineGenerationException(_noConnection));
        }
      } catch (error) {
        if (!controller.isClosed) {
          controller.addError(EngineGenerationException(error.toString()));
        }
      } finally {
        closeClient();
        if (!controller.isClosed) await controller.close();
      }
    }

    controller = StreamController<String>(onListen: run, onCancel: closeClient);
    return controller.stream;
  }

  /// No connection to the service (offline, or the proxy did not
  /// answer in time). Shared by the timeout and transport catches
  /// so the wording stays identical.
  static const String _noConnection =
      'No connection to the AI service. Check your internet '
      'connection and try again.';

  /// The proxy's `{"text": ...}` reply, or null when the body is
  /// not JSON or carries no text string.
  String? _textFrom(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        final text = data['text'];
        return text is String ? text : null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Diagnostic logging for the 2026-11-13 truncation bug: gpt-oss
  /// spends part of the token budget on hidden reasoning, so a reply
  /// can be cut off mid-item. The proxy passes Groq's finish reason
  /// and token usage through; "length" means the budget ran out,
  /// "stop" means the model ended the turn itself, and
  /// `reasoning_tokens` shows what the hidden reasoning consumed.
  /// Debug builds only. Safe to remove once generation is proven
  /// on device.
  void _logReplyDetails(String body) {
    try {
      final data = jsonDecode(body);
      if (data is! Map<String, dynamic>) return;
      final finishReason = data['finish_reason'];
      final usage = data['usage'];
      var detail = '';
      if (usage is Map<String, dynamic>) {
        final completion = usage['completion_tokens'];
        final details = usage['completion_tokens_details'];
        final reasoning = details is Map<String, dynamic>
            ? details['reasoning_tokens']
            : null;
        detail =
            ' completionTokens=$completion reasoningTokens=$reasoning';
      }
      debugPrint(
        '[SI Buddy] PROXY REPLY finish_reason=$finishReason$detail',
      );
    } catch (_) {
      // A malformed body is already handled by _textFrom; never let
      // diagnostic logging break generation.
    }
  }
}
