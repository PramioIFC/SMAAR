# porteiras/models.py
from django.db import models

class Porteira(models.Model):
    CHOICES_STATUS = [
        ('ABERTA', 'Aberta'),
        ('FECHADA', 'Fechada'),
        ('MANUTENCAO', 'Em Manutenção'),
    ]

    id_hardware = models.CharField(max_length=100, unique=True)
    nome = models.CharField(max_length=100)
    horario_aberto = models.TimeField()
    horario_fechado = models.TimeField()
    status = models.CharField(max_length=20, choices=CHOICES_STATUS, default='FECHADA')
    data_hora = models.DateTimeField(auto_now_add=True)
    tipo_status = models.CharField(max_length=100, blank=True, null=True)

    def __str__(self):
        return f"Porteira - {self.status} em {self.data_hora.strftime('%d/%m/%Y %H:%M')}"