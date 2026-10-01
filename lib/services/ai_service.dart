import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_KEY');
  static const String _failMessage =
      "Waan ka xunnahay, turjumaadii waa fashilantay.";

  // Translations kept in memory so revisiting a movie is instant.
  static final Map<int, String> _cache = {};

  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash-lite',
    apiKey: _apiKey,
  );

  Future<String> translateToSomali(int movieId, String englishText) async {
    if (englishText.isEmpty) return "Faahfaahin lagama hayo filimkan.";

    final cached = _cache[movieId];
    if (cached != null) return cached;

    if (_apiKey.isEmpty) return "Turjumaadda ma shaqeynayso (key lama helin).";

    final prompt = '''
    Doorkaaga: Waxaad tahay khabiir turjumaada filimada.
    Hawshaada: U turjun nuxurka filimkan luuqada Soomaaliga.

    Xeerka muhiimka ah: Ha qorin wax hordhac ah ama hadal dheeraad ah. Kaliya soo saar qoraalka la turjumay oo keliya.

    Qoraalka: "$englishText"
  ''';

    try {
      final response = await _model
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 20));

      final result = response.text?.trim();
      if (result == null || result.isEmpty) return _failMessage;

      _cache[movieId] = result; // only successful translations are cached
      return result;
    } catch (_) {
      return _failMessage;
    }
  }
}