import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_client.dart';

/// Handler de mensagens em background (top-level function obrigatória).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance._showLocalNotification(message);
}

/// Serviço singleton de notificações push via Firebase Cloud Messaging.
///
/// Responsabilidades:
///   1. Pedir permissão ao usuário
///   2. Obter e enviar o token FCM ao backend Django
///   3. Exibir notificações locais (foreground + background)
///   4. Diferenciar notificações normais de alertas (vibração extra)
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Canal Android para alertas críticos (vibração longa + prioridade máxima)
  static final AndroidNotificationChannel _alertChannel =
      AndroidNotificationChannel(
    'smaar_alertas',
    'Alertas SMAAR',
    description: 'Notificações de alerta da porteira (abertura fora de horário, etc.)',
    importance: Importance.max,
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
  );

  /// Canal Android para notificações normais
  static final AndroidNotificationChannel _normalChannel =
      AndroidNotificationChannel(
    'smaar_normal',
    'Porteira SMAAR',
    description: 'Notificações normais da porteira.',
    importance: Importance.high,
  );

  /// Inicializa o serviço. Chamar uma vez no boot do app.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Registra o handler de background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Pede permissão
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    // Inicializa notificações locais (Android + iOS)
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // Cria os canais no Android
    if (Platform.isAndroid) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_alertChannel);
      await androidPlugin?.createNotificationChannel(_normalChannel);
    }

    // Listener de foreground: exibe notificação local
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // Listener de quando o usuário toca na notificação
    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      // Pode navegar para uma tela específica no futuro
    });
  }

  /// Obtém o token FCM e o envia ao backend Django.
  Future<void> registerToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await ApiClient().post(
          '/fcm/register/',
          body: {'token': token},
        );
      }
    } catch (_) {
      // Silencia erros de rede; a próxima sessão tentará de novo
    }

    // Escuta renovação de token
    _fcm.onTokenRefresh.listen((newToken) async {
      try {
        await ApiClient().post(
          '/fcm/register/',
          body: {'token': newToken},
        );
      } catch (_) {}
    });
  }

  /// Exibe uma notificação local a partir de uma RemoteMessage.
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final isAlert = message.data['tipo'] == 'alerta';

    final androidDetails = AndroidNotificationDetails(
      isAlert ? _alertChannel.id : _normalChannel.id,
      isAlert ? _alertChannel.name : _normalChannel.name,
      channelDescription: isAlert
          ? _alertChannel.description
          : _normalChannel.description,
      importance: isAlert ? Importance.max : Importance.high,
      priority: isAlert ? Priority.max : Priority.high,
      enableVibration: true,
      vibrationPattern: isAlert
          ? Int64List.fromList([0, 500, 200, 500, 200, 500])
          : Int64List.fromList([0, 250]),
      icon: '@mipmap/launcher_icon',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: isAlert
          ? InterruptionLevel.critical
          : InterruptionLevel.active,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
