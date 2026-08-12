from django.contrib.auth.models import User
from django.db import models


class FCMToken(models.Model):
    """Armazena o token FCM de cada dispositivo de cada usuário."""
    user  = models.ForeignKey(User, on_delete=models.CASCADE, related_name='fcm_tokens')
    token = models.TextField(unique=True)
    criado_em    = models.DateTimeField(auto_now_add=True)
    atualizado_em = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-atualizado_em']

    def __str__(self):
        return f'{self.user.username} – {self.token[:20]}…'
