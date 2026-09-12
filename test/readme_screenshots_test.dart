import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smaar/app_state.dart';
import 'package:smaar/models/models.dart';
import 'package:smaar/pages/day_events_page.dart';
import 'package:smaar/pages/gate_page.dart';
import 'package:smaar/pages/main_page.dart';
import 'package:smaar/repositories/repositories/gate_repository.dart';

const _gate = Gate(
  id: 1,
  name: 'Porteira Principal',
  limitTimeStart: '06:00',
  limitTimeEnd: '22:00',
  isClosed: true,
);

class _PreviewRepository implements GateRepository {
  final today = DateTime.now();

  List<DayEvent> get events => [
        DayEvent(
          id: 1,
          gateId: 1,
          date: today,
          time: '07:15',
          title: 'Porteira aberta',
          subtitle: 'Abertura registrada',
          iconName: 'lock_open',
          type: EventType.danger,
        ),
        DayEvent(
          id: 2,
          gateId: 1,
          date: today,
          time: '08:42',
          title: 'Porteira fechada',
          subtitle: 'Fechamento registrado',
          iconName: 'lock',
          type: EventType.normal,
        ),
        DayEvent(
          id: 3,
          gateId: 1,
          date: today,
          time: '12:10',
          title: 'Porteira aberta',
          subtitle: 'Abertura registrada',
          iconName: 'lock_open',
          type: EventType.danger,
        ),
        DayEvent(
          id: 4,
          gateId: 1,
          date: today,
          time: '12:18',
          title: 'Porteira fechada',
          subtitle: 'Fechamento registrado',
          iconName: 'lock',
          type: EventType.normal,
        ),
      ];

  @override
  Future<List<Gate>> getGatesForUser(int userId) async => [
        _gate,
        const Gate(
          id: 2,
          name: 'Porteira do Pasto',
          limitTimeStart: '07:00',
          limitTimeEnd: '20:00',
          isClosed: false,
        ),
      ];

  @override
  Future<List<DayEvent>> getRegistrosForGate(int gateId) async =>
      gateId == 1 ? events : [];

  @override
  Future<Map<String, String>> getCalendarioForGate(int gateId,
          {required int year, required int month}) async =>
      {};

  @override
  Future<Gate> createGate(Gate gate, {required int ownerId}) async => gate;
  @override
  Future<void> deleteGate(int id) async {}
  @override
  Future<Gate> updateGate(Gate gate) async => gate;
  @override
  Future<DayEvent> updateGateStatus(int id, bool isClosed) async => events.last;
}

Future<AppStateData> _state() async {
  final state = AppStateData(
    gateRepo: _PreviewRepository(),
    enablePolling: false,
  );
  await state.login(const User(id: 1, name: 'João'));
  return state;
}

Future<void> _render(
  WidgetTester tester,
  AppStateData state,
  Widget page,
  String golden, {
  Object? arguments,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    AppState(
      state: state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
        onGenerateRoute: (_) => MaterialPageRoute(
          settings: RouteSettings(arguments: arguments),
          builder: (_) => page,
        ),
      ),
    ),
  );
  await precacheImage(
    const AssetImage('assets/logo.jpg'),
    tester.element(find.byType(MaterialApp)),
  );
  await tester.pump(const Duration(seconds: 1));
  await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
}

void main() {
  setUpAll(() async {
    final dartExecutable = File(Platform.resolvedExecutable);
    final flutterRoot =
        dartExecutable.parent.parent.parent.parent.parent.parent;
    final fonts = Directory(
      '${flutterRoot.path}${Platform.pathSeparator}bin${Platform.pathSeparator}'
      'cache${Platform.pathSeparator}artifacts${Platform.pathSeparator}'
      'material_fonts',
    );

    Future<void> loadFonts(String family, List<String> filenames) async {
      final loader = FontLoader(family);
      for (final filename in filenames) {
        final bytes = await File(
          '${fonts.path}${Platform.pathSeparator}$filename',
        ).readAsBytes();
        loader.addFont(
          Future.value(ByteData.sublistView(Uint8List.fromList(bytes))),
        );
      }
      await loader.load();
    }

    await loadFonts('Roboto', [
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
      'Roboto-Black.ttf',
    ]);
    await loadFonts('MaterialIcons', ['MaterialIcons-Regular.otf']);
  });

  testWidgets('lista de porteiras', (tester) async {
    await _render(tester, await _state(), const MainPage(),
        'goldens/porteiras.png');
  });

  testWidgets('gerenciamento da porteira', (tester) async {
    await _render(tester, await _state(), const GatePage(),
        'goldens/gerenciar-porteira.png',
        arguments: _gate);
  });

  testWidgets('histórico de acessos do dia', (tester) async {
    await _render(tester, await _state(), const DayEventsPage(),
        'goldens/historico-do-dia.png',
        arguments: {'dateLabel': 'Hoje', 'gateId': 1});
  });

}
