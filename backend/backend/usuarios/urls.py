# usuarios/urls.py
from django.urls import path
from .views import RegistroView, LoginView, me

urlpatterns = [
    path('registro/', RegistroView.as_view(), name='registro'),
    path('login/',    LoginView.as_view(),    name='login'),
    path('me/',       me,                     name='me'),
]