from django.urls import path
from .views import view_abrir, view_fechar

urlpatterns = [
    path('porteira/abrir/', view_abrir, name='porteira-abrir'),
    path('porteira/fechar/', view_fechar, name='porteira-fechar'),
]