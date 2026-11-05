import 'package:flutter/foundation.dart';

/// Personal development builds only. Public builds must never embed API keys.
class AiConstants {
  static const geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const geminiModel = 'gemini-2.5-flash-lite';
  static String get geminiApiKey =>
      kReleaseMode ? '' : const String.fromEnvironment('GEMINI_API_KEY');
}
