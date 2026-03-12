import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  final String _apiKey = dotenv.env['GEMINI_KEY'] ?? '';
  late final GenerativeModel _model;

  AiService() {
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  Future<String> translateToSomali(String englishText) async {
    if (englishText.isEmpty) return "Faahfaahin lagama hayo filimkan.";

    final prompt =
        '''
    Doorkaaga: Waxaad tahay khabiir turjumaada filimada.
    Hawshaada: U turjun nuxurka filimkan luuqada Soomaaliga.
    
    Xeerka muhiimka ah: Ha qorin wax hordhac ah ama hadal dheeraad ah. Kaliya soo saar qoraalka la turjumay oo keliya.
    
    Qoraalka: "$englishText"
  ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      return response.text?.trim() ??
          "Waan ka xunnahay, turjumaadii waa fashilantay.";
    } catch (e) {
      return "Cillad ayaa dhacday: \n$e";
    }
  }
}
