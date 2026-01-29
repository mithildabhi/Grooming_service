from rest_framework import serializers
from .models import Salon

class SalonSerializer(serializers.ModelSerializer):
    owner_email = serializers.EmailField(source='owner.email', read_only=True)
    owner_id = serializers.IntegerField(source='owner.id', read_only=True)
    
    # ✅ Use CharField instead of URLField to accept any text (NA, empty, or URLs)
    image_url = serializers.CharField(
        required=False, 
        allow_blank=True, 
        max_length=500,
        default=''
    )
    
    # ✅ NEW: Add full_address property
    full_address = serializers.ReadOnlyField()
    
    class Meta:
        model = Salon
        fields = [
            'id',
            'owner',
            'owner_id',
            'owner_email',
            'name',
            'salon_type',
            'address',
            'city',           # ✅ NEW
            'state',          # ✅ NEW
            'pincode',        # ✅ NEW
            'full_address',   # ✅ NEW (computed)
            'phone',
            'about',
            'image_url',
            'hours',
            'latitude',       # ✅ NEW
            'longitude',      # ✅ NEW
            'rating',
            'is_open',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id', 
            'owner', 
            'owner_id', 
            'owner_email', 
            'rating', 
            'full_address',
            'created_at', 
            'updated_at'
        ]
    
    def validate_phone(self, value):
        """Validate phone number - allow + and digits"""
        if not value:
            raise serializers.ValidationError("Phone is required")
        
        # Remove spaces and + for validation
        clean_phone = value.replace(' ', '').replace('+', '').replace('-', '').replace('(', '').replace(')', '')
        
        if not clean_phone.isdigit():
            raise serializers.ValidationError("Phone must contain only digits and + - ( )")
        
        if len(clean_phone) < 10:
            raise serializers.ValidationError("Phone must be at least 10 digits")
        
        return value
    
    def validate_image_url(self, value):
        """Clean image URL - convert placeholder text to empty string"""
        if not value:
            return ''
        
        # Convert common placeholder values to empty string
        placeholder_values = ['na', 'n/a', 'null', 'none', 'nil', '-']
        if value.lower().strip() in placeholder_values:
            return ''
        
        return value.strip()
    
    def validate_hours(self, value):
        """Validate working hours format"""
        if not isinstance(value, dict):
            raise serializers.ValidationError("Hours must be a dictionary")
        
        # Accept both formats: "Mon" and "monday"
        valid_days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
                      'monday', 'tuesday', 'wednesday', 'thursday', 
                      'friday', 'saturday', 'sunday']
        
        for day in value.keys():
            if day not in valid_days:
                raise serializers.ValidationError(f"Invalid day: {day}")
        
        return value
    
    def validate_city(self, value):
        """Normalize city name"""
        if value:
            # Capitalize first letter of each word
            return value.strip().title()
        return ''
    
    def validate_state(self, value):
        """Normalize state name"""
        if value:
            return value.strip().title()
        return ''
    
    def create(self, validated_data):
        """Override create to handle owner assignment"""
        # owner is set in the view via save(owner=request.user)
        return super().create(validated_data)
    
    def update(self, instance, validated_data):
        """Override update to handle partial updates"""
        return super().update(instance, validated_data)


class SalonListSerializer(serializers.ModelSerializer):
    """
    Lightweight serializer for salon list view
    Used when returning multiple salons to reduce payload size
    """
    full_address = serializers.ReadOnlyField()
    
    class Meta:
        model = Salon
        fields = [
            'id',
            'name',
            'salon_type',
            'address',
            'city',
            'state',
            'pincode',
            'full_address',
            'phone',
            'image_url',
            'rating',
            'is_open',
        ]