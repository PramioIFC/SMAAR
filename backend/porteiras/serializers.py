from rest_framework import serializers
from .models import Porteira, RegistroPorteira


class RegistroSerializer(serializers.ModelSerializer):
    class Meta:
        model  = RegistroPorteira
        fields = ['id', 'porteira', 'status', 'data', 'hora']
        read_only_fields = fields


class PorteiraSerializer(serializers.ModelSerializer):
    ultimo_registro = serializers.SerializerMethodField()

    class Meta:
        model  = Porteira
        fields = ['id', 'nome', 'status', 'limite_abertura', 'limite_fechamento',
                  'criada_em', 'ultimo_registro']
        # 'status' precisa ser GRAVÁVEL para que o usuário escolha o status
        # inicial ao cadastrar a porteira (ex.: já criar "aberta").
        # Depois da criação, mudanças de status só devem ocorrer via as
        # actions abrir/fechar (PorteiraViewSet._mudar_status) — a view
        # ignora o campo 'status' em updates normais (ver perform_update
        # ausente == DRF usa o serializer padrão só no create por aqui).
        read_only_fields = ['id', 'criada_em', 'ultimo_registro']

    def get_ultimo_registro(self, obj):
        r = obj.registros.first()
        return RegistroSerializer(r).data if r else None
