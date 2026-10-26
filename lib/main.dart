import 'package:flutter/material.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Register the LiteRT-LM engine once, at startup (flutter_edge_ai's
  // documented setup). This only registers the engine — no model is
  // loaded until generation runs. The Hugging Face token is NOT read
  // here: it is passed per download by the model data layer, from the
  // HF_TOKEN dart-define (see ai_generation/data/flutter_edge_ai_engine.dart).
  await FlutterEdgeAi.initialize(
    inferenceEngines: const [LiteRtLmEngine()],
  );
  runApp(const ProviderScope(child: MyApp()));
}
