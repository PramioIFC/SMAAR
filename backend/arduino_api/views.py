import urllib.request
import urllib.error
from django.http import JsonResponse
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from .models import ConfiguracaoArduino
from porteiras.models import Porteira, RegistroPorteira


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def enviar_comando(request):
    """
    Recebe o comando do app e repassa ao Arduino.
    Body: { "comando": "abrir" } ou { "comando": "trancar" }
    """
    comando = request.data.get('comando', '').strip().lower()

    if comando not in ('abrir', 'trancar'):
        return Response({'erro': 'Comando inválido. Use "abrir" ou "trancar".'}, status=400)

    config = ConfiguracaoArduino.get_solo()
    url = f'http://{config.ip}:{config.porta}/{comando}'

    try:
        with urllib.request.urlopen(url, timeout=5) as resp:
            return Response({
                'ok': True,
                'comando': comando,
                'arduino': url,
                'status_arduino': resp.status,
            })
    except urllib.error.URLError as e:
        return Response({
            'ok': False,
            'erro': f'Arduino não respondeu: {e.reason}',
            'arduino': url,
        }, status=502)
    except Exception as e:
        return Response({'ok': False, 'erro': str(e)}, status=500)


@api_view(['GET', 'PUT'])
@permission_classes([IsAuthenticated])
def configurar_arduino(request):
    """GET: retorna IP atual. PUT: atualiza IP."""
    config = ConfiguracaoArduino.get_solo()

    if request.method == 'GET':
        return Response({'ip': config.ip, 'porta': config.porta})

    ip    = request.data.get('ip', '').strip()
    porta = request.data.get('porta', 80)

    if not ip:
        return Response({'erro': 'IP é obrigatório.'}, status=400)

    config.ip    = ip
    config.porta = int(porta)
    config.save()
    return Response({'ok': True, 'ip': config.ip, 'porta': config.porta})


def checar_status_porteira(request):
    config = ConfiguracaoArduino.get_solo()
    return JsonResponse({
        'status': 'conectado',
        'arduino_ip':   config.ip,
        'arduino_porta': config.porta,
    })


@api_view(['POST'])
@permission_classes([AllowAny])
def sync_status_arduino(request):
    """
    Recebe o status físico do Arduino e atualiza a Porteira no banco.
    Body: { "porteira_id": 1, "status": "aberto" }
    Dispara notificações push quando a porteira é aberta manualmente.
    """
    from datetime import datetime as _dt
    from django.utils import timezone
    from core.push import notificar_abertura_manual, notificar_abertura_fora_horario

    porteira_id = request.data.get('porteira_id')
    novo_status = request.data.get('status', '').strip().lower()

    if not porteira_id or novo_status not in ('aberto', 'fechado'):
        return Response({'erro': 'Dados inválidos. Envie porteira_id e status (aberto/fechado).'}, status=400)

    try:
        porteira = Porteira.objects.get(id=porteira_id)
    except Porteira.DoesNotExist:
        return Response({'erro': 'Porteira não encontrada.'}, status=404)

    if porteira.status != novo_status:
        porteira.status = novo_status
        porteira.save(update_fields=['status'])
        RegistroPorteira.objects.create(porteira=porteira, status=novo_status)

        # Envia push notification se a porteira foi ABERTA manualmente
        if novo_status == 'aberto':
            # Verifica se está fora do horário permitido
            inicio = (porteira.limite_abertura or '').strip()
            fim    = (porteira.limite_fechamento or '').strip()
            fora_horario = False

            if inicio and fim:
                try:
                    t_inicio = _dt.strptime(inicio, '%H:%M').time()
                    t_fim    = _dt.strptime(fim,    '%H:%M').time()
                    agora    = timezone.localtime().time()

                    if t_inicio <= t_fim:
                        fora_horario = not (t_inicio <= agora <= t_fim)
                    else:
                        fora_horario = not (agora >= t_inicio or agora <= t_fim)
                except ValueError:
                    pass

            if fora_horario:
                notificar_abertura_fora_horario(porteira)
            else:
                notificar_abertura_manual(porteira)

    return Response({'ok': True, 'status': porteira.status})