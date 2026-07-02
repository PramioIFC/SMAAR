from rest_framework import permissions, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Porteira, RegistroPorteira
from .serializers import PorteiraSerializer, RegistroSerializer


class PorteiraViewSet(viewsets.ModelViewSet):
    """
    CRUD + ações abrir/fechar + histórico + calendário.
    Cada usuário só enxerga e manipula as próprias porteiras (JWT).
    """
    serializer_class   = PorteiraSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Porteira.objects.filter(proprietario=self.request.user)

    def perform_create(self, serializer):
        serializer.save(proprietario=self.request.user)

    def perform_update(self, serializer):
        # 'status' só pode mudar via /abrir/ ou /fechar/ (que também criam
        # o RegistroPorteira correspondente). Editar a porteira por PUT/PATCH
        # nunca deve alterar o status para não perder o histórico.
        serializer.validated_data.pop('status', None)
        serializer.save()

    # ── Abrir / Fechar ─────────────────────────────────────────────────────
    def _mudar_status(self, request, novo_status):
        porteira = self.get_object()
        porteira.status = novo_status
        porteira.save(update_fields=['status'])
        registro = RegistroPorteira.objects.create(porteira=porteira, status=novo_status)
        return Response({
            'porteira': PorteiraSerializer(porteira).data,
            'registro': RegistroSerializer(registro).data,
        })

    @action(detail=True, methods=['post'])
    def abrir(self, request, pk=None):
        """POST /api/porteiras/{id}/abrir/"""
        return self._mudar_status(request, 'aberto')

    @action(detail=True, methods=['post'])
    def fechar(self, request, pk=None):
        """POST /api/porteiras/{id}/fechar/"""
        return self._mudar_status(request, 'fechado')

    # ── Histórico de registros ─────────────────────────────────────────────
    @action(detail=True, methods=['get'])
    def registros(self, request, pk=None):
        """
        GET /api/porteiras/{id}/registros/
        GET /api/porteiras/{id}/registros/?data=YYYY-MM-DD
        """
        porteira = self.get_object()
        qs = porteira.registros.all()
        data = request.query_params.get('data')
        if data:
            qs = qs.filter(data=data)
        return Response(RegistroSerializer(qs, many=True).data)

    # ── Calendário ────────────────────────────────────────────────────────
    @action(detail=True, methods=['get'])
    def calendario(self, request, pk=None):
        """
        GET /api/porteiras/{id}/calendario/?ano=2026&mes=6
        Retorna {"2026-06-19": "fechado", ...} — último status de cada dia.
        """
        porteira = self.get_object()
        try:
            ano = int(request.query_params['ano'])
            mes = int(request.query_params['mes'])
        except (KeyError, ValueError):
            return Response({'erro': "Informe 'ano' e 'mes'."}, status=400)

        resumo = {}
        qs = porteira.registros.filter(data__year=ano, data__month=mes).order_by('data', 'hora')
        for r in qs:
            resumo[r.data.isoformat()] = r.status
        return Response(resumo)
