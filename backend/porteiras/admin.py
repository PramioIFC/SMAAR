from django.contrib import admin
from .models import Porteira, RegistroPorteira


@admin.register(Porteira)
class PorteiraAdmin(admin.ModelAdmin):
    list_display  = ('id', 'nome', 'proprietario', 'status', 'criada_em')
    list_filter   = ('status',)
    search_fields = ('nome', 'proprietario__username')


@admin.register(RegistroPorteira)
class RegistroAdmin(admin.ModelAdmin):
    list_display = ('id', 'porteira', 'status', 'data', 'hora')
    list_filter  = ('status', 'data')
