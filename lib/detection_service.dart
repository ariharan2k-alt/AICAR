import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tflite/tflite.dart';

class DetectionResult {
  final String label;
  final double confidence;
  final double x;
  final double y;
  final double width;
  final double height;

  DetectionResult({required this.label, required this.confidence, required this.x, required this.y, required this.width, required this.height});

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      label: json['class'] ?? json['label'] ?? 'object',
      confidence: (json['confidence'] is num) ? (json['confidence'] as num).toDouble() : double.parse(json['confidence'].toString()),
      x: (json['x'] is num) ? (json['x'] as num).toDouble() : double.parse(json['x'].toString()),
      y: (json['y'] is num) ? (json['y'] as num).toDouble() : double.parse(json['y'].toString()),
      width: (json['width'] is num) ? (json['width'] as num).toDouble() : double.parse(json['width'].toString()),
      height: (json['height'] is num) ? (json['height'] as num).toDouble() : double.parse(json['height'].toString()),
    );
  }
}

class DetectionService {
  /// Calls Roboflow Detect API. [model] is the model id (e.g. "my-model"), [version] optional (e.g. "1")
  /// Provide [apiKey] (Roboflow API key). Returns list of DetectionResult.
  static Future<List<DetectionResult>> detectWithRoboflow({required File imageFile, required String apiKey, required String model, String? version}) async {
    final endpoint = version == null || version.isEmpty ? 'https://detect.roboflow.com/$model' : 'https://detect.roboflow.com/$model/$version';
    final uri = Uri.parse(endpoint).replace(queryParameters: {'api_key': apiKey});

    final req = http.MultipartRequest('POST', uri);
    req.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode != 200) {
      throw Exception('Detection API failed: ${resp.statusCode} ${resp.body}');
    }

    final Map<String, dynamic> body = jsonDecode(resp.body);
    final List<dynamic> preds = body['predictions'] ?? body['predictions'] ?? [];

    return preds.map((p) => DetectionResult.fromJson(p as Map<String, dynamic>)).toList();
  }

  /// On-device detection using the `tflite` plugin.
  ///
  /// - `modelAsset` should be the asset path added in pubspec (e.g. "assets/model.tflite").
  /// - `labelsAsset` is optional (e.g. "assets/labels.txt").
  /// This method loads the model, runs detection on the provided image file,
  /// and maps plugin results to `DetectionResult`.
  static Future<List<DetectionResult>> detectWithTflite({required File imageFile, required String modelAsset, String? labelsAsset, double threshold = 0.5, int numResultsPerClass = 5}) async {
    try {
      await Tflite.close();
      await Tflite.loadModel(model: modelAsset, labels: labelsAsset ?? "");

      final List<dynamic>? recognitions = await Tflite.detectObjectOnImage(
        path: imageFile.path,
        model: "SSDMobileNet",
        threshold: threshold,
        numResultsPerClass: numResultsPerClass,
      );

      if (recognitions == null) return [];

      final results = recognitions.map((r) {
        final rect = r['rect'] ?? {};
        final label = (r['detectedClass'] ?? r['label'])?.toString() ?? 'object';
        final confidence = (r['confidence'] is num) ? (r['confidence'] as num).toDouble() : double.tryParse(r['confidence'].toString()) ?? 0.0;

        double x = 0, y = 0, w = 0, h = 0;
        if (rect is Map) {
          x = (rect['x'] is num) ? (rect['x'] as num).toDouble() : double.tryParse(rect['x']?.toString() ?? '0') ?? 0.0;
          y = (rect['y'] is num) ? (rect['y'] as num).toDouble() : double.tryParse(rect['y']?.toString() ?? '0') ?? 0.0;
          w = (rect['w'] is num) ? (rect['w'] as num).toDouble() : double.tryParse(rect['w']?.toString() ?? '0') ?? 0.0;
          h = (rect['h'] is num) ? (rect['h'] as num).toDouble() : double.tryParse(rect['h']?.toString() ?? '0') ?? 0.0;
        }

        return DetectionResult(label: label, confidence: confidence, x: x, y: y, width: w, height: h);
      }).toList();

      await Tflite.close();
      return results;
    } catch (e) {
      await Tflite.close();
      rethrow;
    }
  }
}
