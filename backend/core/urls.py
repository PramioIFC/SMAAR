from django.urls import path
from . import views

urlpatterns = [
    path('fcm/register/', views.register_fcm_token, name='fcm_register'),
]
