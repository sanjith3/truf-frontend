import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turfzone/features/auth/otp_login_screen.dart';
import 'package:turfzone/features/home/user_home_screen.dart';
import 'package:turfzone/services/auth_state.dart';
import 'package:turfzone/services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ─── Master timeline: exactly 3000ms ───
  late AnimationController _master;

  // 0.0s–0.4s: logo fade 0→1 + scale 0.92→1.00
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  // 0.8s–2.8s: cinematic 3% zoom push-in
  late Animation<double> _cameraZoom;

  // 1.2s–2.6s: text fade in
  late Animation<double> _textFade;

  // 2.8s–3.0s: content fades out (NOT background)
  late Animation<double> _exitFade;

  // ─── Glow breathing (continuous sine wave) ───
  late AnimationController _glowCtrl;

  // ─── Lightning flicker: 0.6s–1.4s ───
  late AnimationController _flickerCtrl;

  // ─── Dust particles ───
  late AnimationController _dustCtrl;
  final List<_DustParticle> _particles = [];
  final Random _rng = Random();

  // ─── Auth ───
  Widget? _destination;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 20; i++) {
      _particles.add(_DustParticle(_rng));
    }

    // ─── Master: 3000ms ───
    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Logo: 0.0s–0.4s → interval 0.0–0.133
    _logoFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.0, 0.133, curve: Curves.easeOutCubic),
      ),
    );
    _logoScale = Tween(begin: 0.92, end: 1.00).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.0, 0.133, curve: Curves.easeOutCubic),
      ),
    );

    // Camera zoom: 0.8s–2.8s → interval 0.267–0.933
    _cameraZoom = Tween(begin: 1.00, end: 1.03).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.267, 0.933, curve: Curves.easeInOutSine),
      ),
    );

    // Text: 1.2s–2.6s → interval 0.400–0.867
    _textFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.400, 0.867, curve: Curves.easeOutCubic),
      ),
    );

    // Exit: 2.8s–3.0s → interval 0.933–1.0 (content only, not bg)
    _exitFade = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.933, 1.0, curve: Curves.easeIn),
      ),
    );

    // ─── Glow breathing ───
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // ─── Lightning flicker: 0.6s–1.4s ───
    _flickerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // trigger at 0.6s
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _flickerCtrl.forward();
    });

    // ─── Dust ───
    _dustCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // GO
    _master.forward();
    _master.addStatusListener((status) {
      if (status == AnimationStatus.completed) _navigateNext();
    });

    // Auth in parallel
    _resolveAuth();
  }

  Future<void> _resolveAuth() async {
    try {
      final hasToken = await ApiService.hasToken();
      if (!hasToken) {
        _destination = const OtpLoginScreen();
        return;
      }
      await AuthState.instance.loadProfile();
      _destination = const UserHomeScreen();
    } on AuthExpiredException {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await AuthState.instance.clear();
      _destination = const OtpLoginScreen();
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final token =
          prefs.getString('auth_token') ?? prefs.getString('access_token');
      _destination = (token != null && token.isNotEmpty)
          ? const UserHomeScreen()
          : const OtpLoginScreen();
    }
  }

  void _navigateNext() async {
    if (!mounted) return;
    while (_destination == null) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => _destination!,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _master.dispose();
    _glowCtrl.dispose();
    _flickerCtrl.dispose();
    _dustCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold bg matches gradient top — NEVER black
    return Scaffold(
      backgroundColor: const Color(0xFF001510),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _master,
          _glowCtrl,
          _flickerCtrl,
          _dustCtrl,
        ]),
        builder: (context, _) {
          final glowBreath = sin(_glowCtrl.value * pi) * 0.5 + 0.5;
          final flickerVal = _flickerCtrl.isAnimating
              ? (sin(_flickerCtrl.value * pi * 6) * 0.3 + 0.7)
              : 1.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ─── Layer 0: Background gradient — ALWAYS visible, no Opacity wrapper ───
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF001510),
                      Color(0xFF002A1F),
                      Color(0xFF003D2E),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // ─── Layer 1: Soft stadium radial light — always visible ───
              Opacity(
                opacity: 0.05,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.85),
                      radius: 0.7,
                      colors: [Colors.white, Colors.transparent],
                    ),
                  ),
                ),
              ),

              // ─── Layer 2: Floating dust — always visible ───
              Opacity(
                opacity: 0.35,
                child: CustomPaint(
                  painter: _DustPainter(
                    particles: _particles,
                    t: _dustCtrl.value,
                  ),
                  size: Size.infinite,
                ),
              ),

              // ─── Layer 3: Logo + text — this fades in/out ───
              Opacity(
                opacity: _exitFade.value,
                child: Center(
                  child: Transform.scale(
                    scale: _cameraZoom.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ─── Logo with glow ───
                        Opacity(
                          opacity: _logoFade.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: _logoFade.value > 0.2
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF1DB954)
                                              .withOpacity(
                                                0.12 *
                                                    glowBreath *
                                                    flickerVal *
                                                    _logoFade.value,
                                              ),
                                          blurRadius: 30 + 15 * glowBreath,
                                          spreadRadius: 5 + 8 * glowBreath,
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFF1DB954)
                                              .withOpacity(
                                                0.06 *
                                                    glowBreath *
                                                    _logoFade.value,
                                              ),
                                          blurRadius: 60 + 20 * glowBreath,
                                          spreadRadius: 15 + 10 * glowBreath,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ─── "TURF ZONE" ───
                        Opacity(
                          opacity: _textFade.value,
                          child: const Text(
                            'TURF ZONE',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 4.0,
                              height: 1.0,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ─── Subtitle ───
                        Opacity(
                          opacity: _textFade.value * 0.7,
                          child: const Text(
                            'Book Your Turf Anytime, Anywhere',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              height: 1.0,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── DUST PARTICLE ───
class _DustParticle {
  late double x, y, size, speedX, speedY, opacity;

  _DustParticle(Random rng) {
    x = rng.nextDouble();
    y = rng.nextDouble();
    size = 0.8 + rng.nextDouble() * 1.5;
    speedX = (rng.nextDouble() - 0.5) * 0.03;
    speedY = -0.01 - rng.nextDouble() * 0.02;
    opacity = 0.15 + rng.nextDouble() * 0.25;
  }
}

class _DustPainter extends CustomPainter {
  final List<_DustParticle> particles;
  final double t;

  _DustPainter({required this.particles, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final px = ((p.x + p.speedX * t * 10) % 1.0) * size.width;
      final py = ((p.y + p.speedY * t * 10) % 1.0) * size.height;
      canvas.drawCircle(
        Offset(px, py),
        p.size,
        Paint()
          ..color = Colors.white.withOpacity(p.opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter old) => true;
}
