import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:developer';

import '../auth/login_screen.dart';
import '../controller/app_controller.dart';
import '../controller/unified_detection.dart'; // 🔥 NEW
import 'home_screen.dart';
import 'on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _rotateController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Rotate animation
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      _rotateController,
    );

    // Start animations
    _logoController.forward().then((_) {
      _textController.forward();
      _progressController.forward();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize app controller
      final appController = context.read<AppController>();
      await appController.initializeApp();

      // 🔥 NEW: Initialize Hybrid detection controller
      final detectionController = context.read<UnifiedDetectionController>();
      // Controller auto-initializes in constructor

      // Wait for animations to complete
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      // Check authentication status
      final user = FirebaseAuth.instance.currentUser;
      final isFirstLaunch = appController.isFirstLaunch;

      log("🔍 Auth Check - User: ${user?.email ?? 'null'}, First Launch: $isFirstLaunch");

      Widget nextScreen;

      if (user != null) {
        // ✅ User is authenticated → Go to HomeScreen
        log("✅ Navigating to HomeScreen");
        nextScreen = const HomeScreen();
      } else if (isFirstLaunch) {
        // ✅ First time app launch → Onboarding
        log("✅ Navigating to OnboardingScreen");
        nextScreen = const OnboardingScreen();
      } else {
        // ✅ Not authenticated & not first launch → Login
        log("✅ Navigating to LoginScreen");
        nextScreen = const LoginScreen();
      }

      // Navigate to the determined screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      log("❌ Error initializing app: $e");
      if (mounted) {
        _showErrorDialog('Failed to initialize app: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 12),
            Text('Initialization Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF1B5E20),
              Color(0xFF66BB6A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            ...List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return Positioned(
                    top: 100.0 + (index * 80),
                    left: (MediaQuery.of(context).size.width / 5) * index,
                    child: Transform.rotate(
                      angle: _rotate.value + (index * 0.5),
                      child: Container(
                        width: 100 + (index * 20.0),
                        height: 100 + (index * 20.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(35),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.eco,
                                    size: 70,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    right: 20,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.psychology,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Animated Text
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _textSlide.value),
                          child: FadeTransition(
                            opacity: _textFade,
                            child: Column(
                              children: [
                                const Text(
                                  'Plant Doctor',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Hybrid AI Detection',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 80),

                    // Loading Progress
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Column(
                          children: [
                            SizedBox(
                              width: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _progressController.value,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading PlantVillage Model...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Version Info
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        Text(
                          'v1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PlantVillage Dataset • 38 Classes',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}