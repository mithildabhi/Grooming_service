# bookings/views.py - ENHANCED VERSION

from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.core.exceptions import ValidationError
from datetime import datetime, timedelta, time
from django.utils import timezone

from services.models import Service
from .models import Booking, TimeSlot, BookingBlockout
from .serializers import BookingSerializer, TimeSlotSerializer
from staff.models import Employee
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import TimeSlot, BookingBlockout
from .serializers import TimeSlotSerializer, BookingBlockoutSerializer

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def booking_list(request):
    """Get bookings based on user role"""
    user = request.user

    if user.role == 'CUSTOMER':
        bookings = Booking.objects.filter(user=user)

    elif user.role == 'EMPLOYEE':
        employee = Employee.objects.get(user=user)
        bookings = Booking.objects.filter(staff=employee)

    elif user.role == 'SALON_OWNER':
        bookings = Booking.objects.filter(salon__owner=user)

    else:  # SUPER_ADMIN
        bookings = Booking.objects.all()

    # Optional filters
    date = request.query_params.get('date')
    status_filter = request.query_params.get('status')
    staff_id = request.query_params.get('staff')
    
    if date:
        bookings = bookings.filter(booking_date=date)
    if status_filter:
        bookings = bookings.filter(status=status_filter)
    if staff_id:
        bookings = bookings.filter(staff_id=staff_id)

    bookings = bookings.select_related('service', 'staff', 'salon', 'user').order_by('-booking_date', '-booking_time')
    
    serializer = BookingSerializer(bookings, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_booking(request):
    """
    Create a new booking with automatic validation
    ✅ Auto-accepts bookings
    ✅ Prevents time overlaps
    ✅ Assigns available staff
    """
    try:
        data = request.data.copy()
        
        # Get service to calculate duration
        service = Service.objects.get(id=data['service'])
        salon = service.salon
        
        # Parse booking date and time
        booking_date = datetime.strptime(data['booking_date'], '%Y-%m-%d').date()
        booking_time = datetime.strptime(data['booking_time'], '%H:%M:%S').time()
        
        # Calculate end time
        start_datetime = datetime.combine(booking_date, booking_time)
        end_datetime = start_datetime + timedelta(minutes=service.duration)
        end_time = end_datetime.time()
        
        # ✅ Find available staff for this slot
        staff_id = data.get('staff')
        if not staff_id:
            # Auto-assign available staff
            staff_id = find_available_staff(
                salon, 
                booking_date, 
                booking_time, 
                end_time,
                service
            )
            if not staff_id:
                return Response({
                    'error': 'No staff available for this time slot',
                    'message': 'Please choose a different time or date'
                }, status=status.HTTP_400_BAD_REQUEST)
            data['staff'] = staff_id
        else:
            # Validate chosen staff is available
            is_available = check_staff_availability(
                staff_id,
                booking_date,
                booking_time,
                end_time
            )
            if not is_available:
                return Response({
                    'error': 'Selected staff is not available for this time slot',
                    'message': 'Please choose a different staff member or time'
                }, status=status.HTTP_400_BAD_REQUEST)
        
        # Set additional fields
        data['user'] = request.user.id
        data['salon'] = salon.id
        data['end_time'] = end_time.strftime('%H:%M:%S')
        data['status'] = 'CONFIRMED'  # ✅ Auto-accept
        
        # Set customer details from user if not provided
        if not data.get('customer_name'):
            data['customer_name'] = request.user.get_full_name() or request.user.email
        if not data.get('customer_phone'):
            data['customer_phone'] = getattr(request.user, 'phone', '')
        
        serializer = BookingSerializer(data=data)
        if serializer.is_valid():
            booking = serializer.save()
            
            # TODO: Send confirmation SMS/Email
            # send_booking_confirmation(booking)
            
            return Response({
                'message': 'Booking confirmed successfully! ✅',
                'booking': serializer.data
            }, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
    except Service.DoesNotExist:
        return Response({
            'error': 'Service not found'
        }, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({
            'error': f'Booking failed: {str(e)}'
        }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def update_booking_status(request, pk):
    """Update booking status"""
    try:
        booking = Booking.objects.get(pk=pk)
    except Booking.DoesNotExist:
        return Response({'error': 'Booking not found'}, status=status.HTTP_404_NOT_FOUND)

    # Check permissions
    if request.user.role not in ['EMPLOYEE', 'SALON_OWNER', 'SUPER_ADMIN']:
        return Response({'detail': 'Not allowed'}, status=status.HTTP_403_FORBIDDEN)

    new_status = request.data.get('status', booking.status)
    booking.status = new_status
    booking.save()
    
    return Response({
        'message': f'Booking status updated to {new_status}',
        'booking': BookingSerializer(booking).data
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def available_slots(request):
    """
    Get available time slots for a specific date and service
    
    Query params:
    - date: YYYY-MM-DD
    - service_id: Service ID
    - staff_id: (optional) Specific staff member
    """
    try:
        date_str = request.query_params.get('date')
        service_id = request.query_params.get('service_id')
        staff_id = request.query_params.get('staff_id')
        
        if not date_str or not service_id:
            return Response({
                'error': 'date and service_id are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        booking_date = datetime.strptime(date_str, '%Y-%m-%d').date()
        service = Service.objects.get(id=service_id)
        salon = service.salon
        
        # Get salon operating hours for this day
        day_of_week = booking_date.weekday()
        time_slots = TimeSlot.objects.filter(
            salon=salon,
            day_of_week=day_of_week,
            is_active=True
        )
        
        if not time_slots.exists():
            # Default hours if not configured
            time_slots = [{
                'start_time': time(9, 0),
                'end_time': time(20, 0)
            }]
        else:
            time_slots = [
                {
                    'start_time': slot.start_time,
                    'end_time': slot.end_time
                }
                for slot in time_slots
            ]
        
        # Generate all possible slots (every 15 minutes)
        all_slots = []
        for slot_range in time_slots:
            current_time = datetime.combine(booking_date, slot_range['start_time'])
            end_time = datetime.combine(booking_date, slot_range['end_time'])
            
            while current_time < end_time:
                slot_end = current_time + timedelta(minutes=service.duration)
                
                # Check if slot fits within operating hours
                if slot_end.time() <= slot_range['end_time']:
                    all_slots.append({
                        'start_time': current_time.time().strftime('%H:%M'),
                        'end_time': slot_end.time().strftime('%H:%M'),
                        'available': True
                    })
                
                current_time += timedelta(minutes=15)  # 15-minute intervals
        
        # Check which slots are available
        if staff_id:
            staff_list = [staff_id]
        else:
            # Get all active staff for this salon
            staff_list = Employee.objects.filter(
                salon=salon,
                is_active=True
            ).values_list('id', flat=True)
        
        # Mark unavailable slots
        for slot in all_slots:
            slot_time = datetime.strptime(slot['start_time'], '%H:%M').time()
            slot_end = datetime.strptime(slot['end_time'], '%H:%M').time()
            
            # Check if any staff is available
            available_staff_count = 0
            for sid in staff_list:
                if check_staff_availability(sid, booking_date, slot_time, slot_end):
                    available_staff_count += 1
            
            slot['available'] = available_staff_count > 0
            slot['available_staff_count'] = available_staff_count
        
        return Response({
            'date': date_str,
            'service': service.name,
            'duration': service.duration,
            'slots': all_slots
        })
        
    except Service.DoesNotExist:
        return Response({'error': 'Service not found'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


# =================== HELPER FUNCTIONS ===================

def find_available_staff(salon, date, start_time, end_time, service):
    """
    Find first available staff member for the time slot
    Returns staff ID or None
    """
    # Get all active staff for this salon
    staff_members = Employee.objects.filter(
        salon=salon,
        is_active=True
    )
    
    # Optionally: Filter by staff skill matching service
    # staff_members = staff_members.filter(primary_skill=service.category)
    
    for staff in staff_members:
        if check_staff_availability(staff.id, date, start_time, end_time):
            return staff.id
    
    return None


def check_staff_availability(staff_id, date, start_time, end_time):
    """
    Check if staff member is available for the given time slot
    Returns True if available, False otherwise
    """
    # Check for existing bookings
    overlapping_bookings = Booking.objects.filter(
        staff_id=staff_id,
        booking_date=date,
        status__in=['CONFIRMED', 'PENDING']
    )
    
    for booking in overlapping_bookings:
        # Check if times overlap
        if not (end_time <= booking.booking_time or start_time >= booking.end_time):
            return False
    
    # Check for blockouts (staff leave, holidays)
    blockouts = BookingBlockout.objects.filter(
        staff_id=staff_id,
        start_date__lte=date,
        end_date__gte=date,
        is_active=True
    )
    
    for blockout in blockouts:
        # If blockout has specific times
        if blockout.start_time and blockout.end_time:
            if not (end_time <= blockout.start_time or start_time >= blockout.end_time):
                return False
        else:
            # Entire day blocked
            return False
    
    return True


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def booking_statistics(request):
    """Get booking statistics for salon owner"""
    if request.user.role != 'SALON_OWNER':
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
    
    salon = request.user.salon
    today = timezone.now().date()
    
    stats = {
        'today': {
            'total': Booking.objects.filter(salon=salon, booking_date=today).count(),
            'confirmed': Booking.objects.filter(salon=salon, booking_date=today, status='CONFIRMED').count(),
            'completed': Booking.objects.filter(salon=salon, booking_date=today, status='COMPLETED').count(),
            'cancelled': Booking.objects.filter(salon=salon, booking_date=today, status='CANCELLED').count(),
        },
        'this_week': {
            'total': Booking.objects.filter(
                salon=salon,
                booking_date__gte=today - timedelta(days=today.weekday()),
                booking_date__lte=today
            ).count()
        },
        'this_month': {
            'total': Booking.objects.filter(
                salon=salon,
                booking_date__year=today.year,
                booking_date__month=today.month
            ).count()
        }
    }
    
    return Response(stats)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def time_slot_list(request):
    """Get salon's time slots (operating hours)"""
    if request.user.role != 'SALON_OWNER':
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
    
    salon = request.user.salon
    time_slots = TimeSlot.objects.filter(salon=salon).order_by('day_of_week', 'start_time')
    
    serializer = TimeSlotSerializer(time_slots, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def time_slot_create(request):
    """Create new time slot (operating hours)"""
    if request.user.role != 'SALON_OWNER':
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
    
    data = request.data.copy()
    data['salon'] = request.user.salon.id
    
    serializer = TimeSlotSerializer(data=data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([IsAuthenticated])
def time_slot_detail(request, pk):
    """Manage individual time slot"""
    if request.user.role != 'SALON_OWNER':
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
    
    try:
        time_slot = TimeSlot.objects.get(pk=pk, salon=request.user.salon)
    except TimeSlot.DoesNotExist:
        return Response({'error': 'Time slot not found'}, status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'GET':
        serializer = TimeSlotSerializer(time_slot)
        return Response(serializer.data)
    
    elif request.method == 'PUT':
        serializer = TimeSlotSerializer(time_slot, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        time_slot.delete()
        return Response({'message': 'Time slot deleted'}, status=status.HTTP_200_OK)


# =================== BLOCKOUT MANAGEMENT ===================

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def blockout_list(request):
    """Get blockouts (holidays, staff leave)"""
    if request.user.role != 'SALON_OWNER':
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
    
    salon = request.user.salon
    blockouts = BookingBlockout.objects.filter(salon=salon, is_active=True).order_by('-start_date')
    
    serializer = BookingBlockoutSerializer(blockouts, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def blockout_create(request):
    """Create new blockout"""
    if request.user.role != 'SALON_OWNER':
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
    
    data = request.data.copy()
    data['salon'] = request.user.salon.id
    
    serializer = BookingBlockoutSerializer(data=data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([IsAuthenticated])
def blockout_detail(request, pk):
    """Manage individual blockout"""
    if request.user.role != 'SALON_OWNER':
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
    
    try:
        blockout = BookingBlockout.objects.get(pk=pk, salon=request.user.salon)
    except BookingBlockout.DoesNotExist:
        return Response({'error': 'Blockout not found'}, status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'GET':
        serializer = BookingBlockoutSerializer(blockout)
        return Response(serializer.data)
    
    elif request.method == 'PUT':
        serializer = BookingBlockoutSerializer(blockout, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        blockout.is_active = False
        blockout.save()
        return Response({'message': 'Blockout removed'}, status=status.HTTP_200_OK)