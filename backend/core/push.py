"""
Utilitário para enviar push notifications via Firebase Admin SDK.

Usa o arquivo de credenciais de service account do Firebase.
O caminho do arquivo deve ser definido em FIREBASE_CREDENTIALS no settings.py
ou na variável de ambiente GOOGLE_APPLICATION_CREDENTIALS.
"""
import logging
from datetime import datetime as _dt

import firebase_admin
from firebase_admin import credentials, messaging

from django.conf import settings

logger = logging.getLogger(__name__)

# Inicializa o Firebase Admin SDK uma única vez
_app = None


def _ensure_firebase():
    """Inicializa o app Firebase se ainda não estiver ativo."""
    global _app
    if _app is not None:
        return
    try:
        cred_path = getattr(settings, 'FIREBASE_CREDENTIALS', None)
        if cred_path:
            cred = credentials.Certificate(cred_path)
            _app = firebase_admin.initialize_app(cred)
        else:
            # Tenta usar GOOGLE_APPLICATION_CREDENTIALS do ambiente
            _app = firebase_admin.initialize_app()
        logger.info('Firebase Admin SDK inicializado com sucesso.')
    except Exception as e:
        logger.error(f'Erro ao inicializar Firebase Admin SDK: {e}')


def _enviar_para_tokens(tokens, title, body, data=None):
    """
    Envia notificação para uma lista de tokens FCM.
    Remove tokens inválidos do banco automaticamente.
    """
    _ensure_firebase()
    if _app is None or not tokens:
        return

    from core.models import FCMToken

    message = messaging.MulticastMessage(
        tokens=tokens,
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
        android=messaging.AndroidConfig(
            priority='high',
            notification=messaging.AndroidNotification(
                sound='default',
                channel_id=data.get('channel_id', 'smaar_normal') if data else 'smaar_normal',
            ),
        ),
    )

    try:
        response = messaging.send_each_for_multicast(message)
        # Limpa tokens que falharam permanentemente
        for i, send_response in enumerate(response.responses):
            if send_response.exception:
                error_code = getattr(send_response.exception, 'code', '')
                if error_code in ('NOT_FOUND', 'UNREGISTERED', 'INVALID_ARGUMENT'):
                    FCMToken.objects.filter(token=tokens[i]).delete()
                    logger.info(f'Token FCM removido (inválido): {tokens[i][:20]}…')
        logger.info(
            f'Push enviado: {response.success_count} sucesso, '
            f'{response.failure_count} falha(s)'
        )
    except Exception as e:
        logger.error(f'Erro ao enviar push notification: {e}')


def notificar_abertura_manual(porteira):
    """
    Notificação normal: porteira foi aberta manualmente (pelo Arduino/botão físico).
    """
    from core.models import FCMToken

    tokens = list(
        FCMToken.objects
        .filter(user=porteira.proprietario)
        .values_list('token', flat=True)
    )
    if not tokens:
        return

    hora = _dt.now().strftime('%H:%M')

    _enviar_para_tokens(
        tokens=tokens,
        title=f'{porteira.nome} foi aberta',
        body=f'Abertura manual detectada às {hora}.',
        data={
            'tipo': 'normal',
            'channel_id': 'smaar_normal',
            'porteira_id': str(porteira.id),
        },
    )


def notificar_abertura_fora_horario(porteira):
    """
    Notificação de ALERTA: porteira foi aberta fora do horário permitido.
    Usa vibração longa e prioridade máxima.
    """
    from core.models import FCMToken

    tokens = list(
        FCMToken.objects
        .filter(user=porteira.proprietario)
        .values_list('token', flat=True)
    )
    if not tokens:
        return

    hora = _dt.now().strftime('%H:%M')
    janela = f'{porteira.limite_abertura}–{porteira.limite_fechamento}'

    _enviar_para_tokens(
        tokens=tokens,
        title=f'⚠️ ALERTA: {porteira.nome}',
        body=f'Abertura fora do horário permitido ({janela}) às {hora}!',
        data={
            'tipo': 'alerta',
            'channel_id': 'smaar_alertas',
            'porteira_id': str(porteira.id),
        },
    )
