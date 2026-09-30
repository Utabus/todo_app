import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    setState(() => _isLoading = true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      onSuccess: (_) => context.go(RouteNames.today),
      onError: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Start organizing your work and personal routines',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.secondary),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Name field
                AppTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  hintText: 'Alex Morgan',
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.secondary),
                ),
                const SizedBox(height: AppSpacing.md),

                // Email field
                AppTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  hintText: 'alex.morgan@company.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20, color: AppColors.secondary),
                ),
                const SizedBox(height: AppSpacing.md),

                // Password field
                AppTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Create a strong password',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.secondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Sign Up Button
                AppButton(
                  label: 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _signUp,
                ),
                const SizedBox(height: AppSpacing.md),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?',
                        style: TextStyle(fontSize: 13, color: AppColors.secondary)),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Sign In',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryContainer)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
