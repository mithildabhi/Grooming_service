# salons/views.py - ENHANCED WITH AUTOMATIC GEOCODING

from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.db.models import Q
import math

from authentication.firebase_auth import FirebaseAuthentication
from .models import Salon
from .serializers import SalonSerializer
import json


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
    if city:
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
                    salon['distance'] = None  # No coordinates available
            
            # Sort by distance if calculated
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
            'user_location': {
                'lat': user_lat,
                'lon': user_lon,
            } if user_lat and user_lon else None,
        }
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def nearby_salons(request):
    """
    Get salons near user's location
    
    Query Parameters:
    - lat: User's latitude (required)
    - lon: User's longitude (required)
    - radius: Search radius in kilometers (default: 10km)
    - city: Fallback to city-based search if coordinates not provided
    """
    lat = request.query_params.get('lat', None)
    lon = request.query_params.get('lon', None)
    radius = float(request.query_params.get('radius', 10))  # Default 10km
    city = request.query_params.get('city', None)
    
    salons = Salon.objects.filter(is_open=True)
    
    # If coordinates provided, use distance calculation
    if lat and lon:
        try:
            user_lat = float(lat)
            user_lon = float(lon)
            
            # Get salons with coordinates
            salons_with_coords = salons.exclude(
                Q(latitude__isnull=True) | Q(longitude__isnull=True)
            )
            
            # Calculate distance for each salon
            nearby = []
            for salon in salons_with_coords:
                distance = calculate_distance(
                    user_lat, user_lon,
                    float(salon.latitude), float(salon.longitude)
                )
                
                if distance <= radius:
                    salon_data = SalonSerializer(salon).data
                    salon_data['distance'] = round(distance, 2)
                    nearby.append(salon_data)
            
            # Sort by distance
            nearby.sort(key=lambda x: x['distance'])
            
            print(f"📍 Found {len(nearby)} salons within {radius}km")
            
            return Response({
                'count': len(nearby),
                'radius_km': radius,
                'user_location': {'lat': user_lat, 'lon': user_lon},
                'results': nearby
            })
            
        except (ValueError, TypeError) as e:
            return Response(
                {'error': f'Invalid coordinates: {str(e)}'},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    # Fallback to city-based search
    elif city:
        salons = salons.filter(city__iexact=city.strip())
        serializer = SalonSerializer(salons, many=True)
        
        return Response({
            'count': salons.count(),
            'city': city,
            'results': serializer.data
        })
    
    else:
        return Response(
            {'error': 'Please provide either coordinates (lat/lon) or city'},
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(['GET'])
@permission_classes([AllowAny])
def cities_list(request):
    """
    Get list of all cities where salons are available
    Useful for city selection dropdown
    """
    cities = Salon.objects.filter(
        is_open=True,
        city__isnull=False
    ).exclude(
        city=''
    ).values_list('city', flat=True).distinct().order_by('city')
    
    # Also get state information
    states = Salon.objects.filter(
        is_open=True,
        state__isnull=False
    ).exclude(
        state=''
    ).values_list('state', flat=True).distinct().order_by('state')
    
    return Response({
        'count': len(cities),
        'cities': list(cities),
        'states': list(states),
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def salon_detail(request, pk):
    """Get single salon by ID (public)"""
    try:
        salon = Salon.objects.get(pk=pk, is_open=True)
        serializer = SalonSerializer(salon)
        salon_data = serializer.data
        
        # Calculate distance if user location provided
        user_lat = request.query_params.get('lat', None)
        user_lon = request.query_params.get('lon', None)
        
        if user_lat and user_lon and salon.latitude and salon.longitude:
            try:
                distance = calculate_distance(
                    float(user_lat), float(user_lon),
                    float(salon.latitude), float(salon.longitude)
                )
                salon_data['distance'] = round(distance, 2)
            except (ValueError, TypeError):
                pass
        
        return Response(salon_data)
    except Salon.DoesNotExist:
        return Response(
            {'detail': 'Salon not found'},
            status=status.HTTP_404_NOT_FOUND
        )


# ========================================
# OWNER ENDPOINTS (AUTHENTICATED)
# ========================================

@api_view(['GET'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def my_salon(request):
    """Get authenticated user's salon"""
    try:
        salon = Salon.objects.get(owner=request.user)
        serializer = SalonSerializer(salon)
        return Response(serializer.data)
    except Salon.DoesNotExist:
        return Response(
            {'detail': 'No salon found for this user'},
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def salon_create(request):
    """
    Create salon if not exists, otherwise update existing salon
    ✅ AUTOMATICALLY geocodes address to get latitude/longitude
    """
    print("\n" + "="*60)
    print("🔥 SALON CREATE/UPDATE REQUEST")
    print("="*60)
    print(f"📦 Request Data: {json.dumps(request.data, indent=2)}")
    print(f"👤 User: {request.user.email}")
    print(f"🎭 Role: {request.user.role}")
    print(f"🔑 User ID: {request.user.id}")
    
    try:
        # Check if salon already exists for this user
        salon = Salon.objects.get(owner=request.user)
        print(f"✏️ UPDATING existing salon: {salon.name} (ID: {salon.id})")
        
        # Store old address to check if it changed
        old_full_address = salon.full_address
        
        # UPDATE existing salon
        serializer = SalonSerializer(salon, data=request.data, partial=True)
        is_update = True
        
    except Salon.DoesNotExist:
        print("➕ CREATING new salon")
        
        # CREATE new salon
        serializer = SalonSerializer(data=request.data)
        old_full_address = None
        is_update = False

    if serializer.is_valid():
        # Save with owner
        saved_salon = serializer.save(owner=request.user)
        
        # ✅ AUTO-GEOCODE ADDRESS
        # Geocode if:
        # 1. No coordinates exist, OR
        # 2. Address/city changed (for updates)
        should_geocode = False
        
        if not saved_salon.latitude or not saved_salon.longitude:
            should_geocode = True
            print("🗺️ No coordinates found, will geocode...")
        elif is_update and old_full_address and saved_salon.full_address != old_full_address:
            should_geocode = True
            print(f"🗺️ Address changed from '{old_full_address}' to '{saved_salon.full_address}', will re-geocode...")
        
        if should_geocode:
            print(f"📍 Geocoding address: {saved_salon.full_address}")
            coords = geocode_address(saved_salon.full_address)
            
            if coords:
                saved_salon.latitude = coords['lat']
                saved_salon.longitude = coords['lon']
                saved_salon.save()
                print(f"✅ Successfully geocoded to: {coords['lat']}, {coords['lon']}")
            else:
                print("⚠️ Geocoding failed - coordinates not updated")
        else:
            print("ℹ️ Coordinates already set and address unchanged")
        
        print(f"\n✅ SUCCESS! Salon saved: {saved_salon.name}")
        print(f"🆔 ID: {saved_salon.id}")
        print(f"📞 Phone: {saved_salon.phone}")
        print(f"🏠 Address: {saved_salon.address}")
        print(f"🌆 City: {saved_salon.city}")
        print(f"🏛️ State: {saved_salon.state}")
        print(f"📮 Pincode: {saved_salon.pincode}")
        print(f"📍 Coordinates: ({saved_salon.latitude}, {saved_salon.longitude})")
        print(f"🎨 Type: {saved_salon.salon_type}")
        print("="*60 + "\n")
        
        return Response(
            SalonSerializer(saved_salon).data,
            status=status.HTTP_201_CREATED
        )
    
    print(f"❌ VALIDATION ERRORS:")
    print(json.dumps(serializer.errors, indent=2))
    print("="*60 + "\n")
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT', 'PATCH'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def salon_update(request):
    """
    Update salon profile with automatic re-geocoding when address changes
    """
    print(f"\n🔄 UPDATE REQUEST from {request.user.email}")
    print(f"📦 Data: {request.data}")
    
    try:
        salon = Salon.objects.get(owner=request.user)
    except Salon.DoesNotExist:
        return Response(
            {'detail': 'No salon found. Please create one first.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Store old address components to detect changes
    old_full_address = salon.full_address
    old_address = salon.address
    old_city = salon.city
    old_state = salon.state
    old_pincode = salon.pincode
    
    # Partial update allows updating only specific fields
    serializer = SalonSerializer(salon, data=request.data, partial=True)
    
    if serializer.is_valid():
        updated_salon = serializer.save()
        
        # ✅ AUTO RE-GEOCODE IF ANY ADDRESS COMPONENT CHANGED
        address_changed = (
            updated_salon.address != old_address or
            updated_salon.city != old_city or
            updated_salon.state != old_state or
            updated_salon.pincode != old_pincode
        )
        
        if address_changed:
            new_full_address = updated_salon.full_address
            print(f"🗺️ Address changed:")
            print(f"   Old: {old_full_address}")
            print(f"   New: {new_full_address}")
            print("   Re-geocoding...")
            
            coords = geocode_address(new_full_address)
            
            if coords:
                updated_salon.latitude = coords['lat']
                updated_salon.longitude = coords['lon']
                updated_salon.save()
                print(f"✅ Re-geocoded to: {coords['lat']}, {coords['lon']}")
            else:
                print("⚠️ Re-geocoding failed - keeping old coordinates")
        else:
            print("ℹ️ Address unchanged, skipping geocoding")
        
        print(f"✅ Salon updated: {updated_salon.name} in {updated_salon.city}")
        print(f"📍 Final coordinates: ({updated_salon.latitude}, {updated_salon.longitude})")
        
        return Response(SalonSerializer(updated_salon).data)
    
    print(f"❌ Validation errors: {serializer.errors}")
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def salon_delete(request):
    """Delete/deactivate salon"""
    try:
        salon = Salon.objects.get(owner=request.user)
        
        # Soft delete - just mark as closed
        salon.is_open = False
        salon.save()
        
        print(f"🗑️ Salon deactivated: {salon.name}")
        
        return Response(
            {'detail': 'Salon deactivated successfully'},
            status=status.HTTP_200_OK
        )
    except Salon.DoesNotExist:
        return Response(
            {'detail': 'No salon found'},
            status=status.HTTP_404_NOT_FOUND
        )


# ========================================
# GEOCODING ENDPOINTS
# ========================================

@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def geocode_address_endpoint(request):
    """
    Geocode an address to get coordinates
    Request body: {"address": "123 Main St, City, State"}
    """
    address = request.data.get('address', '')
    
    if not address:
        return Response(
            {'error': 'Address is required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    coords = geocode_address(address)
    
    if coords:
        return Response({
            'success': True,
            'address': address,
            'latitude': coords['lat'],
            'longitude': coords['lon'],
        })
    else:
        return Response(
            {'error': 'Could not geocode address'},
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def reverse_geocode_endpoint(request):
    """
    Reverse geocode coordinates to get address
    Request body: {"lat": 23.0225, "lon": 72.5714}
    """
    lat = request.data.get('lat', None)
    lon = request.data.get('lon', None)
    
    if not lat or not lon:
        return Response(
            {'error': 'Latitude and longitude are required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        address_data = reverse_geocode(float(lat), float(lon))
        
        if address_data:
            return Response({
                'success': True,
                'latitude': lat,
                'longitude': lon,
                **address_data
            })
        else:
            return Response(
                {'error': 'Could not reverse geocode coordinates'},
                status=status.HTTP_400_BAD_REQUEST
            )
    except (ValueError, TypeError) as e:
        return Response(
            {'error': f'Invalid coordinates: {str(e)}'},
            status=status.HTTP_400_BAD_REQUEST
        )


# ========================================
# HELPER FUNCTIONS
# ========================================

def calculate_distance(lat1, lon1, lat2, lon2):
    """
    Calculate distance between two coordinates using Haversine formula
    Returns distance in kilometers
    
    Args:
        lat1: Latitude of point 1 (decimal degrees)
        lon1: Longitude of point 1 (decimal degrees)
        lat2: Latitude of point 2 (decimal degrees)
        lon2: Longitude of point 2 (decimal degrees)
    
    Returns:
        float: Distance in kilometers
    """
    # Convert decimal degrees to radians
    lon1_rad = math.radians(lon1)
    lat1_rad = math.radians(lat1)
    lon2_rad = math.radians(lon2)
    lat2_rad = math.radians(lat2)
    
    # Haversine formula
    dlon = lon2_rad - lon1_rad
    dlat = lat2_rad - lat1_rad
    a = math.sin(dlat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon/2)**2
    c = 2 * math.asin(math.sqrt(a))
    
    # Radius of earth in kilometers
    r = 6371
    
    return c * r


def geocode_address(address):
    """
    Geocode an address using Nominatim (OpenStreetMap) - FREE
    
    Args:
        address: Full address string
    
    Returns:
        dict: {'lat': float, 'lon': float} or None if failed
    """
    import requests
    from time import sleep
    
    if not address or not address.strip():
        return None
    
    try:
        # ✅ Using Nominatim - Completely FREE
        url = 'https://nominatim.openstreetmap.org/search'
        params = {
            'q': address,
            'format': 'json',
            'limit': 1,
        }
        headers = {
            'User-Agent': 'SalonBookingApp/1.0'  # Required by Nominatim
        }
        
        # Be respectful - sleep to avoid rate limiting
        sleep(1)
        
        response = requests.get(url, params=params, headers=headers, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            if data and len(data) > 0:
                result = data[0]
                return {
                    'lat': float(result['lat']),
                    'lon': float(result['lon'])
                }
        
        print(f"⚠️ Geocoding failed for: {address}")
        return None
        
    except Exception as e:
        print(f"❌ Geocoding error: {e}")
        return None


def reverse_geocode(lat, lon):
    """
    Reverse geocode coordinates to address using Nominatim - FREE
    
    Args:
        lat: Latitude
        lon: Longitude
    
    Returns:
        dict: {
            'address': str,
            'city': str,
            'state': str,
            'pincode': str,
            'country': str
        } or None if failed
    """
    import requests
    from time import sleep
    
    try:
        # ✅ Using Nominatim - Completely FREE
        url = 'https://nominatim.openstreetmap.org/reverse'
        params = {
            'lat': lat,
            'lon': lon,
            'format': 'json',
        }
        headers = {
            'User-Agent': 'SalonBookingApp/1.0'
        }
        
        # Be respectful
        sleep(1)
        
        response = requests.get(url, params=params, headers=headers, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            
            if 'address' in data:
                addr = data['address']
                
                # Extract components
                city = (
                    addr.get('city') or 
                    addr.get('town') or 
                    addr.get('village') or 
                    addr.get('municipality') or
                    ''
                )
                
                state = (
                    addr.get('state') or 
                    addr.get('state_district') or
                    ''
                )
                
                pincode = addr.get('postcode', '')
                country = addr.get('country', '')
                
                # Build full address
                full_address = data.get('display_name', '')
                
                return {
                    'address': full_address,
                    'city': city,
                    'state': state,
                    'pincode': pincode,
                    'country': country,
                }
        
        print(f"⚠️ Reverse geocoding failed for: {lat}, {lon}")
        return None
        
    except Exception as e:
        print(f"❌ Reverse geocoding error: {e}")
        return None