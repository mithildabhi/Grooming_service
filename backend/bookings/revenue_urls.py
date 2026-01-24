# bookings/revenue_urls.py - Add these to your bookings/urls.py

from django.urls import path
from . import revenue_views

# Add these to your existing bookings/urls.py:

revenue_urlpatterns = [
    # Main revenue endpoints
    path('revenue/', revenue_views.revenue_overview, name='revenue-overview'),
    path('revenue/daily/', revenue_views.daily_revenue, name='daily-revenue'),
    path('revenue/weekly/', revenue_views.weekly_revenue, name='weekly-revenue'),
    path('revenue/monthly/', revenue_views.monthly_revenue, name='monthly-revenue'),
    
    # Analysis endpoints
    path('revenue/services/', revenue_views.service_revenue, name='service-revenue'),
    path('revenue/staff/', revenue_views.staff_performance, name='staff-performance'),
    path('revenue/categories/', revenue_views.revenue_by_category, name='category-revenue'),
    path('revenue/peak-hours/', revenue_views.peak_hours_revenue, name='peak-hours'),
]

"""
COMPLETE bookings/urls.py file should look like this:

from django.urls import path
from . import views, revenue_views

urlpatterns = [
    # Existing booking endpoints
    path('', views.booking_list, name='booking-list'),
    path('create/', views.create_booking, name='create-booking'),
    path('<int:pk>/status/', views.update_booking_status, name='update-booking-status'),
    path('available-slots/', views.available_slots, name='available-slots'),
    path('statistics/', views.booking_statistics, name='booking-statistics'),
    
    # Time slots
    path('time-slots/', views.time_slot_list, name='time-slot-list'),
    path('time-slots/create/', views.time_slot_create, name='time-slot-create'),
    path('time-slots/<int:pk>/', views.time_slot_detail, name='time-slot-detail'),
    
    # Blockouts
    path('blockouts/', views.blockout_list, name='blockout-list'),
    path('blockouts/create/', views.blockout_create, name='blockout-create'),
    path('blockouts/<int:pk>/', views.blockout_detail, name='blockout-detail'),
    
    # 💰 REVENUE ENDPOINTS - NEW
    path('revenue/', revenue_views.revenue_overview, name='revenue-overview'),
    path('revenue/daily/', revenue_views.daily_revenue, name='daily-revenue'),
    path('revenue/weekly/', revenue_views.weekly_revenue, name='weekly-revenue'),
    path('revenue/monthly/', revenue_views.monthly_revenue, name='monthly-revenue'),
    path('revenue/services/', revenue_views.service_revenue, name='service-revenue'),
    path('revenue/staff/', revenue_views.staff_performance, name='staff-performance'),
    path('revenue/categories/', revenue_views.revenue_by_category, name='category-revenue'),
    path('revenue/peak-hours/', revenue_views.peak_hours_revenue, name='peak-hours'),
]
"""