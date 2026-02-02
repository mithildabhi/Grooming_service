# reviews/models.py
# 🌟 COMPLETE E-COMMERCE-STYLE REVIEW SYSTEM

from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils import timezone
from django.db.models import Avg, Count, Q
from accounts.models import User
from salons.models import Salon
from services.models import Service
from bookings.models import Booking


class Review(models.Model):
    """
    Complete review system supporting:
    - Salon reviews (overall experience)
    - Service-specific reviews
    - Staff reviews (via booking)
    - Verified purchase reviews (booking-linked)
    """
    
    # Core Relationships
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='reviews'
    )
    
    salon = models.ForeignKey(
        Salon,
        on_delete=models.CASCADE,
        related_name='reviews'
    )
    
    # Optional: Link to specific service reviewed
    service = models.ForeignKey(
        Service,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='reviews',
        help_text="Specific service being reviewed"
    )
    
    # Optional: Link to booking (verified review)
    booking = models.OneToOneField(
        Booking,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='review',
        help_text="Booking this review is for (ensures verified reviews)"
    )
    
    # Review Content
    rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        help_text="Overall rating (1-5 stars)"
    )
    
    title = models.CharField(
        max_length=200,
        blank=True,
        help_text="Review title/summary"
    )
    
    comment = models.TextField(
        help_text="Detailed review text"
    )
    
    # Detailed Ratings (Optional)
    service_quality_rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        null=True,
        blank=True,
        help_text="Service quality rating"
    )
    
    staff_behavior_rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        null=True,
        blank=True,
        help_text="Staff behavior rating"
    )
    
    ambiance_rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        null=True,
        blank=True,
        help_text="Ambiance/atmosphere rating"
    )
    
    value_for_money_rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        null=True,
        blank=True,
        help_text="Value for money rating"
    )
    
    # Review Status
    is_verified = models.BooleanField(
        default=False,
        help_text="Verified review (linked to actual booking)"
    )
    
    is_approved = models.BooleanField(
        default=True,
        help_text="Admin approved (for moderation)"
    )
    
    is_edited = models.BooleanField(
        default=False,
        help_text="Review was edited after posting"
    )
    
    # Salon Owner Response
    owner_reply = models.TextField(
        blank=True,
        help_text="Salon owner's response to review"
    )
    
    owner_replied_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text="When owner replied"
    )
    
    # Helpfulness Tracking
    helpful_count = models.IntegerField(
        default=0,
        help_text="Number of users who found this helpful"
    )
    
    not_helpful_count = models.IntegerField(
        default=0,
        help_text="Number of users who didn't find this helpful"
    )
    
    # Images (Optional - for future enhancement)
    images = models.JSONField(
        default=list,
        blank=True,
        help_text="Review images URLs"
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Review'
        verbose_name_plural = 'Reviews'
        indexes = [
            models.Index(fields=['salon', '-created_at']),
            models.Index(fields=['service', '-created_at']),
            models.Index(fields=['user']),
            models.Index(fields=['is_approved', '-created_at']),
            models.Index(fields=['rating']),
        ]
        constraints = [
            # Prevent duplicate reviews for same booking
            models.UniqueConstraint(
                fields=['booking'],
                condition=Q(booking__isnull=False),
                name='unique_review_per_booking'
            )
        ]
    
    def __str__(self):
        return f"{self.user.get_full_name()} - {self.salon.name} ({self.rating}⭐)"
    
    def save(self, *args, **kwargs):
        # Auto-verify if linked to booking
        if self.booking:
            self.is_verified = True
            if not self.service:
                self.service = self.booking.service
        
        # Save first
        super().save(*args, **kwargs)
        
        # Then update salon rating (after save to ensure ID exists)
        try:
            self.update_salon_rating()
        except Exception as e:
            print(f"❌ Error updating salon rating: {e}")

    
    def update_salon_rating(self):
        """Update salon's average rating after review save"""
        try:
            from django.db.models import Avg
            
            # Calculate average of approved reviews
            avg_data = Review.objects.filter(
                salon=self.salon,
                is_approved=True
            ).aggregate(
                avg_rating=Avg('rating'),
                count=Count('id')
            )
            
            avg_rating = avg_data['avg_rating']
            count = avg_data['count']
            
            if avg_rating is not None:
                # Round to 1 decimal place
                self.salon.rating = round(avg_rating, 1)
                self.salon.save(update_fields=['rating'])
                
                print(f"✅ Updated {self.salon.name} rating: {self.salon.rating} ({count} reviews)")
            else:
                # No reviews, reset to 0
                self.salon.rating = 0.0
                self.salon.save(update_fields=['rating'])
                
        except Exception as e:
            print(f"❌ Error in update_salon_rating: {e}")
            import traceback
            traceback.print_exc()
    
    @property
    def user_name(self):
        """Get reviewer's display name"""
        return self.user.get_full_name() or self.user.email.split('@')[0]
    
    @property
    def user_initial(self):
        """Get user's initial for avatar"""
        name = self.user_name
        return name[0].upper() if name else '?'
    
    @property
    def time_since_review(self):
        """Human-readable time since review"""
        delta = timezone.now() - self.created_at
        
        if delta.days > 365:
            years = delta.days // 365
            return f"{years} year{'s' if years > 1 else ''} ago"
        elif delta.days > 30:
            months = delta.days // 30
            return f"{months} month{'s' if months > 1 else ''} ago"
        elif delta.days > 0:
            return f"{delta.days} day{'s' if delta.days > 1 else ''} ago"
        elif delta.seconds > 3600:
            hours = delta.seconds // 3600
            return f"{hours} hour{'s' if hours > 1 else ''} ago"
        elif delta.seconds > 60:
            minutes = delta.seconds // 60
            return f"{minutes} minute{'s' if minutes > 1 else ''} ago"
        else:
            return "Just now"
    
    @property
    def helpfulness_score(self):
        """Calculate helpfulness percentage"""
        total = self.helpful_count + self.not_helpful_count
        if total == 0:
            return 0
        return int((self.helpful_count / total) * 100)


class ReviewHelpfulness(models.Model):
    """Track which users found reviews helpful"""
    review = models.ForeignKey(
        Review,
        on_delete=models.CASCADE,
        related_name='helpfulness_votes'
    )
    
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='review_votes'
    )
    
    is_helpful = models.BooleanField(
        help_text="True if helpful, False if not helpful"
    )
    
    voted_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ['review', 'user']
        verbose_name = 'Review Helpfulness Vote'
        verbose_name_plural = 'Review Helpfulness Votes'
    
    def __str__(self):
        vote = "Helpful" if self.is_helpful else "Not Helpful"
        return f"{self.user.email} - {vote}"


class ReviewReport(models.Model):
    """Allow users to report inappropriate reviews"""
    
    REPORT_REASONS = [
        ('spam', 'Spam or fake review'),
        ('offensive', 'Offensive language'),
        ('irrelevant', 'Irrelevant content'),
        ('personal', 'Personal information'),
        ('duplicate', 'Duplicate review'),
        ('other', 'Other reason'),
    ]
    
    review = models.ForeignKey(
        Review,
        on_delete=models.CASCADE,
        related_name='reports'
    )
    
    reported_by = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='review_reports'
    )
    
    reason = models.CharField(
        max_length=20,
        choices=REPORT_REASONS
    )
    
    description = models.TextField(
        blank=True,
        help_text="Additional details"
    )
    
    is_resolved = models.BooleanField(default=False)
    resolved_at = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ['review', 'reported_by']
        verbose_name = 'Review Report'
        verbose_name_plural = 'Review Reports'
    
    def __str__(self):
        return f"Report: {self.review.id} - {self.reason}"