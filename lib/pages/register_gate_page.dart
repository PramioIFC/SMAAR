import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

// =============================================================================
// PÁGINA DE CADASTRO
// =============================================================================

class RegisterGatePage extends StatefulWidget {
  const RegisterGatePage({super.key});

  @override
  State<RegisterGatePage> createState() => _RegisterGatePageState();
}

class _RegisterGatePageState extends State<RegisterGatePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _openTimeController = TextEditingController();
  final _closeTimeController = TextEditingController();

  bool _isClosed = true; // status inicial da porteira
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    super.dispose();
  }

  // ── Selecionar horário com TimePicker ─────────────────────────────────────

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      controller.text = "$h:$m";
    }
  }

  // ── Salvar e voltar com os dados ──────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    if (!mounted) return;

    final newGate = Gate(
      id: null, // o backend atribui o id real ao persistir
      name: _nameController.text.trim(),
      limitTimeStart: _openTimeController.text.trim(),
      limitTimeEnd: _closeTimeController.text.trim(),
      isClosed: _isClosed,
    );

    // Devolve o objeto para a MainPage via Navigator.pop
    Navigator.pop(context, newGate);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildIconPreview(),
                      const SizedBox(height: 32),
                      _buildLabel("Nome da porteira"),
                      const SizedBox(height: 8),
                      _buildNameField(),
                      const SizedBox(height: 28),
                      _buildLabel("Horário de funcionamento"),
                      const SizedBox(height: 8),
                      _buildTimeRow(),
                      const SizedBox(height: 28),
                      _buildLabel("Status inicial"),
                      const SizedBox(height: 8),
                      _buildStatusToggle(),
                      const SizedBox(height: 40),
                      _buildSubmitButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Cabeçalho ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black87,
              size: 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nova Porteira",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.1,
                ),
              ),
              Text(
                "Preencha os dados abaixo",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Ícone de preview ──────────────────────────────────────────────────────

  Widget _buildIconPreview() {
    return Center(
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        ),
        child: const Icon(
          Icons.fence_rounded,
          size: 44,
          color: Color(0xFF2E7D32),
        ),
      ),
    );
  }

  // ── Label padrão ──────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
        letterSpacing: 0.3,
      ),
    );
  }

  // ── Campo nome ────────────────────────────────────────────────────────────

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      inputFormatters: [LengthLimitingTextInputFormatter(40)],
      style: const TextStyle(fontSize: 18, color: Colors.black87),
      decoration: _inputDecoration(
        hint: "Ex: Porteira Principal",
        icon: Icons.label_outline_rounded,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return "Informe um nome";
        if (v.trim().length < 3) return "Nome muito curto";
        return null;
      },
    );
  }

  // ── Linha de horários ─────────────────────────────────────────────────────

  Widget _buildTimeRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTimeField(
            controller: _openTimeController,
            label: "Abertura",
            icon: Icons.lock_open_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTimeField(
            controller: _closeTimeController,
            label: "Fechamento",
            icon: Icons.lock_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _pickTime(controller),
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
      decoration: _inputDecoration(hint: "00:00", icon: icon).copyWith(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.black45),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return "Obrigatório";
        return null;
      },
    );
  }

  // ── Toggle de status ──────────────────────────────────────────────────────

  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            _isClosed ? Icons.lock_rounded : Icons.lock_open_rounded,
            color: _isClosed ? const Color(0xFF2E7D32) : Colors.redAccent,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _isClosed ? "Fechada" : "Aberta",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _isClosed ? const Color(0xFF2E7D32) : Colors.redAccent,
              ),
            ),
          ),
          Switch(
            value: _isClosed,
            activeColor: const Color(0xFF4CAF50),
            onChanged: (v) => setState(() => _isClosed = v),
          ),
        ],
      ),
    );
  }

  // ── Botão cadastrar ───────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 24),
                  SizedBox(width: 10),
                  Text(
                    "Cadastrar Porteira",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Decoração padrão dos campos ───────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 16),
      prefixIcon: Icon(icon, color: const Color(0xFF4CAF50), size: 22),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black12, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black12, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}
