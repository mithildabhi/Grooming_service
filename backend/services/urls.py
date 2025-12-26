from django.urls import path
from .views import service_list, service_create, service_detail,my_services

urlpatterns = [
    path('', service_list, name='service-list'),  # Public
    path('my-services/', my_services, name='my-services'),  # Owner's services
    path('create/', service_create, name='service-create'),
    path('<int:pk>/', service_detail, name='service-detail'),
]
