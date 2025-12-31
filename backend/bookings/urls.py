# bookings/urls.py - ENHANCED VERSION

from django.urls import path
from . import views

urlpatterns = [
    # Booking CRUD
    path('', views.booking_list, name='booking-list'),  # GET
    path('create/', views.create_booking, name='create-booking'),  # POST
    path('<int:pk>/status/', views.update_booking_status, name='update-booking-status'),  # PUT/PATCH
    
    # ✅ NEW: Slot availability
    path('available-slots/', views.available_slots, name='available-slots'),  # GET
    
    # ✅ NEW: Statistics
    path('statistics/', views.booking_statistics, name='booking-statistics'),  # GET
    
    # ✅ NEW: Time slot management (for admin)
    path('time-slots/', views.time_slot_list, name='time-slot-list'),  # GET
    path('time-slots/create/', views.time_slot_create, name='time-slot-create'),  # POST
    path('time-slots/<int:pk>/', views.time_slot_detail, name='time-slot-detail'),  # GET/PUT/DELETE
    
    # ✅ NEW: Blockout management
    path('blockouts/', views.blockout_list, name='blockout-list'),  # GET
    path('blockouts/create/', views.blockout_create, name='blockout-create'),  # POST
    path('blockouts/<int:pk>/', views.blockout_detail, name='blockout-detail'),  # GET/PUT/DELETE
]