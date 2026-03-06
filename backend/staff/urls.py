from django.urls import path
from .views import staff_list, staff_create, staff_detail, staff_public_list

urlpatterns = [
    path('', staff_list),
    path('public/', staff_public_list),
    path('create/', staff_create),
    path('<int:pk>/', staff_detail),
]
