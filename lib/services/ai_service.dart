import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_KEY');

  Future<String> translateToSomali(String englishText) async {
    if (englishText.isEmpty) return "Faahfaahin lagama hayo filimkan.";
    if (_apiKey.isEmpty) return "Turjumaadda ma shaqeynayso (key lama helin).";

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
    final prompt = '''
    Doorkaaga: Waxaad tahay khabiir turjumaada filimada.
    Hawshaada: U turjun nuxurka filimkan luuqada Soomaaliga.

    Xeerka muhiimka ah: Ha qorin wax hordhac ah ama hadal dheeraad ah. Kaliya soo saar qoraalka la turjumay oo keliya.

    Qoraalka: "$englishText"
  ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ??
          "Waan ka xunnahay, turjumaadii waa fashilantay.";
    } catch (_) {
      return "Waan ka xunnahay, turjumaadii waa fashilantay.";
    }
  }
}