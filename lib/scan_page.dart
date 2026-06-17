import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'detection_service.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _imageFile;
  ui.Image? _imageInfo;
  List<DetectionResult> _predictions = [];
  bool _loading = false;

  // Roboflow settings (user must provide their own values)
  final TextEditingController _apiKeyCtrl = TextEditingController();
  final TextEditingController _modelCtrl = TextEditingController(text: 'your-model');
  final TextEditingController _versionCtrl = TextEditingController(text: '1');

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _modelCtrl.dispose();
    _versionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource src) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: src, maxWidth: 1600);
    if (picked == null) return;

    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final decoded = await decodeImageFromList(bytes);

    setState(() {
      _imageFile = file;
      _imageInfo = decoded;
      _predictions = [];
    });
  }

  Future<void> _detect() async {
    if (_imageFile == null) return;
    final apiKey = _apiKeyCtrl.text.trim();
    final model = _modelCtrl.text.trim();
    final version = _versionCtrl.text.trim();
    if (apiKey.isEmpty || model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter Roboflow API key and model')));
      return;
    }

    setState(() => _loading = true);
    try {
      final preds = await DetectionService.detectWithRoboflow(imageFile: _imageFile!, apiKey: apiKey, model: model, version: version.isEmpty ? null : version);
      setState(() => _predictions = preds);
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Detection failed: ${err.toString()}')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scale = (size.width / 375.0).clamp(0.85, 1.15).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Damage Scan')),
      body: Padding(
        padding: EdgeInsets.all(12 * scale),
        child: Column(
          children: [
            // Roboflow inputs
            TextField(controller: _apiKeyCtrl, decoration: const InputDecoration(labelText: 'Roboflow API Key')),
            Row(children: [Expanded(child: TextField(controller: _modelCtrl, decoration: const InputDecoration(labelText: 'Model'))), SizedBox(width: 8 * scale), SizedBox(width: 80 * scale, child: TextField(controller: _versionCtrl, decoration: const InputDecoration(labelText: 'Ver')))]),
            SizedBox(height: 12 * scale),

            // Image area
            Expanded(
              child: Center(
                child: _imageFile == null
                    ? Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.camera_alt, size: 72 * scale, color: Colors.blueAccent), SizedBox(height: 8 * scale), const Text('Pick or take a photo of the damaged area')])
                    : LayoutBuilder(builder: (context, constraints) {
                        final displayWidth = constraints.maxWidth;
                        final imgW = _imageInfo?.width ?? 1;
                        final imgH = _imageInfo?.height ?? 1;
                        final scaleFit = (displayWidth / imgW).clamp(0.0, 1e6).toDouble();
                        final displayHeight = imgH * scaleFit;

                        return SizedBox(
                          width: displayWidth,
                          height: displayHeight,
                          child: Stack(children: [Image.file(_imageFile!, width: displayWidth, height: displayHeight, fit: BoxFit.cover), CustomPaint(size: Size(displayWidth, displayHeight), painter: _BoxPainter(predictions: _predictions, imageSize: Size(imgW.toDouble(), imgH.toDouble())))]),
                        );
                      }),
              ),
            ),

            // Controls
            if (_loading) const LinearProgressIndicator(),
            SizedBox(height: 8 * scale),
            Row(children: [Expanded(child: ElevatedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera), label: const Text('Camera'))), SizedBox(width: 8 * scale), Expanded(child: ElevatedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo), label: const Text('Gallery')))]),
            SizedBox(height: 8 * scale),
            Row(children: [Expanded(child: ElevatedButton(onPressed: _detect, child: const Text('Detect')))]),
          ],
        ),
      ),
    );
  }
}

class _BoxPainter extends CustomPainter {
  final List<DetectionResult> predictions;
  final Size imageSize;

  _BoxPainter({required this.predictions, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = Colors.redAccent;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final p in predictions) {
      double x = p.x;
      double y = p.y;
      double w = p.width;
      double h = p.height;

      // If coordinates look normalized (<=1), convert to pixels
      if (x <= 1 && y <= 1 && w <= 1 && h <= 1) {
        x *= imageSize.width;
        y *= imageSize.height;
        w *= imageSize.width;
        h *= imageSize.height;
      }

      // Roboflow returns center x,y — convert to top-left
      final left = (x - w / 2) / imageSize.width * size.width;
      final top = (y - h / 2) / imageSize.height * size.height;
      final boxW = w / imageSize.width * size.width;
      final boxH = h / imageSize.height * size.height;

      final rect = Rect.fromLTWH(left, top, boxW, boxH);
      canvas.drawRect(rect, paint);

      final label = '${p.label} ${(p.confidence * 100).toStringAsFixed(1)}%';
      textPainter.text = TextSpan(text: label, style: const TextStyle(color: Colors.white, fontSize: 12, backgroundColor: Colors.redAccent));
      textPainter.layout(minWidth: 0, maxWidth: boxW);
      textPainter.paint(canvas, Offset(left + 4, top - textPainter.height - 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

