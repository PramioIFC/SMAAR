from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from .models import Perfil

@api_view(['POST'])
def view_registro(request):
    username = request.data.get('username')
    password = request.data.get('password')
    confirmar = request.data.get('confirmar_senha')

    if password != confirmar:
        return Response({'erro': 'As senhas não coincidem'}, status=status.HTTP_400_BAD_REQUEST)

    if User.objects.filter(username=username).exists():
        return Response({'erro': 'Usuário já existe'}, status=status.HTTP_400_BAD_REQUEST)

    user = User.objects.create_user(username=username, password=password)
    Perfil.objects.create(usuario=user)
    return Response({'mensagem': 'Usuário criado com sucesso'}, status=status.HTTP_201_CREATED)

@api_view(['POST'])
def view_login(request):
    username = request.data.get('username')
    password = request.data.get('password')

    usuario = authenticate(request, username=username, password=password)
    
    if usuario:
        return Response({'mensagem': 'Login realizado com sucesso'})
    return Response({'erro': 'Usuário ou senha inválidos'}, status=status.HTTP_401_UNAUTHORIZED)