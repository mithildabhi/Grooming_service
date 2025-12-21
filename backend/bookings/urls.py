from django.urls import path
from .views import booking_list, create_booking, update_booking_status

urlpatterns = [
    path('', booking_list),                     # GET (role based)
    path('create/', create_booking),            # POST (user)
    path('<int:pk>/status/', update_booking_status),  # PUT (staff/admin)
]
