import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/repositories/repositories.dart';
import '../widgets/widgets.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GateRepository _gateRepository = MockGateRepository();
  List<Gate> _gates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGates();
  }

  Future<void> _loadGates() async {
    final gates = await _gateRepository.getAllGates();
    setState(() {
      _gates = gates;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Superior
              _buildHeader(),
              const SizedBox(height: 40),

              // Saudação
              const Text(
                "Olá, Usuário 1",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 30),

              // Lista de Porteiras
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildGateList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/dayEvents'),
        backgroundColor: Colors.grey[300],
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "tela principal",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        Row(
          children: [
            const Icon(Icons.logout, color: Colors.black87),
            const SizedBox(width: 20),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person_outline, color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGateList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _gates.length,
      itemBuilder: (context, index) {
        final gate = _gates[index];
        return GateCard(
          gate: gate,
          onTap: () => Navigator.pushNamed(context, '/gate', arguments: gate),
          onHistoryTap: () => Navigator.pushNamed(context, '/history'),
        );
      },
    );
  }
}
