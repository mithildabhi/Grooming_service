from django.urls import path
from .views import service_list, service_create, service_detail

urlpatterns = [
    path('', service_list),
    path('create/', service_create),
    path('<int:pk>/', service_detail),
]
