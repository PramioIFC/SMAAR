from django.contrib.auth.models import User
from django.db import models


STATUS = [('aberto', 'Aberto'), ('fechado', 'Fechado')]


class Porteira(models.Model):
    proprietario   = models.ForeignKey(User, on_delete=models.CASCADE, related_name='porteiras')
    nome           = models.CharField(max_length=100)
    status         = models.CharField(max_length=10, choices=STATUS, default='fechado')
    limite_abertura  = models.CharField(max_length=5, blank=True, default='')
    limite_fechamento = models.CharField(max_length=5, blank=True, default='')
    criada_em      = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['id']

    def __str__(self):
        return f'{self.nome} ({self.status})'


class RegistroPorteira(models.Model):
    """Cada abertura ou fechamento gera um registro imutável."""
    porteira = models.ForeignKey(Porteira, on_delete=models.CASCADE, related_name='registros')
    status   = models.CharField(max_length=10, choices=STATUS)
    data     = models.DateField(auto_now_add=True)
    hora     = models.TimeField(auto_now_add=True)

    class Meta:
        ordering = ['-data', '-hora', '-id']

    def __str__(self):
        return f'{self.porteira.nome} – {self.status} em {self.data} {self.hora}'
