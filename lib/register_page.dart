import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _email = TextEditingController(text: '');
  final TextEditingController _password = TextEditingController(text: '');
  int _selectedTab = 0; // 0 = Car Owner, 1 = Workshop

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide email and password')));
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registered as ${cred.user?.email}')));
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign up failed: ${err.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scale = (size.width / 375.0).clamp(0.85, 1.15).toDouble();
    final headerH = math.min(size.height * 0.40, 320.0) * scale;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Gradient header
              Container(
                height: headerH,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF4A6BFF), Color(0xFF7B3BFF)], begin: Alignment.topCenter, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 84 * scale,
                      height: 84 * scale,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18 * scale)),
                      child: Icon(Icons.handyman, color: Colors.white, size: 40 * scale),
                    ),
                    SizedBox(height: 12 * scale),
                    Text('AI CARCARE', style: TextStyle(color: Colors.white, fontSize: 26 * scale, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6 * scale),
                    Text('Smart Damage Detection', style: TextStyle(color: Colors.white70, fontSize: 14 * scale)),
                  ],
                ),
              ),

              // Card
              Positioned(
                top: headerH - 48 * scale,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(22 * scale),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22 * scale)),
                        padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 20 * scale),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // pill toggle
                            Container(
                              padding: EdgeInsets.all(4 * scale),
                              decoration: BoxDecoration(color: const Color(0xFFF3F5F9), borderRadius: BorderRadius.circular(12 * scale)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedTab = 0),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 10 * scale),
                                        decoration: BoxDecoration(color: _selectedTab == 0 ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8 * scale)),
                                        alignment: Alignment.center,
                                        child: Text('Car Owner', style: TextStyle(color: _selectedTab == 0 ? Colors.blueAccent : Colors.black54, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedTab = 1),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 10 * scale),
                                        decoration: BoxDecoration(color: _selectedTab == 1 ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8 * scale)),
                                        alignment: Alignment.center,
                                        child: Text('Workshop', style: TextStyle(color: _selectedTab == 1 ? Colors.blueAccent : Colors.black54, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 18 * scale),

                            // Email
                            Align(alignment: Alignment.centerLeft, child: Text('EMAIL', style: TextStyle(fontSize: 12 * scale, color: Colors.black54, fontWeight: FontWeight.w600))),
                            SizedBox(height: 8 * scale),
                            Container(
                              decoration: BoxDecoration(color: const Color(0xFFF7F8FB), borderRadius: BorderRadius.circular(12 * scale)),
                              child: Row(
                                children: [
                                  Container(margin: EdgeInsets.all(10 * scale), padding: EdgeInsets.all(8 * scale), decoration: BoxDecoration(color: const Color(0xFFF3F5F9), borderRadius: BorderRadius.circular(8 * scale)), child: Icon(Icons.email_outlined, color: Colors.black45)),
                                  Expanded(child: TextField(controller: _email, decoration: const InputDecoration(border: InputBorder.none, hintText: '@email.com'))),
                                ],
                              ),
                            ),

                            SizedBox(height: 16 * scale),

                            // Password
                            Align(alignment: Alignment.centerLeft, child: Text('PASSWORD', style: TextStyle(fontSize: 12 * scale, color: const Color.fromARGB(136, 0, 0, 0), fontWeight: FontWeight.w600))),
                            SizedBox(height: 8 * scale),
                            Container(
                              decoration: BoxDecoration(color: const Color(0xFFF7F8FB), borderRadius: BorderRadius.circular(12 * scale)),
                              child: Row(
                                children: [
                                  Container(margin: EdgeInsets.all(10 * scale), padding: EdgeInsets.all(8 * scale), decoration: BoxDecoration(color: const Color(0xFFF3F5F9), borderRadius: BorderRadius.circular(8 * scale)), child: Icon(Icons.lock_outline, color: Colors.black45)),
                                  Expanded(child: TextField(controller: _password, obscureText: true, decoration: const InputDecoration(border: InputBorder.none, hintText: 'password'))),
                                ],
                              ),
                            ),

                            SizedBox(height: 22 * scale),

                            // Sign up button
                            SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: _signup,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 14 * scale),
                                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4A6BFF), Color(0xFF7B3BFF)]), borderRadius: BorderRadius.circular(12 * scale), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12 * scale, offset: Offset(0, 6 * scale))]),
                                  child: Center(child: Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 18 * scale, fontWeight: FontWeight.bold))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 14 * scale),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                      },
                      child: const Text("Already have an account? Sign in"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
