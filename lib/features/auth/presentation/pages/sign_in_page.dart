import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    setState(() => _isLoading = true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithEmail(
      _emailController.text.trim().isEmpty ? 'alex.morgan@company.com' : _emailController.text.trim(),
      _passwordController.text.trim().isEmpty ? 'password123' : _passwordController.text.trim(),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded, size: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Welcome Back',
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
                  'Sign in to manage your tasks with calm focus',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.secondary),
                ),
                const SizedBox(height: AppSpacing.xxl),

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
                  hintText: '••••••••',
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
                const SizedBox(height: AppSpacing.sm),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?',
                        style: TextStyle(fontSize: 12, color: AppColors.primaryContainer)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Sign In Button
                AppButton(
                  label: 'Sign In',
                  isLoading: _isLoading,
                  onPressed: _signIn,
                ),
                const SizedBox(height: AppSpacing.md),

                // Google Sign In
                AppButton(
                  label: 'Continue with Google',
                  type: ButtonType.outlined,
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: _signIn,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?",
                        style: TextStyle(fontSize: 13, color: AppColors.secondary)),
                    TextButton(
                      onPressed: () => context.push(RouteNames.signUp),
                      child: const Text('Sign Up',
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
