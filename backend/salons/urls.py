from django.urls import path
from . import views

urlpatterns = [
    # Public endpoints
    path('', views.salon_list, name='salon-list'),
    path('<int:pk>/', views.salon_detail, name='salon-detail'),
    
    # Owner endpoints (authenticated)
    path('my-salon/', views.my_salon, name='my-salon'),
    path('create/', views.salon_create, name='salon-create'),
    path('update/', views.salon_update, name='salon-update'),
    path('delete/', views.salon_delete, name='salon-delete'),
]
