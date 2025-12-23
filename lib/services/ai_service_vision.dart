// // lib/core/services/ai_service_vision.dart
// import 'dart:io';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../models/deed.dart';
//
// class AIService {
//   static const String _visionApiKey = 'YOUR_VISION_API_KEY'; // Replace with your actual API key
//   static const String _visionApiUrl = 'https://vision.googleapis.com/v1/images:annotate';
//
//   Future<DeedType?> recognizeImage(File imageFile) async {
//     try {
//       // Convert image to base64
//       final bytes = await imageFile.readAsBytes();
//       final base64Image = base64Encode(bytes);
//
//       // Prepare the request to Vision API
//       final response = await http.post(
//         Uri.parse('$_visionApiUrl?key=$_visionApiKey'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'requests': [
//             {
//               'image': {'content': base64Image},
//               'features': [
//                 {'type': 'LABEL_DETECTION', 'maxResults': 10},
//                 {'type': 'OBJECT_LOCALIZATION', 'maxResults': 10}
//               ]
//             }
//           ]
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         return _parseVisionResponse(responseData);
//       } else {
//         print('Vision API error: ${response.statusCode} - ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       print('Error calling Vision API: $e');
//       return null;
//     }
//   }
//
//   DeedType? _parseVisionResponse(Map<String, dynamic> responseData) {
//     try {
//       final responses = responseData['responses'][0];
//       final labels = responses['labelAnnotations']?.map<String>((label) => label['description'].toString().toLowerCase()).toList() ?? [];
//       final objects = responses['localizedObjectAnnotations']?.map<String>((obj) => obj['name'].toString().toLowerCase()).toList() ?? [];
//
//       final allDetections = [...labels, ...objects];
//
//       // Check for blood donation related terms
//       if (allDetections.any((detection) => detection.contains('blood') ||
//           detection.contains('donation') ||
//           detection.contains('medical') ||
//           detection.contains('hospital'))) {
//         return DeedType.bloodDonation;
//       }
//
//       // Check for tree plantation related terms
//       if (allDetections.any((detection) => detection.contains('tree') ||
//           detection.contains('plant') ||
//           detection.contains('garden') ||
//           detection.contains('forest'))) {
//         return DeedType.treePlantation;
//       }
//
//       // Check for waste cleaning related terms
//       if (allDetections.any((detection) => detection.contains('waste') ||
//           detection.contains('trash') ||
//           detection.contains('garbage') ||
//           detection.contains('clean') ||
//           detection.contains('dustbin'))) {
//         return DeedType.wasteCleaning;
//       }
//
//       return null;
//     } catch (e) {
//       print('Error parsing vision response: $e');
//       return null;
//     }
//   }
// }