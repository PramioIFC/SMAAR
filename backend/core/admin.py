from django.contrib import admin
from .models import FCMToken


@admin.register(FCMToken)
class FCMTokenAdmin(admin.ModelAdmin):
    list_display = ('user', 'token', 'atualizado_em')
    list_filter  = ('user',)
