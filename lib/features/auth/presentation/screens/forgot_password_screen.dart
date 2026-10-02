import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/core/theme/app_colors.dart';
import 'package:movieapp/core/widgets/custom_button.dart';
import 'package:movieapp/core/widgets/custom_text_field.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:movieapp/l10n/app_localizations.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});
  static const String routeName = '/forgot-password';

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final __emailController = TextEditingController();

  @override
  void dispose() {
    __emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: BlocConsumer<AuthBloc, AuthState>(
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.primaryButton,
                          ),
                        ),
                        const SizedBox(width: 50),
                        Text(
                          l10n.forgotPassword,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryButton,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SvgPicture.asset(AppAssets.forgotPassword),
                    CustomTextField(
                      hint: l10n.email,
                      prefixIconPath: AppAssets.emailIcon,
                      controller: __emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.emailRequired;
                        }

                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value.trim())) {
                          return l10n.enterValidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 80),
                    CustomButton(
                      text: l10n.verifyEmail,
                      isLoading: state is AuthLoading,
                      onPressed: _onVerifyEmail,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
            listener: (context, state) {
              if (state is ForgotPasswordSent) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.passwordResetEmailSent)),
                );

                context.pop();
              }

              if (state is AuthError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
        ),
      ),
    );
  }

  void _onVerifyEmail() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          ForgotPasswordRequested(email: __emailController.text.trim()),
        );
  }
}
