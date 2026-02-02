# reviews/serializers.py
# 🌟 COMPLETE REVIEW SERIALIZERS - E-COMMERCE GRADE

from rest_framework import serializers
from .models import Review, ReviewHelpfulness, ReviewReport
from accounts.models import User
from salons.models import Salon
from services.models import Service
from bookings.models import Booking


class ReviewerSerializer(serializers.ModelSerializer):
    """Minimal user info for reviews (privacy-conscious)"""
    display_name = serializers.SerializerMethodField()
    initial = serializers.SerializerMethodField()
    total_reviews = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = ['id', 'display_name', 'initial', 'total_reviews']
    
    def get_display_name(self, obj):
        """Get display name without exposing email"""
        if hasattr(obj, 'customer_profile') and obj.customer_profile.full_name:
            return obj.customer_profile.full_name
        # Mask email: john.doe@gmail.com -> j***e@gmail.com
        email = obj.email
        parts = email.split('@')
        if len(parts[0]) > 2:
            masked = parts[0][0] + '***' + parts[0][-1]
        else:
            masked = parts[0][0] + '***'
        return f"{masked}@{parts[1]}"
    
    def get_initial(self, obj):
        """Get first letter for avatar"""
        if hasattr(obj, 'customer_profile') and obj.customer_profile.full_name:
            return obj.customer_profile.full_name[0].upper()
        return obj.email[0].upper()
    
    def get_total_reviews(self, obj):
        """Total reviews by this user"""
        return obj.reviews.filter(is_approved=True).count()


class ServiceMiniSerializer(serializers.ModelSerializer):
    """Minimal service info for reviews"""
    class Meta:
        model = Service
        fields = ['id', 'name', 'category', 'price']


class ReviewListSerializer(serializers.ModelSerializer):
    """List view of reviews - lightweight"""
    user = ReviewerSerializer(read_only=True)
    service = ServiceMiniSerializer(read_only=True)
    time_ago = serializers.CharField(source='time_since_review', read_only=True)
    helpfulness_percentage = serializers.IntegerField(source='helpfulness_score', read_only=True)
    has_owner_reply = serializers.SerializerMethodField()
    user_voted = serializers.SerializerMethodField()
    
    class Meta:
        model = Review
        fields = [
            'id',
            'user',
            'service',
            'rating',
            'title',
            'comment',
            'is_verified',
            'is_edited',
            'has_owner_reply',
            'helpful_count',
            'not_helpful_count',
            'helpfulness_percentage',
            'time_ago',
            'created_at',
            'user_voted',
        ]
    
    def get_has_owner_reply(self, obj):
        return bool(obj.owner_reply)
    
    def get_user_voted(self, obj):
        """Check if current user voted on this review"""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                vote = ReviewHelpfulness.objects.get(
                    review=obj,
                    user=request.user
                )
                return 'helpful' if vote.is_helpful else 'not_helpful'
            except ReviewHelpfulness.DoesNotExist:
                return None
        return None


class ReviewDetailSerializer(serializers.ModelSerializer):
    """Detailed view of a single review"""
    user = ReviewerSerializer(read_only=True)
    service = ServiceMiniSerializer(read_only=True)
    time_ago = serializers.CharField(source='time_since_review', read_only=True)
    helpfulness_percentage = serializers.IntegerField(source='helpfulness_score', read_only=True)
    salon_name = serializers.CharField(source='salon.name', read_only=True)
    user_voted = serializers.SerializerMethodField()
    
    class Meta:
        model = Review
        fields = [
            'id',
            'user',
            'salon_name',
            'service',
            'rating',
            'title',
            'comment',
            # Detailed ratings
            'service_quality_rating',
            'staff_behavior_rating',
            'ambiance_rating',
            'value_for_money_rating',
            # Status
            'is_verified',
            'is_edited',
            # Owner reply
            'owner_reply',
            'owner_replied_at',
            # Helpfulness
            'helpful_count',
            'not_helpful_count',
            'helpfulness_percentage',
            # Media
            'images',
            # Timestamps
            'time_ago',
            'created_at',
            'updated_at',
            'user_voted',
        ]
    
    def get_user_voted(self, obj):
        """Check if current user voted on this review"""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                vote = ReviewHelpfulness.objects.get(
                    review=obj,
                    user=request.user
                )
                return 'helpful' if vote.is_helpful else 'not_helpful'
            except ReviewHelpfulness.DoesNotExist:
                return None
        return None


class ReviewCreateSerializer(serializers.ModelSerializer):
    """Create/update review"""
    booking_id = serializers.IntegerField(write_only=True, required=False, allow_null=True)
    service_id = serializers.IntegerField(write_only=True, required=False, allow_null=True)
    salon_id = serializers.IntegerField(write_only=True, required=False, allow_null=True)  # ✅ NEW
    
    class Meta:
        model = Review
        fields = [
            'rating',
            'title',
            'comment',
            # Detailed ratings (optional)
            'service_quality_rating',
            'staff_behavior_rating',
            'ambiance_rating',
            'value_for_money_rating',
            # Images
            'images',
            # IDs
            'booking_id',
            'service_id',
            'salon_id',  # ✅ NEW
        ]
    
    def validate_rating(self, value):
        if value < 1 or value > 5:
            raise serializers.ValidationError("Rating must be between 1 and 5")
        return value
    
    def validate(self, data):
        """Validate review data"""
        # Must have booking_id, service_id, or salon_id
        has_booking = data.get('booking_id')
        has_service = data.get('service_id')
        has_salon = data.get('salon_id')
        
        if not any([has_booking, has_service, has_salon]):
            raise serializers.ValidationError(
                "Either booking_id, service_id, or salon_id is required"
            )
        
        # Comment required for low ratings
        if data.get('rating', 5) <= 2 and not data.get('comment'):
            raise serializers.ValidationError(
                "Comment is required for ratings below 3 stars"
            )
        
        return data
    
    def create(self, validated_data):
        booking_id = validated_data.pop('booking_id', None)
        service_id = validated_data.pop('service_id', None)
        salon_id = validated_data.pop('salon_id', None)
        
        user = self.context['request'].user
        
        # Priority: booking > service > salon
        if booking_id:
            try:
                booking = Booking.objects.get(id=booking_id, user=user)
                
                # Check if already reviewed
                if hasattr(booking, 'review'):
                    raise serializers.ValidationError(
                        "You have already reviewed this booking"
                    )
                
                # Check if booking is completed
                if booking.status != 'COMPLETED':
                    raise serializers.ValidationError(
                        "You can only review completed bookings"
                    )
                
                validated_data['booking'] = booking
                validated_data['salon'] = booking.salon
                validated_data['service'] = booking.service
                
            except Booking.DoesNotExist:
                raise serializers.ValidationError("Booking not found")
        
        elif service_id:
            try:
                service = Service.objects.get(id=service_id)
                validated_data['service'] = service
                validated_data['salon'] = service.salon
            except Service.DoesNotExist:
                raise serializers.ValidationError("Service not found")
        
        elif salon_id:
            try:
                salon = Salon.objects.get(id=salon_id)
                validated_data['salon'] = salon
                # Service is optional for general salon reviews
            except Salon.DoesNotExist:
                raise serializers.ValidationError("Salon not found")
        
        validated_data['user'] = user
        
        # Create review
        review = Review.objects.create(**validated_data)
        
        return review


class ReviewUpdateSerializer(serializers.ModelSerializer):
    """Update existing review"""
    class Meta:
        model = Review
        fields = [
            'rating',
            'title',
            'comment',
            'service_quality_rating',
            'staff_behavior_rating',
            'ambiance_rating',
            'value_for_money_rating',
            'images',
        ]
    
    def update(self, instance, validated_data):
        instance.is_edited = True
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance


class OwnerReplySerializer(serializers.Serializer):
    """Salon owner reply to review"""
    reply = serializers.CharField(max_length=1000)
    
    def validate_reply(self, value):
        if not value or len(value.strip()) < 10:
            raise serializers.ValidationError(
                "Reply must be at least 10 characters"
            )
        return value.strip()


class ReviewHelpfulnessSerializer(serializers.Serializer):
    """Mark review as helpful/not helpful"""
    is_helpful = serializers.BooleanField()


class ReviewReportSerializer(serializers.ModelSerializer):
    """Report inappropriate review"""
    class Meta:
        model = ReviewReport
        fields = ['reason', 'description']
    
    def create(self, validated_data):
        validated_data['reported_by'] = self.context['request'].user
        return super().create(validated_data)


class ReviewStatsSerializer(serializers.Serializer):
    """Review statistics for a salon"""
    total_reviews = serializers.IntegerField()
    average_rating = serializers.FloatField()
    rating_distribution = serializers.DictField()
    verified_reviews_count = serializers.IntegerField()
    
    # Detailed averages
    avg_service_quality = serializers.FloatField()
    avg_staff_behavior = serializers.FloatField()
    avg_ambiance = serializers.FloatField()
    avg_value_for_money = serializers.FloatField()


class ServiceReviewStatsSerializer(serializers.Serializer):
    """Review statistics for a specific service"""
    service_id = serializers.IntegerField()
    service_name = serializers.CharField()
    total_reviews = serializers.IntegerField()
    average_rating = serializers.FloatField()
    rating_distribution = serializers.DictField()