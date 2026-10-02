import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/core/cubits/splash_cubit.dart';
import 'package:movieapp/core/cubits/splash_state.dart';
import 'package:movieapp/core/di/injection_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final SplashCubit _cubit;

  late final Animation<double> _logoIntro; // fade + scale in
  late final Animation<double> _slideOut; // center -> left (reveals text)
  late final Animation<double> _slideBack; // left -> center (covers text)

  bool _animationFinished = false;
  SplashState? _pendingNavigationState;

  // Layout constants (relative to screen width)
  static const double _logoWidthFactor = 0.28;
  static const double _logoShiftFactor = 0.16; // how far the logo moves left
  static const double _textGap = 16; // gap between logo and text (final)
  static const double _textHiddenShiftFactor = 0.30; // text start offset

  Animation<double> _phase(double begin, double end, Curve curve) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: curve),
    );
  }

  @override
  void initState() {
    super.initState();

    _cubit = sl<SplashCubit>()..decideNavigation();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );

    // The animation now ends exactly when the logo is back in the center,
    // so navigation happens right away (no idle hold, no fade-out).
    _logoIntro = _phase(0.00, 0.20, Curves.easeOutCubic);
    _slideOut = _phase(0.22, 0.51, Curves.easeInOutCubic);
    _slideBack = _phase(0.70, 1.00, Curves.easeInOutCubic);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationFinished = true;
        _navigateIfReady();
      }
    });

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage(AppAssets.logo), context);
    precacheImage(AssetImage(AppAssets.maskRoute), context);
  }

  void _handleNavigation(SplashState state) {
    if (!_animationFinished) {
      _pendingNavigationState = state;
      return;
    }
    _navigate(state);
  }

  void _navigateIfReady() {
    final state = _pendingNavigationState;
    if (state != null) {
      _pendingNavigationState = null;
      _navigate(state);
    }
  }

  void _navigate(SplashState state) {
    if (!mounted) return;

    if (state is SplashNavigateToOnboarding) {
      context.go('/onboarding');
    } else if (state is SplashNavigateToLogin) {
      context.go('/login');
    } else if (state is SplashNavigateToHome &&
        GoRouterState.of(context).uri.path != '/main') {
      context.go('/main');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoWidth = size.width * _logoWidthFactor;
    final shift = size.width * _logoShiftFactor;
    final centerX = size.width / 2;

    // Where the text finally sits: right next to the logo's left position.
    final logoFinalRight = centerX - shift + logoWidth / 2;
    final textFinalLeft = logoFinalRight + _textGap;

    return BlocProvider<SplashCubit>.value(
      value: _cubit,
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) => _handleNavigation(state),
        child: Scaffold(
          backgroundColor: const Color(0xFF0E0E0E),
          body: Stack(
            children: [
              // ---- Text: revealed from under the logo / covered by it ----
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // 0 = logo centered (text hidden), 1 = logo left (text shown)
                    final p = _slideOut.value - _slideBack.value;

                    // Right edge of the logo right now (slightly overlapped
                    // so no gap ever shows between logo and clip edge).
                    final logoRight =
                        centerX - p * shift + logoWidth / 2 - 6;

                    final textDx = -(1 - p) * size.width * _textHiddenShiftFactor;

                    return ClipRect(
                      clipper: _LeftEdgeClipper(logoRight),
                      child: Transform.translate(
                        offset: Offset(textDx, 0),
                        child: child,
                      ),
                    );
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: textFinalLeft),
                      child: const Text(
                        'Movie App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ---- Logo (always on top of the text) ----
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final p = _slideOut.value - _slideBack.value;
                    final intro = _logoIntro.value;

                    return Opacity(
                      opacity: intro,
                      child: Transform.translate(
                        offset: Offset(-p * shift, 0),
                        child: Transform.scale(
                          scale: 0.9 + 0.1 * intro,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: RepaintBoundary(
                    child: Image.asset(AppAssets.logo, width: logoWidth),
                  ),
                ),
              ),

              // ---- Footer ----
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.05),
                  child: FadeTransition(
                    // Footer fades out while the logo returns to center,
                    // so nothing "pops" when the login page replaces this one.
                    opacity: ReverseAnimation(_slideBack),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          AppAssets.maskRoute,
                          width: size.width * 0.4,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Supervised by Mohamed Nabil',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows only what is to the right of [left] — the logo's moving right edge.
class _LeftEdgeClipper extends CustomClipper<Rect> {
  _LeftEdgeClipper(this.left);

  final double left;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(left, 0, size.width, size.height);

  @override
  bool shouldReclip(_LeftEdgeClipper old) => old.left != left;
}