import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/core/theme/app_colors.dart';
import 'package:movieapp/core/widgets/custom_text_field.dart';
import 'package:movieapp/features/auth/domain/entities/user_entity.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:movieapp/features/auth/presentation/bloc/auth_state.dart';

class UpdateProfileScreen extends StatefulWidget {
  final UserEntity user;

  const UpdateProfileScreen({super.key, required this.user});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  static const _avatars = [
    AppAssets.gamer1,
    AppAssets.gamer2,
    AppAssets.gamer3,
    AppAssets.gamer4,
    AppAssets.gamer5,
    AppAssets.gamer7,
    AppAssets.gamer8,
    AppAssets.gamer9,
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _selectedAvatar = _avatars.contains(widget.user.avatar)
        ? widget.user.avatar!
        : _avatars.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E0E),
        foregroundColor: AppColors.primaryButton,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: const Text(
          'Update Profile',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _pickAvatar,
            child: const Text(
              'Pick Avatar',
              style: TextStyle(color: AppColors.primaryButton, fontSize: 11),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pop();
          }

          if (state is Unauthenticated) {
            context.go('/login');
          }

          if (state is ForgotPasswordSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password reset email sent.')),
            );
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFF242424),
                    backgroundImage: AssetImage(_selectedAvatar),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  hint: 'Name',
                  prefixIconPath: AppAssets.nameIcon,
                  controller: _nameController,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hint: 'Phone Number',
                  prefixIconPath: AppAssets.phoneIcon,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: isLoading ? null : _resetPassword,
                    child: const Text(
                      'Reset Password',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  child: _ProfileActionButton(
                    text: 'Delete Account',
                    color: AppColors.secButton,
                    foregroundColor: Colors.white,
                    isLoading: isLoading,
                    onPressed: _deleteAccount,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: _ProfileActionButton(
                    text: 'Update Data',
                    color: AppColors.primaryButton,
                    foregroundColor: Colors.black,
                    isLoading: isLoading,
                    onPressed: _updateProfile,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _pickAvatar() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF242424),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: _avatars.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final avatar = _avatars[index];
                final selected = avatar == _selectedAvatar;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedAvatar = avatar);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryButton
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(backgroundImage: AssetImage(avatar)),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _resetPassword() {
    if (widget.user.email.isEmpty) return;

    context.read<AuthBloc>().add(
      ForgotPasswordRequested(email: widget.user.email),
    );
  }

  void _deleteAccount() {
    context.read<AuthBloc>().add(DeleteAccountRequested());
  }

  void _updateProfile() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and phone are required.')),
      );
      return;
    }

    context.read<AuthBloc>().add(
      UpdateProfileRequested(name: name, phone: phone, avatar: _selectedAvatar),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color foregroundColor;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ProfileActionButton({
    required this.text,
    required this.color,
    required this.foregroundColor,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: foregroundColor,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
