from django.urls import path
from . import views

urlpatterns = [
    path('status/',  views.checar_status_porteira, name='status_porteira'),
    path('comando/', views.enviar_comando,          name='arduino_comando'),
    path('config/',  views.configurar_arduino,      name='arduino_config'),
]