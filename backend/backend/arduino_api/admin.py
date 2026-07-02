from django.contrib import admin
from .models import ConfiguracaoArduino


@admin.register(ConfiguracaoArduino)
class ConfiguracaoArduinoAdmin(admin.ModelAdmin):
    list_display  = ('ip', 'porta', 'atualizado_em')
    readonly_fields = ('atualizado_em',)
