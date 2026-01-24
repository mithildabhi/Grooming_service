# bookings/serializers.py - ENHANCED VERSION

from rest_framework import serializers
from .models import Booking, TimeSlot, BookingBlockout
from services.models import Service
from staff.models import Employee


class BookingSerializer(serializers.ModelSerializer):
    service_name = serializers.CharField(source='service.name', read_only=True)
    service_duration = serializers.IntegerField(source='service.duration', read_only=True)
    service_price = serializers.DecimalField(source='service.price', max_digits=8, decimal_places=2, read_only=True)
    
    staff_name = serializers.CharField(source='staff.full_name', read_only=True)
    staff_role = serializers.CharField(source='staff.get_role_display', read_only=True)
    
    salon_name = serializers.CharField(source='salon.name', read_only=True)
    
    customer_email = serializers.EmailField(source='user.email', read_only=True)
    
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    
    class Meta:
        model = Booking
        fields = [
            'id',
            'user',
            'salon',
            'salon_name',
            'service',
            'service_name',
            'service_duration',
            'service_price',
            'staff',
            'staff_name',
            'staff_role',
            'booking_date',
            'booking_time',
            'end_time',
            'price',  # ✅ ADD PRICE FIELD
            'status',
            'status_display',
            'customer_name',
            'customer_phone',
            'customer_email',
            'notes',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['end_time', 'created_at', 'updated_at']


class TimeSlotSerializer(serializers.ModelSerializer):
    day_name = serializers.CharField(source='get_day_of_week_display', read_only=True)
    
    class Meta:
        model = TimeSlot
        fields = [
            'id',
            'salon',
            'day_of_week',
            'day_name',
            'start_time',
            'end_time',
            'is_active'
        ]


class BookingBlockoutSerializer(serializers.ModelSerializer):
    staff_name = serializers.CharField(source='staff.full_name', read_only=True, allow_null=True)
    
    class Meta:
        model = BookingBlockout
        fields = [
            'id',
            'salon',
            'staff',
            'staff_name',
            'start_date',
            'end_date',
            'start_time',
            'end_time',
            'reason',
            'is_active'
        ]


class BookingCreateSerializer(serializers.Serializer):
    """Simplified serializer for creating bookings from frontend"""
    service_id = serializers.IntegerField()
    booking_date = serializers.DateField()
    booking_time = serializers.TimeField()
    staff_id = serializers.IntegerField(required=False, allow_null=True)
    customer_name = serializers.CharField(required=False, allow_blank=True)
    customer_phone = serializers.CharField(required=False, allow_blank=True)
    notes = serializers.CharField(required=False, allow_blank=True)
    
    def validate(self, data):
        # Validate service exists
        try:
            service = Service.objects.get(id=data['service_id'])
            data['service'] = service
        except Service.DoesNotExist:
            raise serializers.ValidationError({'service_id': 'Service not found'})
        
        # Validate staff if provided
        if data.get('staff_id'):
            try:
                staff = Employee.objects.get(id=data['staff_id'])
                if staff.salon != service.salon:
                    raise serializers.ValidationError({'staff_id': 'Staff does not belong to this salon'})
                data['staff'] = staff
            except Employee.DoesNotExist:
                raise serializers.ValidationError({'staff_id': 'Staff member not found'})
        
        return data