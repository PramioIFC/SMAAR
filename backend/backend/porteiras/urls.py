from rest_framework.routers import DefaultRouter
from .views import PorteiraViewSet

router = DefaultRouter()
router.register('porteiras', PorteiraViewSet, basename='porteira')
urlpatterns = router.urls
