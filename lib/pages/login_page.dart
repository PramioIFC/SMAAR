import 'package:flutter/material.dart';
import '../app_state.dart';
import '../repositories/repositories/auth_repository.dart';
import '../services/api_client.dart';
import '../services/notification_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey              = GlobalKey<FormState>();
  final _nameController       = TextEditingController();
  final _passwordController   = TextEditingController();
  final _serverController     = TextEditingController();
  final _authRepo = ApiAuthRepository();

  bool _obscurePassword  = true;
  bool _isLoading        = false;
  bool _showServer       = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final saved = await ApiClient().getBaseUrl();
    if (saved != null && mounted) {
      // Mostra só o host/IP para o usuário (sem http:// e /api)
      final display = saved
          .replaceFirst(RegExp(r'^https?://'), '')
          .replaceFirst(RegExp(r'/api$'), '');
      _serverController.text = display;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _serverController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Salva a URL do servidor antes de tentar login
    final serverText = _serverController.text.trim();
    if (serverText.isEmpty) {
      setState(() => _errorMessage = 'Informe o endereço do servidor (ex: 192.168.1.50)');
      return;
    }
    await ApiClient().saveBaseUrl(serverText);

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    final result = await _authRepo.login(
      _nameController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      await AppState.of(context).login(result.user!);
      // Registra o token de push notifications do dispositivo
      NotificationService.instance.registerToken();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 52),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildForm(),
                    const Spacer(),
                    _buildRegisterLink(context),
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

  Widget _buildHeader() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/logo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Bem-vindo\nde volta',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B5E20),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Faça login para continuar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF66BB6A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Servidor ──────────────────────────────────────────────────────
          _buildServerSection(),
          const SizedBox(height: 20),

          // ── Nome ──────────────────────────────────────────────────────────
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

          // ── Senha ─────────────────────────────────────────────────────────
          _buildLabel('Senha'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passwordController,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            suffixIcon: GestureDetector(
              onTap: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF81C784),
                size: 22,
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Informe a senha' : null,
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
                  const Icon(Icons.error_outline_rounded,
                      color: Color(0xFFE57373), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFFB71C1C)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildServerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho clicável
        GestureDetector(
          onTap: () => setState(() => _showServer = !_showServer),
          child: Row(
            children: [
              const Icon(Icons.settings_ethernet_rounded,
                  size: 16, color: Color(0xFF81C784)),
              const SizedBox(width: 6),
              const Text(
                'Servidor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _showServer
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: const Color(0xFF81C784),
              ),
            ],
          ),
        ),

        // Campo expansível
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _showServer
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextFormField(
              controller: _serverController,
              keyboardType: TextInputType.url,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'ex: 192.168.1.50 ou 192.168.1.50:8000',
                hintStyle:
                    const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 10),
                  child: Icon(Icons.dns_outlined,
                      color: Color(0xFF81C784), size: 22),
                ),
                prefixIconConstraints: const BoxConstraints(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFFE8F5E9), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
              ),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),

        // Indicador de servidor configurado (quando recolhido)
        if (!_showServer && _serverController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _serverController.text,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF81C784)),
            ),
          ),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF81C784),
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
                'Entrar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/register'),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 14, color: Color(0xFF81C784)),
            children: [
              TextSpan(text: 'Não possui conta? '),
              TextSpan(
                text: 'Cadastre-se',
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
