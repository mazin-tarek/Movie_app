import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/core/theme/app_colors.dart';
import 'package:movieapp/core/widgets/custom_button.dart';
import 'package:movieapp/core/widgets/custom_text_field.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:movieapp/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  int _selectedAvatarIndex = 1;
  late final PageController _avatarController;

  final List<String> _avatars = [
    AppAssets.gamer1,
    AppAssets.gamer2,
    AppAssets.gamer3,
    AppAssets.gamer4,
    AppAssets.gamer5,
    AppAssets.gamer7,
    AppAssets.gamer8,
    AppAssets.gamer9,
  ];
  @override
  void initState() {
    super.initState();

    _avatarController = PageController(
      initialPage: _selectedAvatarIndex,
      viewportFraction: 0.32,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),

                _buildHeader(context, l10n),

                SizedBox(height: size.height * 0.025),

                _buildAvatarSection(context, l10n),

                const SizedBox(height: 14),

                CustomTextField(
                  hint: l10n.name,
                  prefixIconPath: AppAssets.name,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  hint: l10n.email,
                  prefixIconPath: AppAssets.emailIcon,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
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
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterPassword;
                    }

                    if (value.length < 6) {
                      return l10n.passwordTooShort;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hint: l10n.confirmPassword,
                  prefixIconPath: AppAssets.passwordIcon,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseConfirmPassword;
                    }

                    if (value != _passwordController.text) {
                      return l10n.passwordsDoNotMatch;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  hint: l10n.phoneNumber,
                  prefixIconPath: AppAssets.phoneIcon,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.phoneNumberRequired;
                    }

                    final phone = value.trim();

                    if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(phone)) {
                      return l10n.invalidEgyptianPhone;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is Authenticated &&
                        GoRouterState.of(context).uri.path != '/main') {
                      context.go('/main');
                    }

                    if (state is AuthError) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    return CustomButton(
                      text: l10n.register,
                      isLoading: state is AuthLoading,
                      onPressed: _onRegisterPressed,
                    );
                  },
                ),
                const SizedBox(height: 10),

                _buildLoginNavigation(context, l10n),

                const SizedBox(height: 12),

                _buildLanguageSelector(context),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primaryButton,
          ),
        ),

        Expanded(
          child: Center(
            child: Text(
              l10n.register,
              style: const TextStyle(
                color: AppColors.primaryButton,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildAvatarSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _avatarController,
            itemCount: _avatars.length,
            onPageChanged: (index) {
              setState(() {
                _selectedAvatarIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _avatarController,
                builder: (context, child) {
                  double page = _selectedAvatarIndex.toDouble();

                  if (_avatarController.hasClients &&
                      _avatarController.position.haveDimensions) {
                    page = _avatarController.page ?? page;
                  }

                  final difference = (page - index).abs();

                  final scale = 1.35 - (difference * 0.55);

                  return Center(
                    child: Transform.scale(
                      scale: scale.clamp(0.1, 6.0),
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    _avatarController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedAvatarIndex == index
                            ? AppColors.primaryButton
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundImage: AssetImage(_avatars[index]),
                      radius: 50,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 4),

        Text(
          l10n.avatar,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLoginNavigation(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: TextButton(
        onPressed: () => context.pop(),
        child: Text.rich(
          TextSpan(
            text: l10n.alreadyHaveAccount,
            style: const TextStyle(
              color: AppColors.lightBackground,
              fontSize: 12,
            ),
            children: [
              TextSpan(
                text: ' ${l10n.login}',
                style: const TextStyle(
                  color: AppColors.primaryButton,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return const SizedBox();
  }

  void _onRegisterPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      SignUpRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        avatar: _avatars[_selectedAvatarIndex],
      ),
    );
  }
}
