import 'package:flutter/material.dart';

class VehicleDetailsPage extends StatefulWidget {
  final String carModel;
  final String plate;

  const VehicleDetailsPage({super.key, required this.carModel, required this.plate});

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  late TextEditingController _carCtrl;
  late TextEditingController _plateCtrl;

  @override
  void initState() {
    super.initState();
    _carCtrl = TextEditingController(text: widget.carModel);
    _plateCtrl = TextEditingController(text: widget.plate);
  }

  @override
  void dispose() {
    _carCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop({'carModel': _carCtrl.text.trim(), 'plate': _plateCtrl.text.trim()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _carCtrl, decoration: const InputDecoration(labelText: 'Car Model')),
            const SizedBox(height: 12),
            TextField(controller: _plateCtrl, decoration: const InputDecoration(labelText: 'Plate Number')),
            const SizedBox(height: 20),
            Row(children: [Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Save')))]),
          ],
        ),
      ),
    );
  }
}
