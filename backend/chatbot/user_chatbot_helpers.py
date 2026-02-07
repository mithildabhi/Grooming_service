# chatbot/user_chatbot_helpers.py
# 🎯 HELPER FUNCTIONS FOR USER CHATBOT
# Extracted from user_analytics.py and user_responses.py

from django.db.models import Q, Count
from django.utils import timezone
from datetime import timedelta
import math


def find_nearby_salons(city=None, customer=None, radius_km=10):
    """
    Find salons near user's location
    
    Args:
        city: City name to filter
        customer: Customer object with location data
        radius_km: Search radius in kilometers (default 10)
    
    Returns:
        List of nearby salons sorted by distance or rating
    """
    from salons.models import Salon
    
    salons = Salon.objects.filter(is_open=True)
    
    # Filter by city
    if city:
        salons = salons.filter(city__iexact=city)
    elif customer and customer.city:
        salons = salons.filter(city__iexact=customer.city)
    
    # Get salons with coordinates for distance calculation
    if customer and hasattr(customer, 'latitude') and customer.latitude:
        salons_with_coords = salons.exclude(
            Q(latitude__isnull=True) | Q(longitude__isnull=True)
        )
        
        # Calculate distance for each salon
        nearby_salons = []
        for salon in salons_with_coords:
            distance = calculate_distance(
                float(customer.latitude),
                float(customer.longitude),
                float(salon.latitude),
                float(salon.longitude)
            )
            
            if distance <= radius_km:
                salon.distance = distance
                nearby_salons.append(salon)
        
        # Sort by distance
        nearby_salons.sort(key=lambda x: x.distance)
        return nearby_salons
    
    # Return all salons in city (sorted by rating)
    return list(salons.order_by('-rating')[:20])


def get_salon_recommendations(customer):
    """
    Get personalized salon recommendations for user
    
    Strategies:
    1. High-rated salons in user's city
    2. Popular salons by booking count
    3. Salons offering user's favorite service
    
    Args:
        customer: Customer object
    
    Returns:
        List of recommended salons (max 10)
    """
    from salons.models import Salon
    from bookings.models import Booking
    
    recommendations = []
    
    # Strategy 1: High-rated salons in user's city
    if customer.city:
        top_rated = Salon.objects.filter(
            city__iexact=customer.city,
            is_open=True,
            rating__gte=4.0
        ).order_by('-rating')[:5]
        
        recommendations.extend(list(top_rated))
    
    # Strategy 2: Popular salons by booking count
    popular_salons = Salon.objects.filter(
        is_open=True
    ).annotate(
        booking_count=Count('bookings')
    ).filter(
        booking_count__gt=0
    ).order_by('-booking_count')[:5]
    
    for salon in popular_salons:
        if salon not in recommendations:
            recommendations.append(salon)
    
    # Strategy 3: Salons offering user's favorite service
    try:
        user_bookings = Booking.objects.filter(user=customer.user)
        favorite_service = user_bookings.values(
            'service'
        ).annotate(
            count=Count('id')
        ).order_by('-count').first()
        
        if favorite_service:
            from services.models import Service
            service_id = favorite_service['service']
            
            salons_with_service = Salon.objects.filter(
                services__id=service_id,
                is_open=True
            ).distinct()[:3]
            
            for salon in salons_with_service:
                if salon not in recommendations:
                    recommendations.append(salon)
    except Exception as e:
        print(f"⚠️ Error getting favorite service: {e}")
    
    return recommendations[:10]


def calculate_distance(lat1, lon1, lat2, lon2):
    """
    Calculate distance between two GPS coordinates using Haversine formula
    
    Args:
        lat1, lon1: First coordinate (latitude, longitude)
        lat2, lon2: Second coordinate (latitude, longitude)
    
    Returns:
        Distance in kilometers
    """
    # Convert to radians
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(lat2)
    lon2_rad = math.radians(lon2)
    
    # Haversine formula
    dlon = lon2_rad - lon1_rad
    dlat = lat2_rad - lat1_rad
    a = math.sin(dlat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon/2)**2
    c = 2 * math.asin(math.sqrt(a))
    
    # Radius of earth in kilometers
    r = 6371
    
    return c * r


def get_best_booking_time(salon_id):
    """
    Suggest best time to book based on salon's historical busy hours
    
    Args:
        salon_id: ID of the salon
    
    Returns:
        Dict with busiest_hour and suggested_time
    """
    from bookings.models import Booking
    from django.db.models.functions import ExtractHour
    
    try:
        # Get bookings from last 30 days
        thirty_days_ago = timezone.now().date() - timedelta(days=30)
        
        busy_hours = Booking.objects.filter(
            salon_id=salon_id,
            booking_date__gte=thirty_days_ago
        ).annotate(
            hour=ExtractHour('booking_time')
        ).values('hour').annotate(
            count=Count('id')
        ).order_by('-count')
        
        if busy_hours:
            busiest_hour = busy_hours[0]['hour']
            
            # Suggest off-peak hours
            if busiest_hour > 12:
                suggested_time = "morning (9 AM - 11 AM)"
            else:
                suggested_time = "afternoon (2 PM - 4 PM)"
            
            return {
                'busiest_hour': f"{busiest_hour}:00",
                'suggested_time': suggested_time,
                'reason': 'to avoid crowds'
            }
    except Exception as e:
        print(f"⚠️ Error getting best booking time: {e}")
    
    return {
        'suggested_time': 'morning or early afternoon',
        'reason': 'for best availability'
    }


def get_beauty_knowledge_base():
    """
    Comprehensive beauty tips and advice database
    
    Returns:
        Dict with categorized beauty knowledge
    """
    return {
        'haircare_general': [
            "Wash hair 2-3 times weekly, not daily",
            "Use lukewarm water, not hot",
            "Apply conditioner to ends, not roots",
            "Air dry when possible",
            "Trim every 6-8 weeks",
            "Weekly deep conditioning masks",
            "Minimize heat styling",
            "Brush from ends to roots to avoid breakage"
        ],
        'hair_types': {
            'dry': "Use moisturizing shampoo, deep condition weekly, avoid heat styling, oil treatments 2x/week",
            'oily': "Clarifying shampoo, light conditioner on ends only, wash more frequently, sulfate-free products",
            'normal': "Balanced routine, regular conditioning, occasional masks, maintain with good products",
            'curly': "Sulfate-free products, wide-tooth comb, leave-in conditioner, scrunch don't brush, diffuser for drying",
            'colored': "Color-safe shampoo, purple shampoo for blondes, deep condition weekly, limit washing, protect from sun"
        },
        'skincare_routine': [
            "Morning: Cleanser → Toner → Serum → Moisturizer → Sunscreen (SPF 30+)",
            "Evening: Makeup remover → Cleanser → Toner → Treatment → Night cream",
            "Weekly: Exfoliate 1-2 times, Face mask 1 time",
            "Stay hydrated: Drink 8 glasses of water daily",
            "Sleep: Get 7-8 hours for skin regeneration"
        ],
        'pre_salon': [
            "Arrive on time or 5 minutes early",
            "Bring reference photos for desired style",
            "Communicate clearly with your stylist",
            "Mention any allergies or sensitivities",
            "Ask questions about maintenance and products",
            "Wash hair day before (not same day) for cuts",
            "Come with clean face for makeup/facial services"
        ],
        'post_salon': [
            "Follow stylist's product recommendations",
            "Wait 48 hours before washing colored hair",
            "Use color-safe products for dyed hair",
            "Book next appointment before leaving",
            "Take photos to remember the style",
            "Avoid heat styling for 24 hours after treatment",
            "Use recommended hair masks for maintenance"
        ],
        'nail_care': [
            "Keep nails clean and dry",
            "Moisturize cuticles daily",
            "File in one direction only",
            "Don't bite nails or pick cuticles",
            "Wear gloves for household chores",
            "Give nails breaks from polish"
        ]
    }


def get_beauty_tips_by_topic(topic='general'):
    """
    Get specific beauty tips by topic
    
    Args:
        topic: 'hair', 'skin', 'nails', 'pre_salon', 'post_salon', or 'general'
    
    Returns:
        List of tips for the requested topic
    """
    kb = get_beauty_knowledge_base()
    
    topic_map = {
        'hair': kb['haircare_general'],
        'haircare': kb['haircare_general'],
        'skin': kb['skincare_routine'],
        'skincare': kb['skincare_routine'],
        'nails': kb['nail_care'],
        'nail': kb['nail_care'],
        'before salon': kb['pre_salon'],
        'pre salon': kb['pre_salon'],
        'after salon': kb['post_salon'],
        'post salon': kb['post_salon'],
    }
    
    return topic_map.get(topic.lower(), kb['haircare_general'])


def get_hair_type_advice(hair_type):
    """
    Get specific advice for hair type
    
    Args:
        hair_type: 'dry', 'oily', 'normal', 'curly', or 'colored'
    
    Returns:
        String with specific advice
    """
    kb = get_beauty_knowledge_base()
    hair_types = kb['hair_types']
    
    return hair_types.get(hair_type.lower(), hair_types['normal'])
