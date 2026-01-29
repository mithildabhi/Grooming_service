# chatbot/user_analytics.py
# 🎯 USER ANALYTICS & RECOMMENDATIONS

from django.db.models import Q, Count, Avg, F
from django.utils import timezone
from datetime import datetime, timedelta
import math


def get_user_salon_context(customer):
    """Get context about user's booking history and preferences"""
    from bookings.models import Booking
    
    context = {
        'customer_name': customer.full_name or 'Guest',
        'customer_city': customer.city or 'your area',
        'customer_email': customer.email,
    }
    
    try:
        # User's booking statistics
        user_bookings = Booking.objects.filter(user=customer.user)
        
        context['total_bookings'] = user_bookings.count()
        context['completed_bookings'] = user_bookings.filter(
            status__iexact='COMPLETED'
        ).count()
        
        # Upcoming bookings
        upcoming = user_bookings.filter(
            booking_date__gte=timezone.now().date()
        ).exclude(status__iexact='CANCELLED').count()
        context['upcoming_bookings'] = upcoming
        
        # Favorite salon (most visited)
        favorite_salon_data = user_bookings.values(
            'salon__id', 'salon__name'
        ).annotate(
            visit_count=Count('id')
        ).order_by('-visit_count').first()
        
        if favorite_salon_data:
            context['favorite_salon'] = favorite_salon_data['salon__name']
            context['favorite_salon_visits'] = favorite_salon_data['visit_count']
        
        # Favorite service
        favorite_service_data = user_bookings.values(
            'service__id', 'service__name'
        ).annotate(
            booking_count=Count('id')
        ).order_by('-booking_count').first()
        
        if favorite_service_data:
            context['favorite_service'] = favorite_service_data['service__name']
            context['favorite_service_count'] = favorite_service_data['booking_count']
        
        # Last booking
        last_booking = user_bookings.filter(
            status__iexact='COMPLETED'
        ).order_by('-booking_date').first()
        
        if last_booking:
            context['last_visit_date'] = last_booking.booking_date.isoformat()
            context['last_visit_salon'] = last_booking.salon.name
            context['last_visit_service'] = last_booking.service.name
        
        # Average spend
        total_spent = user_bookings.filter(
            Q(status__iexact='COMPLETED') | Q(status__iexact='CONFIRMED')
        ).aggregate(total=models.Sum('price'))['total'] or 0
        
        context['total_spent'] = float(total_spent)
        context['average_booking_value'] = (
            total_spent / context['completed_bookings']
            if context['completed_bookings'] > 0 else 0
        )
        
    except Exception as e:
        print(f"❌ User analytics error: {e}")
        context.update({
            'total_bookings': 0,
            'completed_bookings': 0,
            'upcoming_bookings': 0,
            'total_spent': 0,
            'average_booking_value': 0,
        })
    
    return context


def get_user_conversation_history(user, limit=5):
    """Get user's recent chat history"""
    try:
        from .models import UserChatHistory
        
        history = UserChatHistory.objects.filter(
            user=user
        ).order_by('-created_at')[:limit]
        
        messages = []
        for chat in reversed(history):
            messages.append({'role': 'user', 'content': chat.user_message})
            messages.append({'role': 'assistant', 'content': chat.bot_response})
        
        return messages
    except:
        return []


def find_nearby_salons(city=None, customer=None, radius_km=10):
    """Find salons near user's location"""
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
    """Get personalized salon recommendations"""
    from salons.models import Salon
    from bookings.models import Booking
    
    recommendations = []
    
    # Strategy 1: Salons with high ratings in user's city
    if customer.city:
        top_rated = Salon.objects.filter(
            city__iexact=customer.city,
            is_open=True,
            rating__gte=4.0
        ).order_by('-rating')[:5]
        
        recommendations.extend(list(top_rated))
    
    # Strategy 2: Popular salons (by booking count)
    from django.db.models import Count
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
    except:
        pass
    
    return recommendations[:10]


def calculate_distance(lat1, lon1, lat2, lon2):
    """Calculate distance between two coordinates using Haversine formula"""
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
    """Suggest best time to book based on salon's busy hours"""
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
    except:
        pass
    
    return {
        'suggested_time': 'morning or early afternoon',
        'reason': 'for best availability'
    }


# Import models at module level to avoid circular imports
from django.db import models