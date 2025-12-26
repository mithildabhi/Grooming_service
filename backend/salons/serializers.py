from rest_framework import serializers
from .models import Salon

class SalonSerializer(serializers.ModelSerializer):
    owner_email = serializers.EmailField(source='owner.email', read_only=True)
    
    class Meta:
        model = Salon
        fields = [
            'id',
            'owner',
            'owner_email',
            'name',
            'salon_type',
            'address',
            'phone',
            'about',
            'image_url',
            'hours',
            'rating',
            'is_open',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['owner', 'rating', 'created_at', 'updated_at']
    
    def validate_phone(self, value):
        """Validate phone number"""
        if not value.isdigit():
            raise serializers.ValidationError("Phone must contain only digits")
        if len(value) < 10:
            raise serializers.ValidationError("Phone must be at least 10 digits")
        return value
    
    def validate_hours(self, value):
        """Validate working hours format"""
        if not isinstance(value, dict):
            raise serializers.ValidationError("Hours must be a dictionary")
        
        valid_days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        for day in value.keys():
            if day not in valid_days:
                raise serializers.ValidationError(f"Invalid day: {day}")
        
        return value
