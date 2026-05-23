import 'package:flutter/material.dart';
import '../app_state.dart';
import '../repositories/repositories/auth_repository.dart';

// ── Modelo de força de senha ───────────────────────────────────────────────

enum _PasswordStrength { empty, weak, fair, strong, veryStrong }

class _StrengthResult {
  final _PasswordStrength level;
  final List<String> failedRules; // regras ainda não cumpridas

  const _StrengthResult(this.level, this.failedRules);
}

_StrengthResult _evaluatePassword(String password) {
  if (password.isEmpty) {
    return const _StrengthResult(_PasswordStrength.empty, []);
  }

  final rules = <String, bool>{
    'Mínimo 8 caracteres': password.length >= 8,
    'Letra maiúscula': password.contains(RegExp(r'[A-Z]')),
    'Letra minúscula': password.contains(RegExp(r'[a-z]')),
    'Número': password.contains(RegExp(r'[0-9]')),
    'Caractere especial (!@#\$...)': password.contains(
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]'),
    ),
  };

  final passed = rules.values.where((v) => v).length;
  final failed = rules.entries
      .where((e) => !e.value)
      .map((e) => e.key)
      .toList();

  final level = switch (passed) {
    0 || 1 => _PasswordStrength.weak,
    2 => _PasswordStrength.weak,
    3 => _PasswordStrength.fair,
    4 => _PasswordStrength.strong,
    _ => _PasswordStrength.veryStrong,
  };

  return _StrengthResult(level, failed);
}

// ── Página ─────────────────────────────────────────────────────────────────

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authRepo = MockAuthRepository();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  _StrengthResult _strength = const _StrengthResult(
    _PasswordStrength.empty,
    [],
  );

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {
        _strength = _evaluatePassword(_passwordController.text);
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authRepo.register(
      _nameController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // Registra a sessão antes de navegar — sem isso o AuthGuard bloquearia a rota '/'
      await AppState.of(context).login(result.user!);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  // ── Helpers de cor e label ─────────────────────────────────────────────

  Color _strengthColor() => switch (_strength.level) {
    _PasswordStrength.empty => Colors.transparent,
    _PasswordStrength.weak => const Color(0xFFEF9A9A),
    _PasswordStrength.fair => const Color(0xFFFFCC80),
    _PasswordStrength.strong => const Color(0xFF81C784),
    _PasswordStrength.veryStrong => const Color(0xFF2E7D32),
  };

  String _strengthLabel() => switch (_strength.level) {
    _PasswordStrength.empty => '',
    _PasswordStrength.weak => 'Fraca',
    _PasswordStrength.fair => 'Razoável',
    _PasswordStrength.strong => 'Forte',
    _PasswordStrength.veryStrong => 'Muito forte',
  };

  int _strengthSegments() => switch (_strength.level) {
    _PasswordStrength.empty => 0,
    _PasswordStrength.weak => 1,
    _PasswordStrength.fair => 2,
    _PasswordStrength.strong => 3,
    _PasswordStrength.veryStrong => 4,
  };

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildBackButton(context),
                    const SizedBox(height: 32),
                    _buildHeader(),
                    const SizedBox(height: 36),
                    _buildForm(),
                    const Spacer(),
                    _buildLoginLink(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF2E7D32),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_outlined,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Criar\nconta',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Preencha os dados para se registrar',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF66BB6A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Nome'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nameController,
            hint: 'Seu nome de usuário',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
          ),
          const SizedBox(height: 20),
          _buildLabel('Senha'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passwordController,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF81C784),
                size: 22,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe a senha';
              if (v.length < 8) return 'Mínimo 8 caracteres';
              if (_strength.level == _PasswordStrength.weak) {
                return 'Senha muito fraca';
              }
              return null;
            },
          ),
          // Indicador de força — aparece ao digitar
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _strength.level != _PasswordStrength.empty
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _buildStrengthIndicator(),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          _buildLabel('Confirmar senha'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _confirmController,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscureConfirm,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
              child: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF81C784),
                size: 22,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirme a senha';
              if (v != _passwordController.text) return 'Senhas não coincidem';
              return null;
            },
          ),
          const SizedBox(height: 32),
          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEF9A9A)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFE57373),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildRegisterButton(),
        ],
      ),
    );
  }

  // ── Indicador visual de força ──────────────────────────────────────────

  Widget _buildStrengthIndicator() {
    final color = _strengthColor();
    final label = _strengthLabel();
    final segments = _strengthSegments();
    final failed = _strength.failedRules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra segmentada
        Row(
          children: List.generate(4, (i) {
            final active = i < segments;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: 5,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: active ? color : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        // Label de força
        Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                label,
                key: ValueKey(label),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _strength.level == _PasswordStrength.empty
                      ? Colors.transparent
                      : color,
                ),
              ),
            ),
          ],
        ),
        // Regras faltando — lista compacta
        if (failed.isNotEmpty) ...[
          const SizedBox(height: 6),
          ...failed.map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Color(0xFFEF9A9A),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    rule,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: Color(0xFF4CAF50),
              ),
              SizedBox(width: 5),
              Text(
                'Todos os requisitos atendidos',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2E7D32),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF1B5E20),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, color: const Color(0xFF81C784), size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 14),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8F5E9), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF9A9A), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF9A9A), width: 2),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    final canSubmit =
        _strength.level != _PasswordStrength.empty &&
        _strength.level != _PasswordStrength.weak;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (_isLoading || !canSubmit) ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFB0BEC5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Cadastrar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 14, color: Color(0xFF81C784)),
            children: [
              TextSpan(text: 'Já possui conta? '),
              TextSpan(
                text: 'Entrar',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
