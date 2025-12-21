from django.urls import path
from .views import salon_list, salon_create, salon_detail

urlpatterns = [
    path('', salon_list),                 # GET only
    path('create/', salon_create),        # POST only (JWT required)
    path('<int:pk>/', salon_detail),      # GET / PUT / DELETE
]
