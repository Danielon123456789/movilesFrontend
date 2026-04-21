import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSignUp = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }

      final shouldNavigate =
          next.user != null &&
          !next.isLoading &&
          (prev?.user == null || prev?.isLoading == true);
      if (shouldNavigate) {
        context.go(Routes.agenda);
      }
    });

    const bgColor = Color(0xFFF3F4F6);
    const brandBlue = Color(0xFF6677F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: brandBlue,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Sanctum',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D1C36),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _isSignUp ? 'Crear cuenta' : '¡Bienvenido!',
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0B1B34),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _isSignUp
                      ? 'Crea tu cuenta para comenzar a utilizar Sanctum'
                      : 'Inicia sesión en tu cuenta de Sanctum',
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.25,
                    color: Color(0xFF4C5D76),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_isSignUp) ...[
                  const Text(
                    'Nombre',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B1B34),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _InputField(
                    controller: _nameController,
                    hintText: 'Nombre completo',
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B1B34),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _InputField(
                  controller: _emailController,
                  hintText: 'admin@clinica.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Contraseña',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B1B34),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _InputField(
                  controller: _passwordController,
                  hintText: 'Contraseña',
                  obscureText: _obscurePassword,
                  suffix: IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF9BA5B5),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Change password process')),
                      );
                    },
                    child: const Text(
                      '¿Olvidaste la contraseña?',
                      style: TextStyle(color: brandBlue, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(_isSignUp ? 'Crear cuenta' : 'Iniciar sesión'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: const [
                    Expanded(child: Divider(color: Color(0xFFD9DDE4))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'o',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFD9DDE4))),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: authState.isLoading ? null : _submitGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Continuar con Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0B1B34),
                      side: const BorderSide(color: Color(0xFFD9DDE4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _isSignUp
                            ? '¿Ya tienes una cuenta? '
                            : '¿No tienes una cuenta? ',
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 17,
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _isSignUp = !_isSignUp),
                        child: Text(
                          _isSignUp ? 'Iniciar sesión' : 'Registrarse',
                          style: const TextStyle(
                            color: brandBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Center(
                  child: Text(
                    'Sistema de Gestión Clínica',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu correo y contraseña.')),
      );
      return;
    }

    final notifier = ref.read(authControllerProvider.notifier);
    if (_isSignUp) {
      notifier.register(email, password);
    } else {
      notifier.login(email, password);
    }
  }

  void _submitGoogle() {
    ref.read(authControllerProvider.notifier).loginWithGoogle();
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFF0B1B34), fontSize: 18),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9BA5B5), fontSize: 17),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD9DDE4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD9DDE4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6677F0), width: 1.2),
        ),
      ),
    );
  }
}
