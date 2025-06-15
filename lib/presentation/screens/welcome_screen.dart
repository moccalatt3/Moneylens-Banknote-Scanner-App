import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';
import '../styles/fonts.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  bool _secondGradient = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _logoAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _textAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _secondGradient = true;
      });
    });

    Timer(Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _logoAnimation,
                    child: Image.asset(
                      'assets/images/icons/logo2.png',
                      width: 150,
                    ),
                  ),
                  SizedBox(height: 20),
                  FadeTransition(
                    opacity: _textAnimation,
                    child: AnimatedSwitcher(
                      duration: Duration(seconds: 2),
                      child: ShaderMask(
                        key: ValueKey<bool>(_secondGradient),
                        shaderCallback: (bounds) => LinearGradient(
                          colors: _secondGradient
                              ? [Color(0xFF15AFF7), Color(0xFF021B8C)]
                              : [Color(0xFF3C3D37), Color(0xFF1D201E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text( 
                          "MoneyLens",
                          style: AppFonts.headingStyle.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Teks versi di bawah
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textAnimation,
                child: Text(
                  "version 1.0",
                  textAlign: TextAlign.center,
                  style: AppFonts.versionStyle.copyWith(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
