import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'scan_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _username = 'USER';
  String _carModel = 'Toyota Camry';
  String _plate = 'WXY 1234';

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scale = (size.width / 375.0).clamp(0.85, 1.15).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 20 * scale),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A6BFF), Color(0xFF7B3BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 14 * scale)),
                          SizedBox(height: 6 * scale),
                          Text(_username, style: TextStyle(color: Colors.white, fontSize: 22 * scale, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        onPressed: _logout,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.logout),
                        tooltip: 'LOGOUT',
                      )
                    ],
                  ),
                  SizedBox(height: 14 * scale),
                  GestureDetector(
                    onTap: () async {
                      final res = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsPage(username: _username, carModel: _carModel, plate: _plate)));
                      if (res != null && res is Map) {
                        setState(() {
                          _username = (res['username'] as String?) ?? _username;
                          _carModel = (res['carModel'] as String?) ?? _carModel;
                          _plate = (res['plate'] as String?) ?? _plate;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12 * scale)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_car, color: Colors.white, size: 18 * scale),
                          SizedBox(width: 8 * scale),
                          Text('$_carModel · $_plate', style: TextStyle(color: Colors.white, fontSize: 14 * scale)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 20 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scan card (tap to open ScanPage)
                    Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(18 * scale),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18 * scale),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScanPage())),
                        child: Container(
                          padding: EdgeInsets.all(16 * scale),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18 * scale)),
                          child: Row(
                            children: [
                              Container(
                                width: 56 * scale,
                                height: 56 * scale,
                                decoration: BoxDecoration(color: const Color(0xFFF3F5F9), borderRadius: BorderRadius.circular(12 * scale)),
                                child: Icon(Icons.camera_alt, color: Colors.blueAccent),
                              ),
                              SizedBox(width: 12 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Scan Damage', style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 6 * scale),
                                    Text('AI Analysis & Cost Estimate', style: TextStyle(color: Colors.black54)),
                                  ],
                                ),
                              ),
                              Container(
                                width: 44 * scale,
                                height: 44 * scale,
                                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), shape: BoxShape.circle),
                                child: Icon(Icons.arrow_forward, color: const Color(0xFF4A6BFF)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 18 * scale),

                    // Center card
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12 * scale),
                      child: Container(
                        padding: EdgeInsets.all(12 * scale),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12 * scale)),
                        child: Row(
                          children: [
                            Container(
                              width: 64 * scale,
                              height: 64 * scale,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8 * scale), color: const Color(0xFFF3F5F9)),
                              child: Icon(Icons.business, color: Colors.blueAccent),
                            ),
                            SizedBox(width: 12 * scale),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text('AI CarCare Center', style: TextStyle(fontWeight: FontWeight.w600))),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                                        decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8 * scale)),
                                        child: Row(
                                          children: [
                                            Icon(Icons.star, color: Colors.green, size: 14 * scale),
                                            SizedBox(width: 4 * scale),
                                            Text('4.8', style: TextStyle(color: Colors.green[700])),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6 * scale),
                                  Text('1.2km · Paint, Dents, Engine', style: TextStyle(color: Colors.black54, fontSize: 12 * scale)),
                                  SizedBox(height: 6 * scale),
                                  Text('Open Now', style: TextStyle(color: Colors.green, fontSize: 12 * scale)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20 * scale),
                    Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16 * scale)),
                    SizedBox(height: 8 * scale),
                    // Placeholder for activities
                    Container(height: 80 * scale, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12 * scale)), alignment: Alignment.center, child: Text('No recent activity', style: TextStyle(color: Colors.black45))),
                    SizedBox(height: 80 * scale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF7B3BFF),
        child: const Icon(Icons.edit),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) async {
          if (i == 2) {
            final res = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsPage(username: _username, carModel: _carModel, plate: _plate)));
            if (res != null && res is Map) {
              setState(() {
                _username = (res['username'] as String?) ?? _username;
                _carModel = (res['carModel'] as String?) ?? _carModel;
                _plate = (res['plate'] as String?) ?? _plate;
              });
            }
            return;
          }
          setState(() => _currentIndex = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
