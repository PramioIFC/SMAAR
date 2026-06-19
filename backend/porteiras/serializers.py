from rest_framework import serializers
from .models import Porteira


class PorteiraSerializer(serializers.ModelSerializer):
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Porteira
        fields = ['id', 'status', 'status_display', 'data_hora', 'tipo_status']
        read_only_fields = ['data_hora']