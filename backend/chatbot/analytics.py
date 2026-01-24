# chatbot/analytics.py
# 🎯 OPTIMIZED ANALYTICS ENGINE - Fixed Revenue Calculation

from django.db.models import Sum, Count, Avg, Q, F
from django.utils import timezone
from datetime import datetime, timedelta
from django.core.cache import cache


def get_comprehensive_salon_analytics(salon):
    """
    ✅ OPTIMIZED: Fetch ALL analytics data for the salon
    ✅ FIXED: Uses correct 'price' field instead of 'total_price'
    ✅ Cached for 60 seconds to improve performance
    """
    # Try cache first
    cache_key = f'salon_analytics_{salon.id}'
    cached_data = cache.get(cache_key)
    if cached_data:
        return cached_data
    
    today = timezone.now().date()
    week_start = today - timedelta(days=today.weekday())
    month_start = today.replace(day=1)
    last_month_start = (month_start - timedelta(days=1)).replace(day=1)
    
    context = {
        'salon_name': salon.name,
        'salon_id': salon.id,
        'salon_location': getattr(salon, 'city', 'N/A'),
        'salon_owner': salon.owner.email,
    }
    
    # === BOOKING ANALYTICS ===
    try:
        from bookings.models import Booking
        
        # ✅ OPTIMIZED: Use select_related to reduce queries
        base_bookings = Booking.objects.filter(
            salon=salon
        ).select_related('service', 'staff', 'user')
        
        # ✅ TODAY'S BOOKINGS
        today_bookings = base_bookings.filter(booking_date=today)
        context['today_bookings_count'] = today_bookings.count()
        
        # ✅ FIXED: Use 'price' field from Booking model
        context['today_revenue'] = float(
            today_bookings.aggregate(total=Sum('price'))['total'] or 0
        )
        
        # Status breakdown (case-insensitive)
        context['today_pending'] = today_bookings.filter(
            status__iexact='PENDING'
        ).count()
        context['today_confirmed'] = today_bookings.filter(
            status__iexact='CONFIRMED'
        ).count()
        context['today_completed'] = today_bookings.filter(
            status__iexact='COMPLETED'
        ).count()
        context['today_cancelled'] = today_bookings.filter(
            status__iexact='CANCELLED'
        ).count()
        
        # ✅ WEEK'S BOOKINGS
        week_bookings = base_bookings.filter(
            booking_date__gte=week_start,
            booking_date__lte=today
        )
        context['week_bookings_count'] = week_bookings.count()
        
        # ✅ FIXED: Week revenue from completed/confirmed bookings
        week_completed = week_bookings.filter(
            Q(status__iexact='CONFIRMED') | Q(status__iexact='COMPLETED')
        )
        context['week_revenue'] = float(
            week_completed.aggregate(total=Sum('price'))['total'] or 0
        )
        
        context['week_avg_booking_value'] = (
            context['week_revenue'] / context['week_bookings_count'] 
            if context['week_bookings_count'] > 0 else 0
        )
        
        # ✅ MONTH'S BOOKINGS
        month_bookings = base_bookings.filter(
            booking_date__gte=month_start
        )
        context['month_bookings_count'] = month_bookings.count()
        
        month_completed = month_bookings.filter(
            Q(status__iexact='CONFIRMED') | Q(status__iexact='COMPLETED')
        )
        context['month_revenue'] = float(
            month_completed.aggregate(total=Sum('price'))['total'] or 0
        )
        
        # ✅ LAST MONTH COMPARISON
        last_month_bookings = base_bookings.filter(
            booking_date__gte=last_month_start,
            booking_date__lt=month_start,
        ).filter(
            Q(status__iexact='CONFIRMED') | Q(status__iexact='COMPLETED')
        )
        
        last_month_revenue = float(
            last_month_bookings.aggregate(total=Sum('price'))['total'] or 0
        )
        
        if last_month_revenue > 0:
            revenue_growth = (
                (context['month_revenue'] - last_month_revenue) / 
                last_month_revenue
            ) * 100
            context['revenue_growth_percentage'] = round(revenue_growth, 1)
        else:
            context['revenue_growth_percentage'] = 0
        
        # ✅ PEAK HOURS ANALYSIS
        from django.db.models.functions import ExtractHour
        
        peak_hours_data = week_bookings.annotate(
            hour=ExtractHour('booking_time')
        ).values('hour').annotate(
            count=Count('id')
        ).order_by('-count')[:3]
        
        context['peak_hours'] = [
            f"{item['hour']:02d}:00" for item in peak_hours_data
        ]
        
        # ✅ BUSIEST DAYS
        busy_days = week_bookings.values('booking_date').annotate(
            count=Count('id')
        ).order_by('-count')[:3]
        
        context['busiest_days'] = [
            day['booking_date'].strftime('%A') for day in busy_days
        ]
        
        # ✅ CANCELLATION RATE
        total_month = month_bookings.count()
        cancelled = month_bookings.filter(status__iexact='CANCELLED').count()
        context['cancellation_rate'] = (
            (cancelled / total_month * 100) if total_month > 0 else 0
        )
        
    except Exception as e:
        print(f"❌ Booking analytics error: {e}")
        import traceback
        traceback.print_exc()
        context.update({
            'today_bookings_count': 0, 'today_revenue': 0,
            'week_bookings_count': 0, 'week_revenue': 0,
            'month_bookings_count': 0, 'month_revenue': 0,
            'revenue_growth_percentage': 0, 'cancellation_rate': 0,
            'peak_hours': [], 'busiest_days': [],
            'today_pending': 0, 'today_confirmed': 0,
            'today_completed': 0, 'today_cancelled': 0
        })
    
    # === STAFF ANALYTICS ===
    try:
        from staff.models import Employee
        from bookings.models import Booking
        
        employees = Employee.objects.filter(
            salon=salon, 
            is_active=True
        ).prefetch_related('bookings')
        
        context['total_staff'] = employees.count()
        context['staff_names'] = [emp.full_name for emp in employees]
        
        # Staff by role
        staff_by_role = employees.values('role').annotate(
            count=Count('id')
        )
        context['staff_breakdown'] = {
            item['role']: item['count'] for item in staff_by_role
        }
        
        # ✅ TOP PERFORMING STAFF (optimized)
        staff_performance = []
        for emp in employees[:10]:  # Limit to top 10 for performance
            emp_bookings = Booking.objects.filter(
                salon=salon,
                staff=emp,
                booking_date__gte=month_start
            ).filter(
                Q(status__iexact='CONFIRMED') | Q(status__iexact='COMPLETED')
            ).count()
            
            if emp_bookings > 0:
                staff_performance.append({
                    'name': emp.full_name,
                    'bookings': emp_bookings,
                    'role': emp.get_role_display()
                })
        
        # Sort by bookings and get top 3
        context['top_staff'] = sorted(
            staff_performance, 
            key=lambda x: x['bookings'], 
            reverse=True
        )[:3]
        
    except Exception as e:
        print(f"❌ Staff analytics error: {e}")
        context.update({
            'total_staff': 0,
            'staff_names': [],
            'staff_breakdown': {},
            'top_staff': []
        })
    
    # === SERVICE ANALYTICS ===
    try:
        from services.models import Service
        from bookings.models import Booking
        
        services = Service.objects.filter(
            salon=salon, 
            is_active=True
        )
        context['total_services'] = services.count()
        
        # ✅ POPULAR SERVICES (optimized with annotation)
        popular_services_data = Booking.objects.filter(
            salon=salon,
            booking_date__gte=month_start
        ).filter(
            Q(status__iexact='CONFIRMED') | Q(status__iexact='COMPLETED')
        ).values(
            'service__id', 
            'service__name', 
            'service__price'
        ).annotate(
            booking_count=Count('id'),
            total_revenue=Sum('price')
        ).order_by('-total_revenue')[:5]
        
        context['popular_services'] = [
            {
                'name': s['service__name'],
                'bookings': s['booking_count'],
                'price': float(s['service__price']) if s['service__price'] else 0,
                'revenue': float(s['total_revenue']) if s['total_revenue'] else 0
            }
            for s in popular_services_data
        ]
        
        # Service revenue contribution
        total_service_revenue = sum(
            s['revenue'] for s in context['popular_services']
        )
        if total_service_revenue > 0:
            for service in context['popular_services']:
                service['revenue_percentage'] = round(
                    (service['revenue'] / total_service_revenue) * 100, 1
                )
        
    except Exception as e:
        print(f"❌ Service analytics error: {e}")
        context.update({
            'total_services': 0,
            'popular_services': []
        })
    
    # === CUSTOMER ANALYTICS ===
    try:
        from bookings.models import Booking
        
        # Unique customers this month
        unique_customers = Booking.objects.filter(
            salon=salon,
            booking_date__gte=month_start
        ).values('user').distinct().count()
        
        context['monthly_unique_customers'] = unique_customers
        
        # Repeat customers
        customer_bookings = Booking.objects.filter(
            salon=salon,
            booking_date__gte=month_start
        ).values('user').annotate(
            visit_count=Count('id')
        )
        
        repeat_customers = sum(
            1 for c in customer_bookings if c['visit_count'] > 1
        )
        context['repeat_customer_rate'] = (
            (repeat_customers / unique_customers * 100) 
            if unique_customers > 0 else 0
        )
        
        # Average visits per customer
        context['avg_visits_per_customer'] = (
            context['month_bookings_count'] / unique_customers 
            if unique_customers > 0 else 0
        )
        
    except Exception as e:
        print(f"❌ Customer analytics error: {e}")
        context.update({
            'monthly_unique_customers': 0,
            'repeat_customer_rate': 0,
            'avg_visits_per_customer': 0
        })
    
    # Cache for 60 seconds
    cache.set(cache_key, context, 60)
    
    return context


def get_conversation_history(user, salon, limit=5):
    """
    ✅ PRIVACY: Get chat history ONLY for this user and salon
    """
    try:
        from .models import ChatHistory
        
        history = ChatHistory.objects.filter(
            user=user, 
            salon=salon
        ).order_by('-created_at')[:limit]
        
        messages = []
        for chat in reversed(history):
            messages.append({'role': 'user', 'content': chat.user_message})
            messages.append({'role': 'assistant', 'content': chat.bot_response})
        return messages
    except:
        return []


def clear_salon_cache(salon_id):
    """Clear cached analytics for a salon"""
    cache_key = f'salon_analytics_{salon_id}'
    cache.delete(cache_key)