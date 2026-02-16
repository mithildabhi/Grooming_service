# bookings/revenue_views.py - Complete Revenue Management System

from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.db.models import Sum, Count, Q, F, Avg
from django.utils import timezone
from datetime import datetime, timedelta
from collections import defaultdict

from .models import Booking
from services.models import Service
from staff.models import Employee
from salons.models import Salon


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def revenue_overview(request):
    """Complete revenue overview for salon owner"""
    try:
        bookings = Booking.objects.none()
        salon = None
        
        if request.user.role == 'SALON_OWNER':
            if hasattr(request.user, 'salon'):
                salon = request.user.salon
                bookings = Booking.objects.filter(salon=salon, status='COMPLETED')
            else:
                # Salon owner but no salon profile yet
                return Response({
                    'revenue': {'total': 0, 'today': 0, 'this_week': 0, 'this_month': 0, 'this_year': 0, 'pending': 0},
                    'bookings': {'total': 0, 'today': 0, 'this_week': 0, 'this_month': 0},
                    'metrics': {'average_booking_value': 0, 'completion_rate': 0}
                })
        elif request.user.role == 'SUPER_ADMIN':
            bookings = Booking.objects.filter(status='COMPLETED')
            salon = None
        else:
            return Response(
                {'error': 'Only salon owners can view revenue'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        today = timezone.now().date()
        week_start = today - timedelta(days=today.weekday())
        month_start = today.replace(day=1)
        year_start = today.replace(month=1, day=1)
        
        # ✅ USE booking.price instead of service.price
        total_revenue = bookings.aggregate(
            total=Sum('price')  # Changed from 'service__price'
        )['total'] or 0
        
        today_revenue = bookings.filter(
            booking_date=today
        ).aggregate(total=Sum('price'))['total'] or 0
        
        week_revenue = bookings.filter(
            booking_date__gte=week_start
        ).aggregate(total=Sum('price'))['total'] or 0
        
        month_revenue = bookings.filter(
            booking_date__gte=month_start
        ).aggregate(total=Sum('price'))['total'] or 0
        
        year_revenue = bookings.filter(
            booking_date__gte=year_start
        ).aggregate(total=Sum('price'))['total'] or 0
        
        # Booking counts
        total_bookings = bookings.count()
        today_bookings = bookings.filter(booking_date=today).count()
        week_bookings = bookings.filter(booking_date__gte=week_start).count()
        month_bookings = bookings.filter(booking_date__gte=month_start).count()
        
        # Average booking value
        # Ensure float conversion for division
        total_rev_float = float(total_revenue)
        avg_booking_value = (total_rev_float / total_bookings) if total_bookings > 0 else 0
        
        # Pending revenue
        if salon:
            pending = Booking.objects.filter(
                salon=salon,
                status='CONFIRMED'
            ).aggregate(total=Sum('price'))['total'] or 0
        else:
            pending = Booking.objects.filter(
                status='CONFIRMED'
            ).aggregate(total=Sum('price'))['total'] or 0
        
        response_data = {
            'revenue': {
                'total': float(total_revenue),
                'today': float(today_revenue),
                'this_week': float(week_revenue),
                'this_month': float(month_revenue),
                'this_year': float(year_revenue),
                'pending': float(pending),
            },
            'bookings': {
                'total': total_bookings,
                'today': today_bookings,
                'this_week': week_bookings,
                'this_month': month_bookings,
            },
            'metrics': {
                'average_booking_value': round(float(avg_booking_value), 2),
                'completion_rate': _calculate_completion_rate(salon),
            }
        }
        
        return Response(response_data)
        
    except Exception as e:
        print(f"❌ Revenue overview error: {e}")
        import traceback
        traceback.print_exc()
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def daily_revenue(request):
    """
    Daily revenue breakdown for a date range
    Query params: start_date, end_date (YYYY-MM-DD)
    """
    try:
        # Get date range
        start_date_str = request.query_params.get('start_date')
        end_date_str = request.query_params.get('end_date')
        
        if start_date_str:
            start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
        else:
            start_date = timezone.now().date() - timedelta(days=30)
        
        if end_date_str:
            end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
        else:
            end_date = timezone.now().date()
        
        # Get salon
        if request.user.role == 'SALON_OWNER':
            if hasattr(request.user, 'salon'):
                salon = request.user.salon
                bookings = Booking.objects.filter(
                    salon=salon,
                    status='COMPLETED',
                    booking_date__gte=start_date,
                    booking_date__lte=end_date
                )
            else:
                 return Response({
                    'start_date': start_date.strftime('%Y-%m-%d'),
                    'end_date': end_date.strftime('%Y-%m-%d'),
                    'daily_breakdown': [],
                    'total_revenue': 0,
                    'total_bookings': 0,
                })
        else:
            bookings = Booking.objects.filter(
                status='COMPLETED',
                booking_date__gte=start_date,
                booking_date__lte=end_date
            )
        
        # Group by date
        daily_data = {}
        for booking in bookings.select_related('service'):
            date_str = booking.booking_date.strftime('%Y-%m-%d')
            if date_str not in daily_data:
                daily_data[date_str] = {
                    'date': date_str,
                    'revenue': 0,
                    'bookings': 0,
                }
            daily_data[date_str]['revenue'] += float(booking.service.price)
            daily_data[date_str]['bookings'] += 1
        
        # Sort by date
        result = sorted(daily_data.values(), key=lambda x: x['date'])
        
        return Response({
            'start_date': start_date.strftime('%Y-%m-%d'),
            'end_date': end_date.strftime('%Y-%m-%d'),
            'daily_breakdown': result,
            'total_revenue': sum(d['revenue'] for d in result),
            'total_bookings': sum(d['bookings'] for d in result),
        })
        
    except Exception as e:
        print(f"❌ Daily revenue error: {e}")
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def weekly_revenue(request):
    """
    Weekly revenue breakdown for last N weeks
    Query param: weeks (default: 12)
    """
    try:
        weeks = int(request.query_params.get('weeks', 12))
        today = timezone.now().date()
        
        # Get salon
        if request.user.role == 'SALON_OWNER':
            if hasattr(request.user, 'salon'):
                salon = request.user.salon
                bookings = Booking.objects.filter(salon=salon, status='COMPLETED')
            else:
                 return Response({'weeks': weeks, 'weekly_breakdown': [], 'total_revenue': 0})
        else:
            bookings = Booking.objects.filter(status='COMPLETED')
        
        weekly_data = []
        
        for i in range(weeks):
            week_start = today - timedelta(days=today.weekday() + (i * 7))
            week_end = week_start + timedelta(days=6)
            
            week_bookings = bookings.filter(
                booking_date__gte=week_start,
                booking_date__lte=week_end
            )
            
            revenue = week_bookings.aggregate(
                total=Sum('service__price')
            )['total'] or 0
            
            count = week_bookings.count()
            
            weekly_data.insert(0, {
                'week_start': week_start.strftime('%Y-%m-%d'),
                'week_end': week_end.strftime('%Y-%m-%d'),
                'week_number': i + 1,
                'revenue': float(revenue),
                'bookings': count,
            })
        
        return Response({
            'weeks': weeks,
            'weekly_breakdown': weekly_data,
            'total_revenue': sum(w['revenue'] for w in weekly_data),
        })
        
    except Exception as e:
        print(f"❌ Weekly revenue error: {e}")
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def monthly_revenue(request):
    """
    Monthly revenue breakdown for last N months
    Query param: months (default: 12)
    """
    try:
        months = int(request.query_params.get('months', 12))
        today = timezone.now().date()
        
        # Get salon
        if request.user.role == 'SALON_OWNER':
            if hasattr(request.user, 'salon'):
                salon = request.user.salon
                bookings = Booking.objects.filter(salon=salon, status='COMPLETED')
            else:
                 return Response({'months': months, 'monthly_breakdown': [], 'total_revenue': 0})
        else:
            bookings = Booking.objects.filter(status='COMPLETED')
        
        monthly_data = []
        
        for i in range(months):
            # Calculate month
            month_date = today.replace(day=1) - timedelta(days=i * 30)
            month_start = month_date.replace(day=1)
            
            # Get next month's first day
            if month_start.month == 12:
                month_end = month_start.replace(year=month_start.year + 1, month=1, day=1) - timedelta(days=1)
            else:
                month_end = month_start.replace(month=month_start.month + 1, day=1) - timedelta(days=1)
            
            month_bookings = bookings.filter(
                booking_date__gte=month_start,
                booking_date__lte=month_end
            )
            
            revenue = month_bookings.aggregate(
                total=Sum('service__price')
            )['total'] or 0
            
            count = month_bookings.count()
            
            monthly_data.insert(0, {
                'month': month_start.strftime('%B %Y'),
                'month_start': month_start.strftime('%Y-%m-%d'),
                'month_end': month_end.strftime('%Y-%m-%d'),
                'revenue': float(revenue),
                'bookings': count,
            })
        
        return Response({
            'months': months,
            'monthly_breakdown': monthly_data,
            'total_revenue': sum(m['revenue'] for m in monthly_data),
        })
        
    except Exception as e:
        print(f"❌ Monthly revenue error: {e}")
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def service_revenue(request):
    """
    Revenue breakdown by service
    Shows which services earn the most money
    """
    try:
        # Get salon
        if request.user.role == 'SALON_OWNER':
            if hasattr(request.user, 'salon'):
                salon = request.user.salon
                bookings = Booking.objects.filter(salon=salon, status='COMPLETED')
            else:
                 return Response({'total_services': 0, 'total_revenue': 0, 'services': [], 'top_earning_service': None})
        else:
            bookings = Booking.objects.filter(status='COMPLETED')
        
        # Group by service
        service_stats = bookings.values(
            'service__id',
            'service__name',
            'service__category',
            'service__price'
        ).annotate(
            total_bookings=Count('id'),
            total_revenue=Sum('service__price')
        ).order_by('-total_revenue')
        
        # Calculate percentages
        # ✅ FIX: Convert sum of Decimals to float explicitly before using in division
        total_revenue_decimal = sum(s['total_revenue'] or 0 for s in service_stats)
        total_revenue = float(total_revenue_decimal)
        
        result = []
        for service in service_stats:
            revenue = float(service['total_revenue'] or 0)
            percentage = (revenue / total_revenue * 100) if total_revenue > 0 else 0
            
            result.append({
                'service_id': service['service__id'],
                'service_name': service['service__name'],
                'category': service['service__category'],
                'price': float(service['service__price']),
                'total_bookings': service['total_bookings'],
                'total_revenue': revenue,
                'revenue_percentage': round(percentage, 2),
            })
        
        return Response({
            'total_services': len(result),
            'total_revenue': float(total_revenue),
            'services': result,
            'top_earning_service': result[0] if result else None,
        })
        
    except Exception as e:
        print(f"❌ Service revenue error: {e}")
        import traceback
        traceback.print_exc()
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def staff_performance(request):
    """
    Revenue and performance by staff member
    """
    try:
        # Get salon
        if request.user.role == 'SALON_OWNER':
            if hasattr(request.user, 'salon'):
                salon = request.user.salon
                bookings = Booking.objects.filter(salon=salon, status='COMPLETED')
            else:
                 return Response({'total_staff': 0, 'total_revenue': 0, 'staff_performance': [], 'top_performer': None})
        else:
            bookings = Booking.objects.filter(status='COMPLETED')
        
        # Group by staff
        staff_stats = bookings.filter(
            staff__isnull=False
        ).values(
            'staff__id',
            'staff__full_name',
            'staff__role'
        ).annotate(
            total_bookings=Count('id'),
            total_revenue=Sum('service__price')
        ).order_by('-total_revenue')
        
        # Calculate additional metrics
        # ✅ FIX: Convert sum of Decimals to float explicitly
        total_revenue_decimal = sum(s['total_revenue'] or 0 for s in staff_stats)
        total_revenue = float(total_revenue_decimal)
        
        result = []
        for staff in staff_stats:
            revenue = float(staff['total_revenue'] or 0)
            bookings_count = staff['total_bookings']
            avg_per_booking = revenue / bookings_count if bookings_count > 0 else 0
            
            result.append({
                'staff_id': staff['staff__id'],
                'staff_name': staff['staff__full_name'],
                'role': staff['staff__role'],
                'total_bookings': bookings_count,
                'total_revenue': revenue,
                'average_per_booking': round(avg_per_booking, 2),
                'revenue_percentage': round((revenue / total_revenue * 100), 2) if total_revenue > 0 else 0,
            })
        
        return Response({
            'total_staff': len(result),
            'total_revenue': float(total_revenue),
            'staff_performance': result,
            'top_performer': result[0] if result else None,
        })
        
    except Exception as e:
        print(f"❌ Staff performance error: {e}")
        import traceback
        traceback.print_exc()
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def revenue_by_category(request):
    """
    Revenue breakdown by service category
    """
    try:
        # Get salon
        if request.user.role == 'SALON_OWNER':
            if hasattr(request.user, 'salon'):
                salon = request.user.salon
                bookings = Booking.objects.filter(salon=salon, status='COMPLETED')
            else:
                 return Response({'categories': [], 'total_revenue': 0})
        else:
            bookings = Booking.objects.filter(status='COMPLETED')
        
        # Group by category
        category_stats = bookings.values(
            'service__category'
        ).annotate(
            total_bookings=Count('id'),
            total_revenue=Sum('service__price')
        ).order_by('-total_revenue')
        
        # ✅ FIX: Explicit float conversion
        total_revenue_decimal = sum(c['total_revenue'] or 0 for c in category_stats)
        total_revenue = float(total_revenue_decimal)
        
        result = []
        for category in category_stats:
            revenue = float(category['total_revenue'] or 0)
            
            result.append({
                'category': category['service__category'],
                'total_bookings': category['total_bookings'],
                'total_revenue': revenue,
                'revenue_percentage': round((revenue / total_revenue * 100), 2) if total_revenue > 0 else 0,
            })
        
        return Response({
            'categories': result,
            'total_revenue': float(total_revenue),
        })
        
    except Exception as e:
        print(f"❌ Category revenue error: {e}")
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def peak_hours_revenue(request):
    """
    Revenue breakdown by hour of day
    Shows which time slots generate most revenue
    """
    try:
        # Get salon
        if request.user.role == 'SALON_OWNER':
            if hasattr(request.user, 'salon'):
                salon = request.user.salon
                bookings = Booking.objects.filter(salon=salon, status='COMPLETED')
            else:
                 return Response({'hourly_breakdown': [], 'peak_hours': []})
        else:
            bookings = Booking.objects.filter(status='COMPLETED')
        
        # Group by hour
        hourly_stats = defaultdict(lambda: {'bookings': 0, 'revenue': 0})
        
        for booking in bookings.select_related('service'):
            try:
                hour = int(booking.booking_time.strftime('%H'))
                hourly_stats[hour]['bookings'] += 1
                hourly_stats[hour]['revenue'] += float(booking.service.price)
            except:
                continue
        
        # Format result
        result = []
        for hour in range(0, 24):
            stats = hourly_stats.get(hour, {'bookings': 0, 'revenue': 0})
            result.append({
                'hour': hour,
                'time_slot': f"{hour:02d}:00 - {hour:02d}:59",
                'bookings': stats['bookings'],
                'revenue': stats['revenue'],
            })
        
        # Sort by revenue
        result_sorted = sorted(result, key=lambda x: x['revenue'], reverse=True)
        
        return Response({
            'hourly_breakdown': result,
            'peak_hours': result_sorted[:5],  # Top 5 hours
        })
        
    except Exception as e:
        print(f"❌ Peak hours error: {e}")
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


# =================== HELPER FUNCTIONS ===================

def _calculate_completion_rate(salon):
    """Calculate booking completion rate"""
    try:
        if salon:
            total = Booking.objects.filter(salon=salon).exclude(status='CANCELLED').count()
            completed = Booking.objects.filter(salon=salon, status='COMPLETED').count()
        else:
            total = Booking.objects.exclude(status='CANCELLED').count()
            completed = Booking.objects.filter(status='COMPLETED').count()
        
        if total == 0:
            return 0
        
        return round((completed / total) * 100, 2)
    except:
        return 0