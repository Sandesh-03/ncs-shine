// lib/services/ai_service.dart
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String apiKey = 'key;

  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 1,
        maxOutputTokens: 50,
      ),
    );
  }

  Future<String?> recognizeImage(File imageFile) async {
    try {
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Create the prompt
      final prompt = TextPart(
        """Analyze this image carefully. Identify if it shows ANY of these charitable activities:

🩸 BLOOD DONATION
Look for: Person donating blood, medical staff, blood bags, IV needles in arm, donation center, Red Cross symbols, bandages on inner elbow, donation certificates, medical equipment

🌳 TREE PLANTATION  
Look for: Planting trees/saplings, digging holes with tools, garden equipment, nursery bags, newly planted trees, watering plants outdoors, seedlings, hands in soil, gardening gloves

🗑️ WASTE CLEANING
Look for: Picking up trash/litter, holding garbage bags, cleaning parks or beaches, sorting recyclables, cleaning gloves, trash bins, litter collection, cleaning equipment, pile of collected waste

INSTRUCTIONS:
- Examine EVERY detail in the image
- Look for context clues (location, equipment, activities)
- Be generous - if it COULD be one of these, classify it
- Consider partial views or indirect evidence

RESPOND WITH EXACTLY ONE OF THESE:
"Blood Donation" OR "Tree Plantation" OR "Waste Cleaning" OR "None"

Your answer (one phrase only):""",
      );

      // Create image part
      final imagePart = DataPart('image/jpeg', imageBytes);

      // Generate content
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      final detectedText = response.text?.toLowerCase().trim() ?? 'none';

      // Parse response
      if (detectedText.contains('blood') || detectedText.contains('donation')) {
        return 'Blood Donation';
      } else if (detectedText.contains('tree') ||
          detectedText.contains('plant')) {
        return 'Tree Plantation';
      } else if (detectedText.contains('waste') ||
          detectedText.contains('clean') ||
          detectedText.contains('trash')) {
        return 'Waste Cleaning';
      } else if (detectedText.contains('none')) {
        return null;
      }

      return null;
    } on GenerativeAIException catch (e) {
      return e.message;
    } catch (e) {
      return null;
    }
  }

  //  Test (API is working)
  Future<void> testAPI() async {
    try {
      final response = await _model.generateContent([
        Content.text('Say "Hello from Gemini!" if you can read this.'),
      ]);
    } catch (e) {}
  }
}
