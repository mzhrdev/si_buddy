import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:si_buddy/features/ai_generation/data/edge_ai_engine.dart';
import 'package:si_buddy/features/ai_generation/data/proxy_generation_engine.dart';

/// Unit tests for the proxy engine, over a fake HTTP client: no
/// network, no dart-defines. The engine under test is always built
/// with an explicit proxy URL + token, except for the unconfigured
/// case, which uses the bare `const ProxyGenerationEngine()` — the
/// test run defines no PROXY_URL/APP_TOKEN, so that reads exactly
/// like a build without them.

const _proxyUrl = 'https://proxy.test';
const _appToken = 'test-app-token';

ProxyGenerationEngine _engine(http.Client client) => ProxyGenerationEngine(
  proxyUrl: _proxyUrl,
  appToken: _appToken,
  client: client,
);

/// A client whose request never answers on its own: the only way
/// the in-flight call ends is the engine closing the client.
class _HangingClient extends http.BaseClient {
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return Completer<http.StreamedResponse>().future;
  }

  @override
  void close() {
    closed = true;
    super.close();
  }
}

void main() {
  test('unconfigured engine is not ready; generateText throws '
      'EngineNoActiveModelException', () async {
    const engine = ProxyGenerationEngine();
    expect(await engine.isModelReady(), isFalse);
    expect(await engine.isModelInstalled(), isFalse);
    await expectLater(
      engine.generateText('prompt'),
      emitsError(isA<EngineNoActiveModelException>()),
    );
  });

  test('downloadModel completes immediately (nothing to download)', () async {
    const engine = ProxyGenerationEngine();
    await expectLater(engine.downloadModel(), emits(1.0));
  });

  test('health 200 means ready', () async {
    final engine = _engine(
      MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$_proxyUrl/health');
        return http.Response('', 200);
      }),
    );
    expect(await engine.isModelReady(), isTrue);
    expect(await engine.isModelInstalled(), isTrue);
  });

  test('health non-200 means not ready', () async {
    final engine = _engine(MockClient((_) async => http.Response('down', 503)));
    expect(await engine.isModelReady(), isFalse);
  });

  test('health throwing means not ready', () async {
    final engine = _engine(
      MockClient((_) async => throw http.ClientException('no route')),
    );
    expect(await engine.isModelReady(), isFalse);
  });

  test('generate 200 yields the proxy text as one chunk', () async {
    const prompt = 'Make 2 flashcards about cells.';
    final engine = _engine(
      MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), '$_proxyUrl/generate');
        expect(request.headers['x-app-token'], _appToken);
        expect(request.headers['Content-Type'], contains('application/json'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['prompt'], prompt);
        expect(body['maxTokens'], 512);
        return http.Response(
          jsonEncode({'text': 'Q: What is a cell?\nA: The basic unit.'}),
          200,
        );
      }),
    );
    await expectLater(
      engine.generateText(prompt, maxOutputTokens: 512),
      emits('Q: What is a cell?\nA: The basic unit.'),
    );
  });

  test('generate 401 maps to the unauthorized exception', () async {
    final engine = _engine(MockClient((_) async => http.Response('nope', 401)));
    await expectLater(
      engine.generateText('prompt'),
      emitsError(
        isA<EngineGenerationException>().having(
          (e) => e.message,
          'message',
          contains('app token rejected'),
        ),
      ),
    );
  });

  test('generate 429 maps to rate limiting', () async {
    final engine = _engine(
      MockClient((_) async => http.Response('slow down', 429)),
    );
    await expectLater(
      engine.generateText('prompt'),
      emitsError(
        isA<EngineGenerationException>().having(
          (e) => e.message,
          'message',
          contains('rate-limiting'),
        ),
      ),
    );
  });

  test('generate 503 maps to unavailable/overloaded', () async {
    final engine = _engine(MockClient((_) async => http.Response('busy', 503)));
    await expectLater(
      engine.generateText('prompt'),
      emitsError(
        isA<EngineGenerationException>().having(
          (e) => e.message,
          'message',
          contains('unavailable or overloaded'),
        ),
      ),
    );
  });

  test('generate 400 maps to a bad request', () async {
    final engine = _engine(MockClient((_) async => http.Response('bad', 400)));
    await expectLater(
      engine.generateText('prompt'),
      emitsError(
        isA<EngineGenerationException>().having(
          (e) => e.message,
          'message',
          contains('rejected the request'),
        ),
      ),
    );
  });

  test('generate 200 without a text field maps to an unexpected '
      'response', () async {
    final engine = _engine(
      MockClient((_) async => http.Response('{"other": 1}', 200)),
    );
    await expectLater(
      engine.generateText('prompt'),
      emitsError(
        isA<EngineGenerationException>().having(
          (e) => e.message,
          'message',
          contains('unexpected response'),
        ),
      ),
    );
  });

  test('generate 200 with a non-JSON body maps to an unexpected '
      'response', () async {
    final engine = _engine(
      MockClient((_) async => http.Response('not json', 200)),
    );
    await expectLater(
      engine.generateText('prompt'),
      emitsError(
        isA<EngineGenerationException>().having(
          (e) => e.message,
          'message',
          contains('unexpected response'),
        ),
      ),
    );
  });

  test('a timeout maps to the no-connection exception', () async {
    final engine = _engine(
      MockClient((_) async => throw TimeoutException('timed out')),
    );
    await expectLater(
      engine.generateText('prompt'),
      emitsError(
        isA<EngineGenerationException>().having(
          (e) => e.message,
          'message',
          contains('No connection to the AI service'),
        ),
      ),
    );
  });

  test('a transport failure maps to the no-connection exception', () async {
    final engine = _engine(
      MockClient((_) async => throw http.ClientException('socket closed')),
    );
    await expectLater(
      engine.generateText('prompt'),
      emitsError(
        isA<EngineGenerationException>().having(
          (e) => e.message,
          'message',
          contains('No connection to the AI service'),
        ),
      ),
    );
  });

  test('cancelling generateText closes the client', () async {
    final client = _HangingClient();
    final engine = ProxyGenerationEngine(
      proxyUrl: _proxyUrl,
      appToken: _appToken,
      client: client,
    );
    final subscription = engine
        .generateText('prompt')
        .listen((_) {}, onError: (_) {});
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await subscription.cancel();
    expect(client.closed, isTrue);
  });
}
