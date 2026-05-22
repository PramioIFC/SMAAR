import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class GatePage extends StatefulWidget {
  const GatePage({super.key});

  @override
  State<GatePage> createState() => _GatePageState();
}

class _GatePageState extends State<GatePage> {
  int? _gateId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Gate) {
        _gateId = args.id;
      } else if (args is int) {
        _gateId = args;
      }
    }
  }

  Gate _resolveGate(AppStateData state, Object? routeArgs) {
    if (_gateId != null) {
      final found = state.gateById(_gateId!);
      if (found != null) return found;
    }
    if (routeArgs is Gate) return routeArgs;
    return const Gate(
      name: 'Porteira',
      limitTimeStart: '00:00',
      limitTimeEnd: '00:00',
      isClosed: true,
    );
  }

  void _handleAction(BuildContext context, bool close, int? gateId) {
    if (gateId == null) return;
    AppState.of(context).toggleGate(gateId, close);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final gate = _resolveGate(state, routeArgs);
    final lastEvent =
        gate.id != null ? state.lastEventForGate(gate.id!) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          gate.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildStatusSection(gate),
              const SizedBox(height: 15),
              _buildActivityCard(lastEvent),
              const SizedBox(height: 15),
              _buildActionButtons(context, gate),
              const SizedBox(height: 15),
              _buildHistoryButton(context, gate),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(Gate gate) {
    final statusColor =
        gate.isClosed ? const Color(0xFF4CAF50) : const Color(0xFFD32F2F);
    final statusText = gate.isClosed ? 'FECHADA' : 'ABERTA';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Column(
        key: ValueKey(gate.isClosed),
        children: [
          Text(
            'STATUS DA PORTEIRA',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 15),
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              gate.isClosed ? Icons.lock_outline : Icons.lock_open,
              color: Colors.white,
              size: 90,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(DayEvent? lastEvent) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Última atividade:',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            _buildActivityContent(lastEvent),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityContent(DayEvent? lastEvent) {
    if (lastEvent == null) {
      return const Text(
        'Nenhuma atividade registrada',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black38,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final colors = EventColors.forType(lastEvent.type);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colors.iconBg.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(lastEvent.icon, color: colors.iconBg, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              children: [
                TextSpan(
                  text: lastEvent.time,
                  style: TextStyle(
                    color: colors.timeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: '  ${lastEvent.title}'),
                TextSpan(
                  text: '\n${lastEvent.subtitle}',
                  style:
                      TextStyle(fontSize: 12, color: colors.subtitleColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Gate gate) {
    return Row(
      children: [
        Expanded(
          child: ActionButton(
            label: 'ABRIR',
            icon: Icons.lock_open_outlined,
            color: const Color(0xFFD32F2F),
            onTap: gate.isClosed ? () => _handleAction(context, false, gate.id) : () {},
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ActionButton(
            label: 'FECHAR',
            icon: Icons.lock_outlined,
            color: const Color(0xFF4CAF50),
            onTap: !gate.isClosed ? () => _handleAction(context, true, gate.id) : () {},
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryButton(BuildContext context, Gate gate) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/history', arguments: gate.id),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black26, width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: Color(0xFF1976D2), size: 28),
            SizedBox(width: 10),
            Text(
              'HISTÓRICO',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
