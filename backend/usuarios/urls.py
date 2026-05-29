# usuarios/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('registro/', views.view_registro, name='registro'),
    path('login/', views.view_login, name='login'),
]