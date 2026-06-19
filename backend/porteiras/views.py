from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Porteira
from .serializers import PorteiraSerializer


@api_view(['POST'])
def view_fechar(request):
    porteira = Porteira.objects.create(status='FECHADA')
    serializer = PorteiraSerializer(porteira)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['POST'])
def view_abrir(request):
    porteira = Porteira.objects.create(status='ABERTA')
    serializer = PorteiraSerializer(porteira)
    return Response(serializer.data, status=status.HTTP_201_CREATED)