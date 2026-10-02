import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/core/cubits/locale_cubit.dart';
import 'package:movieapp/core/di/injection_container.dart';
import 'package:movieapp/core/theme/app_colors.dart';
import 'package:movieapp/core/widgets/custom_button.dart';
import 'package:movieapp/core/widgets/custom_text_field.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:movieapp/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:movieapp/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // ---- Opening animation (only addition) ----
  late final AnimationController _introController;
  late final Animation<double> _logoMove;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoMove = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
    );

    final contentCurve = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
    );
    _contentFade = contentCurve;
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(contentCurve);

    // Start after the first frame is on screen (logo visible at the center),
    // with a short beat so the move up is clearly noticeable.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (mounted) _introController.forward();
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Center(
                    child: AnimatedBuilder(
                      animation: _introController,
                      // NOTE: the parameter is "_" on purpose so `context`
                      // below is the screen's context (outside SafeArea),
                      // which still reports the real top inset.
                      builder: (_, child) {
                        // Start position = exact screen center (where the
                        // splash logo ends), computed without measuring so
                        // the logo is visible from the very first frame:
                        // dy = H*0.46 - safeTop - logoHeight/2
                        final screenH = MediaQuery.sizeOf(context).height;
                        final safeTop = MediaQuery.paddingOf(context).top;
                        final remaining = 1 - _logoMove.value;

                        return Transform.translate(
                          offset: Offset(
                            0,
                            (screenH * 0.46 - safeTop) * remaining,
                          ),
                          child: FractionalTranslation(
                            translation: Offset(0, -0.5 * remaining),
                            child: child,
                          ),
                        );
                      },
                      child: Image.asset(
                        AppAssets.logo,
                        width: MediaQuery.of(context).size.width * 0.28,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            hint: l10n.email,
                            prefixIconPath: AppAssets.emailIcon,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.pleaseEnterEmail;
                              }
                              if (!value.contains('@')) {
                                return l10n.invalidEmailFormat;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            hint: l10n.password,
                            prefixIconPath: AppAssets.passwordIcon,
                            controller: _passwordController,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.pleaseEnterPassword;
                              }
                              if (value.length < 6) {
                                return l10n.passwordTooShort;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 2),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  context.push(ForgetPasswordScreen.routeName),
                              child: Text(l10n.forgetPassword),
                            ),
                          ),
                          const SizedBox(height: 20),
                          BlocConsumer<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return CustomButton(
                                text: l10n.login,
                                isLoading: state is AuthLoading,
                                onPressed: () => _onLoginPressed(context),
                              );
                            },
                            listener: (context, state) {
                              if (state is Authenticated &&
                                  GoRouterState.of(context).uri.path !=
                                      '/main') {
                                context.go('/main');
                              } else if (state is AuthError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: TextButton(
                              onPressed: () => context.push('/register'),
                              child: Text.rich(
                                TextSpan(
                                  text: l10n.dontHaveAccount,
                                  style: const TextStyle(
                                    color: AppColors.lightBackground,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: l10n.register,
                                      style: const TextStyle(
                                        color: AppColors.primaryButton,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 90,
                                child: const Divider(
                                  color: AppColors.primaryButton,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  l10n.or,
                                  style: const TextStyle(
                                    color: AppColors.primaryButton,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 90,
                                child: const Divider(
                                  color: AppColors.primaryButton,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return ElevatedButton.icon(
                                onPressed: () {
                                  context
                                      .read<AuthBloc>()
                                      .add(GoogleSignInRequested());
                                },
                                icon: SvgPicture.asset(
                                  AppAssets.googleIcon,
                                  width: 24,
                                ),
                                label: Text(l10n.loginWithGoogle),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryButton,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: const BorderSide(
                                      color: AppColors.primaryButton,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          const SizedBox(height: 16),
                          // زرار تبديل اللغة
                          Center(
                            child: BlocBuilder<LocaleCubit, Locale>(
                              builder: (context, locale) {
                                final isArabic = locale.languageCode == 'ar';
                                return GestureDetector(
                                  onTap: () {
                                    context.read<LocaleCubit>().changeLocale(
                                      isArabic
                                          ? const Locale('en')
                                          : const Locale('ar'),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildLangFlag(
                                          AppAssets.arIcon,
                                          isActive: isArabic,
                                        ),
                                        const SizedBox(width: 4),
                                        _buildLangFlag(
                                          AppAssets.enIcon,
                                          isActive: !isArabic,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onLoginPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  Widget _buildLangFlag(String iconPath, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isActive
            ? Border.all(color: AppColors.primaryButton, width: 2)
            : null,
      ),
      child: SvgPicture.asset(iconPath, width: 28, height: 28),
    );
  }
}