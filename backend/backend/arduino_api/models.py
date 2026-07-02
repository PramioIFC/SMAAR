from django.db import models

class ConfiguracaoArduino(models.Model):
    """Armazena o IP do Arduino. Só existe um registro."""
    ip         = models.CharField(max_length=100, default='192.168.1.127')
    porta      = models.IntegerField(default=80)
    atualizado_em = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Configuração do Arduino'
        verbose_name_plural = 'Configuração do Arduino'

    def __str__(self):
        return f'Arduino: {self.ip}:{self.porta}'

    @classmethod
    def get_solo(cls):
        obj, _ = cls.objects.get_or_create(pk=1)
        return obj