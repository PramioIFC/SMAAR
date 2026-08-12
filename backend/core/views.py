from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import FCMToken


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def register_fcm_token(request):
    """
    Salva/atualiza o token FCM do dispositivo para o usuário autenticado.
    Body: { "token": "<fcm_token_string>" }
    """
    token = request.data.get('token', '').strip()
    if not token:
        return Response({'erro': 'Token é obrigatório.'}, status=400)

    # Se já existe para outro user, reatribui (dispositivo trocou de conta)
    FCMToken.objects.filter(token=token).exclude(user=request.user).delete()

    obj, created = FCMToken.objects.update_or_create(
        token=token,
        defaults={'user': request.user},
    )
    return Response({'ok': True, 'created': created})
