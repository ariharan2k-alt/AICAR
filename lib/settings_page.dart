import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';
import 'vehicle_details_page.dart';

class SettingsPage extends StatefulWidget {
  final String username;
  final String carModel;
  final String plate;

  const SettingsPage({super.key, required this.username, required this.carModel, required this.plate});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _email;
  late String _username;
  late String _carModel;
  late String _plate;

  @override
  void initState() {
    super.initState();
    _email = FirebaseAuth.instance.currentUser?.email;
    _username = widget.username;
    _carModel = widget.carModel;
    _plate = widget.plate;
  }

  Future<void> _removeProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Profile'),
        content: const Text('This will delete your account from this device (may require recent login). Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (err) {
      // If delete fails (requires recent auth), fall back to sign out.
      await FirebaseAuth.instance.signOut();
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return '';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 375.0).clamp(0.85, 1.15).toDouble();

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop({'username': _username, 'carModel': _carModel, 'plate': _plate});
        return false;
      },
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(''),
        automaticallyImplyLeading: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop({'username': _username, 'carModel': _carModel, 'plate': _plate}),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180 * scale,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF5B7CFA), Color(0xFF7AC7FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                ),
                Positioned(
                  left: 16 * scale,
                  bottom: -36 * scale,
                  child: CircleAvatar(
                    radius: 36 * scale,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 32 * scale,
                      backgroundColor: Colors.grey.shade300,
                      child: Text(_initials(_username), style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 48 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_username, style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.w700)),
                  SizedBox(height: 6 * scale),
                  Text(_email ?? '${_username.toLowerCase().replaceAll(' ', '.')}@example.com', style: TextStyle(color: Colors.grey[700], fontSize: 14 * scale)),
                  SizedBox(height: 18 * scale),

                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: const Text('Edit Profile'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final res = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditProfilePage(username: _username)));
                            if (res is Map && res['username'] != null) {
                              setState(() => _username = res['username']);
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.directions_car_outlined),
                          title: const Text('Vehicle Details'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final res = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => VehicleDetailsPage(carModel: _carModel, plate: _plate)));
                            if (res is Map) {
                              setState(() {
                                if (res['carModel'] != null) _carModel = res['carModel'];
                                if (res['plate'] != null) _plate = res['plate'];
                              });
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.settings_outlined),
                          title: const Text('Settings'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to deeper settings
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16 * scale),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red.shade700,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14 * scale),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _signOut,
                      icon: const Icon(Icons.power_settings_new),
                      label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quick action (optional)
        },
        child: const Icon(Icons.edit),
      ),
    ),
    );
  }
}
