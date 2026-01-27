from django.urls import path
from .views import (
    CustomerProfileView,
    CustomerStatisticsView,
    CustomerBookingListView,
    CustomerUpcomingBookingsView,
    CustomerCompletedBookingsView,
    CustomerCancelledBookingsView,
    CustomerBookingDetailView,
    CustomerDashboardView,
    CustomerProfilePictureUploadView,
)

app_name = 'customers'

urlpatterns = [
    # ✅ CRITICAL: Add /me/ endpoint for Flutter app
    path('me/', CustomerProfileView.as_view(), name='profile-me'),
    
    # Dashboard - Complete overview
    path('dashboard/', CustomerDashboardView.as_view(), name='dashboard'),
    
    # Profile Management
    path('profile/', CustomerProfileView.as_view(), name='profile'),
    path('profile/picture/', CustomerProfilePictureUploadView.as_view(), name='profile-picture'),
    
    # Statistics
    path('statistics/', CustomerStatisticsView.as_view(), name='statistics'),
    
    # Bookings - All
    path('bookings/', CustomerBookingListView.as_view(), name='bookings-list'),
    path('bookings/<int:pk>/', CustomerBookingDetailView.as_view(), name='booking-detail'),
    
    # Bookings - Filtered by Status
    path('bookings/upcoming/', CustomerUpcomingBookingsView.as_view(), name='bookings-upcoming'),
    path('bookings/completed/', CustomerCompletedBookingsView.as_view(), name='bookings-completed'),
    path('bookings/cancelled/', CustomerCancelledBookingsView.as_view(), name='bookings-cancelled'),
]