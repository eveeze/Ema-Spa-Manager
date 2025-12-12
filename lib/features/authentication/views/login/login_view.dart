import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/theme/spacing.dart';
import 'package:emababyspa/features/authentication/controllers/auth_controller.dart';
import 'package:emababyspa/common/utils/validator_utils.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/widgets/app_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final success = await _authController.login(email, password);
      if (success) {
        Get.offAllNamed('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              isDark ? ColorTheme.secondaryDark : ColorTheme.secondary,
              isDark ? ColorTheme.primaryLightDark : ColorTheme.primaryDark,
            ],
            stops: const [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: size.height - MediaQuery.of(context).padding.top,
              child: Column(
                children: [
                  // Top Section
                  SizedBox(
                    height: size.height * 0.35,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: M3Spacing.lg,
                        vertical: M3Spacing.md,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/login_icon.png',
                          width: size.width * 0.5,
                          height: size.width * 0.5,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.spa,
                              size: size.width * 0.3,
                              color: colorScheme.onPrimary,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Bottom Section (Form)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(M3Spacing.xl),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: M3Spacing.lg,
                                  ),
                                  child: Text(
                                    'Sign In',
                                    style: textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onBackground,
                                    ),
                                  ),
                                ),
                              ),

                              // Email Input
                              AppTextField(
                                label: 'Email',
                                placeholder: 'Enter your email',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                size: TextFieldSize.medium,
                                isRequired: true,
                                prefix: const Icon(Icons.email_outlined),
                                validator: ValidatorUtils.validateEmail,
                                textInputAction: TextInputAction.next,
                                labelColor: colorScheme.onBackground,
                                requiredColor: colorScheme.error,
                                textStyle: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: M3Spacing.lg),

                              // Password Input
                              AppTextField(
                                label: 'Password',
                                placeholder: 'Enter your password',
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                size: TextFieldSize.medium,
                                isRequired: true,
                                prefix: const Icon(Icons.lock_outlined),
                                suffix: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder:
                                      (child, anim) => RotationTransition(
                                        turns: anim,
                                        child: child,
                                      ),
                                  child: IconButton(
                                    key: ValueKey(_isPasswordVisible),
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: ValidatorUtils.validatePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _handleLogin(),
                                labelColor: colorScheme.onBackground,
                                requiredColor: colorScheme.error,
                                textStyle: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: M3Spacing.xl),

                              // Login Button
                              Obx(
                                () => AppButton(
                                  text: 'LOGIN',
                                  onPressed:
                                      _authController.isLoading.value
                                          ? null
                                          : _handleLogin,
                                  type: AppButtonType.primary,
                                  size: AppButtonSize.large,
                                  isFullWidth: true,
                                  isLoading: _authController.isLoading.value,
                                  icon: Icons.login,
                                ),
                              ),

                              const SizedBox(height: M3Spacing.lg),

                              // Error Message
                              Obx(() {
                                final error =
                                    _authController.errorMessage.value;
                                if (error.isNotEmpty) {
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                      bottom: M3Spacing.md,
                                    ),
                                    padding: const EdgeInsets.all(M3Spacing.md),
                                    decoration: BoxDecoration(
                                      color: colorScheme.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colorScheme.error.withOpacity(
                                          0.4,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color: colorScheme.error,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            error,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: colorScheme.error,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                            ],
                          ),
                        ),
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
}
