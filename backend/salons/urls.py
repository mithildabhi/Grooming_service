# salons/urls.py - UPDATED WITH LOCATION ENDPOINTS

from django.urls import path
from . import views

urlpatterns = [
    # ========================================
    # PUBLIC ENDPOINTS
    # ========================================
    
    # List/search salons with filtering and distance calculation
    path('', views.salon_list, name='salon-list'),
    
    # Get single salon details
    path('<int:pk>/', views.salon_detail, name='salon-detail'),
    
    # Get salons near user location
    path('nearby/', views.nearby_salons, name='nearby-salons'),
    
    # Get list of all cities
    path('cities/', views.cities_list, name='cities-list'),
    
    # ========================================
    # OWNER ENDPOINTS (AUTHENTICATED)
    # ========================================
    
    # Get owner's salon profile
    path('my-salon/', views.my_salon, name='my-salon'),
    
    # Create or update salon
    path('create/', views.salon_create, name='salon-create'),
    
    # Update salon
    path('update/', views.salon_update, name='salon-update'),
    
    # Delete/deactivate salon
    path('delete/', views.salon_delete, name='salon-delete'),
    
    # ========================================
    # ✅ NEW: GEOCODING ENDPOINTS
    # ========================================
    
    # Convert address to coordinates
    path('geocode/', views.geocode_address_endpoint, name='geocode-address'),
    
    # Convert coordinates to address
    path('reverse-geocode/', views.reverse_geocode_endpoint, name='reverse-geocode'),
]

"""
API ENDPOINTS SUMMARY:

PUBLIC (No Authentication):
- GET  /api/salons/                 - List all salons (with filters: city, search, lat/lon)
- GET  /api/salons/<id>/            - Get salon details
- GET  /api/salons/nearby/          - Get nearby salons (params: lat, lon, radius)
- GET  /api/salons/cities/          - Get list of available cities

OWNER (Authentication Required):
- GET  /api/salons/my-salon/        - Get my salon profile
- POST /api/salons/create/          - Create/update my salon
- PUT  /api/salons/update/          - Update my salon
- DEL  /api/salons/delete/          - Deactivate my salon
- POST /api/salons/geocode/         - Geocode address to coordinates
- POST /api/salons/reverse-geocode/ - Reverse geocode coordinates to address

QUERY PARAMETERS:

/api/salons/ (salon_list):
  - city: Filter by city name (case-insensitive)
  - state: Filter by state
  - search: Search in name, address, city, about
  - salon_type: Filter by type (male/female/unisex)
  - lat: User latitude (for distance calculation)
  - lon: User longitude (for distance calculation)
  
  Example: /api/salons/?city=Surat&lat=21.1702&lon=72.8311

/api/salons/nearby/ (nearby_salons):
  - lat: User latitude (required)
  - lon: User longitude (required)
  - radius: Search radius in km (default: 10)
  - city: Fallback city filter
  
  Example: /api/salons/nearby/?lat=21.1702&lon=72.8311&radius=5

/api/salons/<id>/ (salon_detail):
  - lat: User latitude (optional, for distance)
  - lon: User longitude (optional, for distance)
  
  Example: /api/salons/1/?lat=21.1702&lon=72.8311
"""