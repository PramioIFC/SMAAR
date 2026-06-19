from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from rest_framework_simplejwt.tokens import RefreshToken
from .models import Perfil
from .serializers import RegistroSerializer, LoginSerializer


class RegistroView(APIView):
    serializer_class = RegistroSerializer

    def post(self, request):
        serializer = RegistroSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        username = serializer.validated_data['username']
        password = serializer.validated_data['password']
        confirmar = serializer.validated_data['confirmar_senha']

        if password != confirmar:
            return Response({'erro': 'As senhas não coincidem'}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(username=username).exists():
            return Response({'erro': 'Usuário já existe'}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.create_user(username=username, password=password)
        Perfil.objects.create(usuario=user)
        return Response({
            'mensagem': 'Usuário criado com sucesso',
            'id': user.id,
            'username': user.username,
        }, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    serializer_class = LoginSerializer

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        username = serializer.validated_data['username']
        password = serializer.validated_data['password']

        usuario = authenticate(request, username=username, password=password)

        if usuario:
            refresh = RefreshToken.for_user(usuario)
            return Response({
                'mensagem': 'Login realizado com sucesso',
                'access': str(refresh.access_token),
                'refresh': str(refresh),
                'id': usuario.id,
                'username': usuario.username,
            })
        return Response({'erro': 'Usuário ou senha inválidos'}, status=status.HTTP_401_UNAUTHORIZED)