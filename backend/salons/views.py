# salons/views.py - ✅ COMPLETE WITH GEOCODING & LOCATION

from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.db.models import Q
import math
import requests
from time import sleep

from authentication.firebase_auth import FirebaseAuthentication
from .models import Salon
from .serializers import SalonSerializer
import json


# ========================================
# ✅ GEOCODING UTILITIES
# ========================================

def geocode_address(address):
    """
    Convert address to coordinates using Nominatim (OpenStreetMap)
    FREE - No API key needed!
    
    Returns: {'lat': float, 'lon': float} or None
    """
    if not address or not address.strip():
        return None
    
    try:
        url = 'https://nominatim.openstreetmap.org/search'
        params = {
            'q': address.strip(),
            'format': 'json',
            'limit': 1,
        }
        headers = {
            'User-Agent': 'SalonBookingApp/1.0'  # Required by Nominatim
        }
        
        response = requests.get(url, params=params, headers=headers, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            if data and len(data) > 0:
                result = data[0]
                coords = {
                    'lat': float(result['lat']),
                    'lon': float(result['lon']),
                    'display_name': result.get('display_name', '')
                }
                print(f"✅ Geocoded '{address}' to: ({coords['lat']}, {coords['lon']})")
                return coords
        
        print(f"⚠️ Could not geocode address: {address}")
        return None
        
    except Exception as e:
        print(f"❌ Geocoding error: {e}")
        return None


def reverse_geocode(lat, lon):
    """
    Convert coordinates to address using Nominatim
    
    Returns: {'address': str, 'city': str, 'state': str} or None
    """
    try:
        url = 'https://nominatim.openstreetmap.org/reverse'
        params = {
            'lat': lat,
            'lon': lon,
            'format': 'json',
        }
        headers = {
            'User-Agent': 'SalonBookingApp/1.0'
        }
        
        response = requests.get(url, params=params, headers=headers, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            if data.get('address'):
                addr = data['address']
                
                # Extract components
                city = (addr.get('city') or 
                       addr.get('town') or 
                       addr.get('village') or 
                       addr.get('municipality') or '')
                
                state = (addr.get('state') or 
                        addr.get('state_district') or '')
                
                result = {
                    'address': data.get('display_name', ''),
                    'city': city,
                    'state': state,
                    'pincode': addr.get('postcode', ''),
                    'country': addr.get('country', ''),
                }
                
                print(f"✅ Reverse geocoded ({lat}, {lon}) to: {city}, {state}")
                return result
        
        return None
        
    except Exception as e:
        print(f"❌ Reverse geocoding error: {e}")
        return None


def calculate_distance(lat1, lon1, lat2, lon2):
    """
    Calculate distance between two coordinates using Haversine formula
    Returns distance in kilometers
    """
    R = 6371  # Earth's radius in kilometers
    
    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    delta_lat = math.radians(lat2 - lat1)
    delta_lon = math.radians(lon2 - lon1)
    
    a = (math.sin(delta_lat / 2) ** 2 +
         math.cos(lat1_rad) * math.cos(lat2_rad) *
         math.sin(delta_lon / 2) ** 2)
    
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    distance = R * c
    return distance


# ========================================
# PUBLIC ENDPOINTS
# ========================================

@api_view(['GET'])
@permission_classes([AllowAny])
def salon_list(request):
    """
    Public endpoint - list all salons with optional filtering
    
    Query Parameters:
    - city: Filter salons by city name (case-insensitive)
    - state: Filter by state
    - search: Search in name, address, city
    - salon_type: Filter by type (male/female/unisex)
    - lat: User latitude (for distance calculation)
    - lon: User longitude (for distance calculation)
    """
    salons = Salon.objects.filter(is_open=True)
    
    # ✅ CITY FILTER
    city = request.query_params.get('city', None)
    if city and city != 'All Cities':
        salons = salons.filter(city__iexact=city.strip())
        print(f"🌍 Filtering salons by city: {city} - Found {salons.count()} salons")
    
    # ✅ STATE FILTER
    state = request.query_params.get('state', None)
    if state:
        salons = salons.filter(state__iexact=state.strip())
    
    # ✅ SEARCH FILTER
    search = request.query_params.get('search', None)
    if search:
        salons = salons.filter(
            Q(name__icontains=search) |
            Q(address__icontains=search) |
            Q(city__icontains=search) |
            Q(about__icontains=search)
        )
    
    # ✅ SALON TYPE FILTER
    salon_type = request.query_params.get('salon_type', None)
    if salon_type:
        salons = salons.filter(salon_type=salon_type.lower())
    
    # ✅ GET USER LOCATION FOR DISTANCE CALCULATION
    user_lat = request.query_params.get('lat', None)
    user_lon = request.query_params.get('lon', None)
    
    # Serialize salons
    serializer = SalonSerializer(salons, many=True)
    salon_data = serializer.data
    
    # ✅ CALCULATE DISTANCE IF USER LOCATION PROVIDED
    if user_lat and user_lon:
        try:
            user_lat = float(user_lat)
            user_lon = float(user_lon)
            
            for salon in salon_data:
                if salon.get('latitude') and salon.get('longitude'):
                    distance = calculate_distance(
                        user_lat, user_lon,
                        float(salon['latitude']), float(salon['longitude'])
                    )
                    salon['distance'] = round(distance, 2)
                else:
                    salon['distance'] = None
            
            # Sort by distance
            salon_data = sorted(
                salon_data, 
                key=lambda x: x['distance'] if x['distance'] is not None else float('inf')
            )
            
            print(f"📍 Calculated distances for {len([s for s in salon_data if s['distance']])} salons")
            
        except (ValueError, TypeError) as e:
            print(f"⚠️ Error calculating distances: {e}")
    
    return Response({
        'count': len(salon_data),
        'results': salon_data,
        'filters': {
            'city': city,
            'state': state,
            'search': search,
            'salon_type': salon_type,
        }
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def salon_detail(request, pk):
    """Get single salon details with optional distance calculation"""
    try:
        salon = Salon.objects.get(pk=pk)
    except Salon.DoesNotExist:
        return Response(
            {'error': 'Salon not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    serializer = SalonSerializer(salon)
    salon_data = serializer.data
    
    # Calculate distance if user location provided
    user_lat = request.query_params.get('lat', None)
    user_lon = request.query_params.get('lon', None)
    
    if user_lat and user_lon and salon_data.get('latitude') and salon_data.get('longitude'):
        try:
            distance = calculate_distance(
                float(user_lat), float(user_lon),
                float(salon_data['latitude']), float(salon_data['longitude'])
            )
            salon_data['distance'] = round(distance, 2)
        except (ValueError, TypeError):
            pass
    
    return Response(salon_data)


@api_view(['GET'])
@permission_classes([AllowAny])
def nearby_salons(request):
    """
    Get salons near user location
    
    Query Parameters (REQUIRED):
    - lat: User latitude
    - lon: User longitude
    - radius: Search radius in km (default: 10)
    - city: Fallback city filter if no GPS
    """
    user_lat = request.query_params.get('lat', None)
    user_lon = request.query_params.get('lon', None)
    radius = float(request.query_params.get('radius', 10))  # Default 10km
    
    # Fallback to city if no GPS
    if not user_lat or not user_lon:
        city = request.query_params.get('city', None)
        if city:
            return salon_list(request)
        else:
            return Response(
                {'error': 'Please provide lat/lon or city'},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    try:
        user_lat = float(user_lat)
        user_lon = float(user_lon)
    except ValueError:
        return Response(
            {'error': 'Invalid coordinates'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Get all salons with coordinates
    salons = Salon.objects.filter(
        is_open=True,
        latitude__isnull=False,
        longitude__isnull=False
    )
    
    # Calculate distances
    salons_with_distance = []
    for salon in salons:
        distance = calculate_distance(
            user_lat, user_lon,
            float(salon.latitude), float(salon.longitude)
        )
        
        if distance <= radius:
            serializer = SalonSerializer(salon)
            salon_data = serializer.data
            salon_data['distance'] = round(distance, 2)
            salons_with_distance.append(salon_data)
    
    # Sort by distance
    salons_with_distance.sort(key=lambda x: x['distance'])
    
    return Response({
        'count': len(salons_with_distance),
        'radius_km': radius,
        'user_location': {'lat': user_lat, 'lon': user_lon},
        'results': salons_with_distance,
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def cities_list(request):
    """Get list of all cities with salons"""
    cities = Salon.objects.filter(
        is_open=True,
        city__isnull=False
    ).exclude(
        city=''
    ).values_list('city', flat=True).distinct().order_by('city')
    
    city_list = ['All Cities'] + list(cities)
    
    return Response({
        'count': len(city_list),
        'cities': city_list
    })


# ========================================
# OWNER ENDPOINTS (AUTHENTICATED)
# ========================================

@api_view(['GET'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def my_salon(request):
    """Get owner's salon profile"""
    try:
        salon = Salon.objects.get(owner=request.user)
        serializer = SalonSerializer(salon)
        return Response(serializer.data)
    except Salon.DoesNotExist:
        return Response(
            {'error': 'No salon profile found'},
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def salon_create(request):
    """
    Create or update salon profile
    ✅ AUTOMATICALLY GEOCODES ADDRESS TO GET COORDINATES
    """
    try:
        salon = Salon.objects.get(owner=request.user)
        # Update existing salon
        serializer = SalonSerializer(salon, data=request.data, partial=True)
    except Salon.DoesNotExist:
        # Create new salon
        serializer = SalonSerializer(data=request.data)
    
    if serializer.is_valid():
        # ✅ AUTOMATIC GEOCODING BEFORE SAVE
        validated_data = serializer.validated_data
        
        # Build full address for geocoding
        address_parts = []
        if 'address' in validated_data:
            address_parts.append(validated_data['address'])
        if 'city' in validated_data:
            address_parts.append(validated_data['city'])
        if 'state' in validated_data:
            address_parts.append(validated_data['state'])
        if 'pincode' in validated_data:
            address_parts.append(validated_data['pincode'])
        
        full_address = ', '.join(address_parts)
        
        # Only geocode if address changed or no coordinates exist
        should_geocode = False
        
        if hasattr(serializer, 'instance') and serializer.instance:
            # Updating existing salon - check if address changed
            old_salon = serializer.instance
            address_changed = (
                old_salon.address != validated_data.get('address', old_salon.address) or
                old_salon.city != validated_data.get('city', old_salon.city) or
                old_salon.state != validated_data.get('state', old_salon.state) or
                old_salon.pincode != validated_data.get('pincode', old_salon.pincode)
            )
            should_geocode = address_changed
        else:
            # New salon
            should_geocode = True
        
        # Geocode if needed
        if should_geocode and full_address:
            print(f"🗺️ Geocoding address: {full_address}")
            coords = geocode_address(full_address)
            
            if coords:
                serializer.validated_data['latitude'] = coords['lat']
                serializer.validated_data['longitude'] = coords['lon']
                print(f"✅ Coordinates set: ({coords['lat']}, {coords['lon']})")
            else:
                print("⚠️ Geocoding failed - proceeding without coordinates")
        
        # Save salon
        salon = serializer.save(owner=request.user)
        
        return Response(
            SalonSerializer(salon).data,
            status=status.HTTP_200_OK if hasattr(serializer, 'instance') and serializer.instance else status.HTTP_201_CREATED
        )
    
    return Response(
        serializer.errors,
        status=status.HTTP_400_BAD_REQUEST
    )


@api_view(['PUT'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def salon_update(request):
    """Update salon profile (alias for create - handles both)"""
    return salon_create(request)


@api_view(['DELETE'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def salon_delete(request):
    """Delete/deactivate salon"""
    try:
        salon = Salon.objects.get(owner=request.user)
        salon.is_open = False
        salon.save()
        return Response({'message': 'Salon deactivated successfully'})
    except Salon.DoesNotExist:
        return Response(
            {'error': 'No salon profile found'},
            status=status.HTTP_404_NOT_FOUND
        )


# ========================================
# ✅ GEOCODING ENDPOINTS
# ========================================

@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def geocode_address_endpoint(request):
    """
    Convert address to coordinates
    
    Request Body:
    {
        "address": "123 Main St, Surat, Gujarat, 395007"
    }
    
    Response:
    {
        "lat": 21.1702,
        "lon": 72.8311,
        "display_name": "..."
    }
    """
    address = request.data.get('address', '')
    
    if not address:
        return Response(
            {'error': 'Address is required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    coords = geocode_address(address)
    
    if coords:
        return Response(coords)
    else:
        return Response(
            {'error': 'Could not geocode address'},
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def reverse_geocode_endpoint(request):
    """
    Convert coordinates to address
    
    Request Body:
    {
        "lat": 21.1702,
        "lon": 72.8311
    }
    
    Response:
    {
        "address": "...",
        "city": "Surat",
        "state": "Gujarat",
        "pincode": "395007"
    }
    """
    lat = request.data.get('lat', None)
    lon = request.data.get('lon', None)
    
    if lat is None or lon is None:
        return Response(
            {'error': 'Latitude and longitude are required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        lat = float(lat)
        lon = float(lon)
    except ValueError:
        return Response(
            {'error': 'Invalid coordinates'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    address_data = reverse_geocode(lat, lon)
    
    if address_data:
        return Response(address_data)
    else:
        return Response(
            {'error': 'Could not reverse geocode coordinates'},
            status=status.HTTP_404_NOT_FOUND
        )