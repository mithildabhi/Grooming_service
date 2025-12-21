from django.urls import path
from .views import staff_list, staff_create, staff_detail

urlpatterns = [
    path('', staff_list),
    path('create/', staff_create),
    path('<int:pk>/', staff_detail),
]
