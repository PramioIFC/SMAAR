import urllib.request
import urllib.error
from django.http import JsonResponse
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import ConfiguracaoArduino


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