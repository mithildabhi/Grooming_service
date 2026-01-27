from django.db import models
from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.core.validators import RegexValidator


class Customer(models.Model):
    """
    Customer Profile - Extends User model with customer-specific information
    Auto-created when a User with role='CUSTOMER' is created
    """
    
    GENDER_CHOICES = [
        ('MALE', 'Male'),
        ('FEMALE', 'Female'),
        ('OTHER', 'Other'),
        ('NOT_SPECIFIED', 'Not Specified'),
    ]
    
    # Link to User (OneToOne relationship)
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='customer_profile',
        primary_key=True
    )
    
    # Personal Information
    full_name = models.CharField(
        max_length=100,
        blank=True,
        help_text="Full name of the customer"
    )
    
    phone_regex = RegexValidator(
        regex=r'^\+?1?\d{9,15}$',
        message="Phone number must be entered in the format: '+999999999'. Up to 15 digits allowed."
    )
    phone = models.CharField(
        validators=[phone_regex],
        max_length=17,
        blank=True,
        help_text="Contact phone number"
    )
    
    # Address Information
    address = models.TextField(
        blank=True,
        help_text="Street address"
    )
    
    city = models.CharField(
        max_length=100,
        blank=True,
        help_text="City name"
    )
    
    pincode = models.CharField(
        max_length=10,
        blank=True,
        help_text="Postal/ZIP code"
    )
    
    # Personal Details
    gender = models.CharField(
        max_length=20,
        choices=GENDER_CHOICES,
        default='NOT_SPECIFIED',
        help_text="Gender"
    )
    
    date_of_birth = models.DateField(
        null=True,
        blank=True,
        help_text="Date of birth"
    )
    
    # Profile Picture
    profile_picture = models.ImageField(
        upload_to='customer_profiles/',
        null=True,
        blank=True,
        help_text="Customer profile picture"
    )
    
    # Preferences (for future AI recommendations)
    preferred_services = models.JSONField(
        default=list,
        blank=True,
        help_text="List of preferred service IDs"
    )
    
    preferred_salons = models.JSONField(
        default=list,
        blank=True,
        help_text="List of preferred salon IDs"
    )
    
    # Metadata
    is_verified = models.BooleanField(
        default=False,
        help_text="Phone/email verification status"
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Customer'
        verbose_name_plural = 'Customers'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['phone']),
            models.Index(fields=['city', 'pincode']),
        ]
    
    def __str__(self):
        # ✅ Show full name first, then email
        if self.full_name:
            return f"{self.full_name} - {self.user.email}"
        return f"{self.user.email}"
    
    # ========================================
    # EMAIL PROPERTY (Read-Only)
    # ========================================
    
    @property
    def email(self):
        """Get email from User - Read-only"""
        return self.user.email
    
    # ========================================
    # COMPUTED PROPERTIES (Statistics)
    # ========================================
    
    @property
    def total_bookings(self):
        """Total number of bookings made by customer"""
        return self.user.bookings.count()
    
    @property
    def completed_bookings(self):
        """Number of completed bookings"""
        return self.user.bookings.filter(status='COMPLETED').count()
    
    @property
    def upcoming_bookings(self):
        """Number of upcoming bookings (PENDING or CONFIRMED)"""
        return self.user.bookings.filter(
            status__in=['PENDING', 'CONFIRMED']
        ).count()
    
    @property
    def cancelled_bookings(self):
        """Number of cancelled bookings"""
        return self.user.bookings.filter(status='CANCELLED').count()
    
    @property
    def total_spent(self):
        """Total amount spent on completed bookings"""
        from django.db.models import Sum
        result = self.user.bookings.filter(
            status='COMPLETED'
        ).aggregate(
            total=Sum('price')
        )
        return float(result['total'] or 0)
    
    @property
    def average_booking_value(self):
        """Average value per completed booking"""
        completed = self.completed_bookings
        if completed == 0:
            return 0
        return self.total_spent / completed
    
    @property
    def favorite_salon(self):
        """Most frequently visited salon"""
        from django.db.models import Count
        
        favorite = self.user.bookings.filter(
            status='COMPLETED'
        ).values(
            'salon__id', 'salon__name'
        ).annotate(
            visit_count=Count('id')
        ).order_by('-visit_count').first()
        
        return favorite if favorite else None
    
    @property
    def favorite_service(self):
        """Most frequently booked service"""
        from django.db.models import Count
        
        favorite = self.user.bookings.filter(
            status='COMPLETED'
        ).values(
            'service__id', 'service__name'
        ).annotate(
            booking_count=Count('id')
        ).order_by('-booking_count').first()
        
        return favorite if favorite else None
    
    @property
    def loyalty_tier(self):
        """Calculate customer loyalty tier based on bookings"""
        completed = self.completed_bookings
        
        if completed >= 50:
            return 'PLATINUM'
        elif completed >= 25:
            return 'GOLD'
        elif completed >= 10:
            return 'SILVER'
        elif completed >= 3:
            return 'BRONZE'
        else:
            return 'NEW'
    
    def get_booking_history(self, status=None, limit=None):
        """Get customer's booking history"""
        bookings = self.user.bookings.select_related(
            'salon', 'service', 'staff'
        ).order_by('-booking_date', '-booking_time')
        
        if status:
            bookings = bookings.filter(status=status)
        
        if limit:
            bookings = bookings[:limit]
        
        return bookings
    
    def get_statistics_summary(self):
        """Get complete statistics summary"""
        return {
            'total_bookings': self.total_bookings,
            'completed_bookings': self.completed_bookings,
            'upcoming_bookings': self.upcoming_bookings,
            'cancelled_bookings': self.cancelled_bookings,
            'total_spent': self.total_spent,
            'average_booking_value': self.average_booking_value,
            'favorite_salon': self.favorite_salon,
            'favorite_service': self.favorite_service,
            'loyalty_tier': self.loyalty_tier,
        }


# ========================================
# SIGNALS - Auto-create Customer Profile
# ========================================

@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_customer_profile(sender, instance, created, **kwargs):
    """
    Automatically create a Customer profile when a User with role='CUSTOMER' is created
    ✅ IMPROVED: Better initial data handling
    """
    if created and instance.role == 'CUSTOMER':
        # Extract name from username or email
        full_name = instance.get_full_name() or instance.username
        if '@' in full_name:  # If username is email
            full_name = full_name.split('@')[0].replace('.', ' ').replace('_', ' ').title()
        
        Customer.objects.create(
            user=instance,
            full_name=full_name,
        )
        print(f"✅ Customer profile auto-created for {instance.username} ({instance.email})")
        print(f"   Initial full_name: {full_name}")


@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def ensure_customer_profile_exists(sender, instance, created, **kwargs):
    """
    Ensure Customer profile exists for users with CUSTOMER role
    This handles existing users who might not have a profile yet
    """
    if not created and instance.role == 'CUSTOMER':
        # Check if customer profile exists
        if not hasattr(instance, 'customer_profile'):
            full_name = instance.get_full_name() or instance.username
            if '@' in full_name:  # If username is email
                full_name = full_name.split('@')[0].replace('.', ' ').replace('_', ' ').title()
            
            Customer.objects.get_or_create(
                user=instance,
                defaults={
                    'full_name': full_name,
                }
            )
            print(f"✅ Customer profile created for existing user {instance.username} ({instance.email})")


@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def save_customer_profile(sender, instance, **kwargs):
    """
    Save customer profile when user is saved
    """
    if instance.role == 'CUSTOMER':
        if hasattr(instance, 'customer_profile'):
            instance.customer_profile.save()