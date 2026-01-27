from rest_framework import serializers
from .models import Customer
from bookings.models import Booking


class CustomerProfileSerializer(serializers.ModelSerializer):
    """
    Serializer for Customer Profile GET requests
    Includes computed statistics fields that Flutter expects
    """
    # User fields (read-only)
    user = serializers.CharField(source='user.id', read_only=True)  # ✅ Add user ID
    email = serializers.EmailField(source='user.email', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    
    # ✅ Statistics fields (computed properties from model)
    total_bookings = serializers.IntegerField(read_only=True)
    completed_bookings = serializers.IntegerField(read_only=True)
    upcoming_bookings = serializers.IntegerField(read_only=True)
    cancelled_bookings = serializers.IntegerField(read_only=True)
    total_spent = serializers.FloatField(read_only=True)
    average_booking_value = serializers.FloatField(read_only=True)
    loyalty_tier = serializers.CharField(read_only=True)
    
    class Meta:
        model = Customer
        fields = [
            'user',  # ✅ Flutter expects this
            'email',  # READ-ONLY
            'username',
            'full_name',
            'phone',
            'address',
            'city',
            'pincode',
            'gender',
            'date_of_birth',
            'profile_picture',
            'is_verified',
            # ✅ Statistics
            'total_bookings',
            'completed_bookings',
            'upcoming_bookings',
            'cancelled_bookings',
            'total_spent',
            'average_booking_value',
            'loyalty_tier',
            # Metadata
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'user',
            'email', 
            'username', 
            'is_verified',
            'total_bookings',
            'completed_bookings',
            'upcoming_bookings',
            'cancelled_bookings',
            'total_spent',
            'average_booking_value',
            'loyalty_tier',
            'created_at', 
            'updated_at'
        ]


class CustomerProfileUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer for Customer Profile UPDATE requests
    Only includes fields that can be modified
    """
    class Meta:
        model = Customer
        fields = [
            'full_name',
            'phone',
            'address',
            'city',
            'pincode',
            'gender',
            'date_of_birth',
        ]
    
    def validate_phone(self, value):
        """Validate phone number format"""
        if value and len(value) < 10:
            raise serializers.ValidationError("Phone number must be at least 10 digits")
        return value
    
    def validate_pincode(self, value):
        """Validate pincode format"""
        if value and (len(value) < 5 or len(value) > 10):
            raise serializers.ValidationError("Invalid pincode format")
        return value
    
    def validate_date_of_birth(self, value):
        """Validate date of birth"""
        if value:
            from datetime import date
            today = date.today()
            age = today.year - value.year - ((today.month, today.day) < (value.month, value.day))
            if age < 13:
                raise serializers.ValidationError("Must be at least 13 years old")
            if age > 120:
                raise serializers.ValidationError("Invalid date of birth")
        return value


class CustomerStatisticsSerializer(serializers.ModelSerializer):
    """
    Serializer for Customer Statistics - read-only computed fields
    """
    # User info
    email = serializers.EmailField(source='user.email', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    
    # Statistics (computed properties from model)
    total_bookings = serializers.IntegerField(read_only=True)
    completed_bookings = serializers.IntegerField(read_only=True)
    upcoming_bookings = serializers.IntegerField(read_only=True)
    cancelled_bookings = serializers.IntegerField(read_only=True)
    total_spent = serializers.FloatField(read_only=True)
    average_booking_value = serializers.FloatField(read_only=True)
    loyalty_tier = serializers.CharField(read_only=True)
    
    # Favorites
    favorite_salon = serializers.DictField(read_only=True)
    favorite_service = serializers.DictField(read_only=True)
    
    class Meta:
        model = Customer
        fields = [
            'email',
            'username',
            'full_name',
            'total_bookings',
            'completed_bookings',
            'upcoming_bookings',
            'cancelled_bookings',
            'total_spent',
            'average_booking_value',
            'loyalty_tier',
            'favorite_salon',
            'favorite_service',
        ]


class CustomerBookingSerializer(serializers.ModelSerializer):
    """
    Serializer for Customer's Booking History - nested salon and service info
    """
    salon_name = serializers.CharField(source='salon.name', read_only=True)
    salon_address = serializers.CharField(source='salon.address', read_only=True)
    salon_image = serializers.CharField(source='salon.image', read_only=True)
    
    service_name = serializers.CharField(source='service.name', read_only=True)
    service_description = serializers.CharField(source='service.description', read_only=True)
    
    staff_name = serializers.CharField(source='staff.full_name', read_only=True, allow_null=True)
    
    # Format date and time for Flutter
    date = serializers.DateField(source='booking_date', format='%Y-%m-%d')
    time = serializers.TimeField(source='booking_time', format='%H:%M')
    
    duration_minutes = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Booking
        fields = [
            'id',
            'salon_name',
            'salon_address',
            'salon_image',
            'service_name',
            'service_description',
            'staff_name',
            'date',
            'time',
            'duration_minutes',
            'price',
            'status',
            'customer_name',
            'customer_phone',
            'notes',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class CustomerBookingDetailSerializer(serializers.ModelSerializer):
    """
    Detailed serializer for single booking view
    """
    salon = serializers.SerializerMethodField()
    service = serializers.SerializerMethodField()
    staff = serializers.SerializerMethodField()
    
    date = serializers.DateField(source='booking_date', format='%Y-%m-%d')
    time = serializers.TimeField(source='booking_time', format='%H:%M')
    duration_minutes = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Booking
        fields = [
            'id',
            'salon',
            'service',
            'staff',
            'date',
            'time',
            'duration_minutes',
            'price',
            'status',
            'customer_name',
            'customer_phone',
            'notes',
            'created_at',
            'updated_at',
        ]
    
    def get_salon(self, obj):
        return {
            'id': obj.salon.id,
            'name': obj.salon.name,
            'address': obj.salon.address,
            'phone': obj.salon.phone,
            'image': obj.salon.image if hasattr(obj.salon, 'image') else None,
        }
    
    def get_service(self, obj):
        return {
            'id': obj.service.id,
            'name': obj.service.name,
            'description': obj.service.description,
            'price': float(obj.service.price),
            'duration': obj.service.duration,
        }
    
    def get_staff(self, obj):
        if obj.staff:
            return {
                'id': obj.staff.id,
                'full_name': obj.staff.full_name,
                'specialization': obj.staff.specialization if hasattr(obj.staff, 'specialization') else None,
            }
        return None


class CustomerDashboardSerializer(serializers.ModelSerializer):
    """
    Complete dashboard serializer - combines profile and statistics
    """
    # Profile fields
    email = serializers.EmailField(source='user.email', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    
    # Statistics
    statistics = serializers.SerializerMethodField()
    
    # Recent bookings
    recent_bookings = serializers.SerializerMethodField()
    
    class Meta:
        model = Customer
        fields = [
            'email',
            'username',
            'full_name',
            'phone',
            'address',
            'city',
            'pincode',
            'gender',
            'date_of_birth',
            'profile_picture',
            'is_verified',
            'statistics',
            'recent_bookings',
            'created_at',
        ]
    
    def get_statistics(self, obj):
        return {
            'total_bookings': obj.total_bookings,
            'completed_bookings': obj.completed_bookings,
            'upcoming_bookings': obj.upcoming_bookings,
            'cancelled_bookings': obj.cancelled_bookings,
            'total_spent': obj.total_spent,
            'average_booking_value': obj.average_booking_value,
            'loyalty_tier': obj.loyalty_tier,
            'favorite_salon': obj.favorite_salon,
            'favorite_service': obj.favorite_service,
        }
    
    def get_recent_bookings(self, obj):
        recent = obj.get_booking_history(limit=5)
        return CustomerBookingSerializer(recent, many=True).data