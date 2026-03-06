from django.db import models
from django.utils import timezone
from accounts.models import User

class Salon(models.Model):
    SALON_TYPE_CHOICES = [
        ('male', 'Male'),
        ('female', 'Female'),
        ('unisex', 'Unisex'),
    ]
    
    owner = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='salon',
        limit_choices_to={'role': 'SALON_OWNER'}
    )
    
    # Basic Information
    name = models.CharField(max_length=100)
    salon_type = models.CharField(
        max_length=10,
        choices=SALON_TYPE_CHOICES,
        default='unisex'
    )
    address = models.TextField()
    
    # ✅ NEW: City field for location-based filtering
    city = models.CharField(
        max_length=100,
        blank=True,
        default='',
        help_text="City name for location-based filtering",
        db_index=True  # Add index for faster queries
    )
    
    # ✅ NEW: State/Region field (optional)
    state = models.CharField(
        max_length=100,
        blank=True,
        default='',
        help_text="State/Region name"
    )
    
    # ✅ NEW: Pincode field
    pincode = models.CharField(
        max_length=10,
        blank=True,
        default='',
        help_text="Postal/ZIP code"
    )
    
    phone = models.CharField(max_length=15)
    about = models.TextField(blank=True, default='')
    
    # Image - allow blank URLs
    image_url = models.URLField(blank=True, default='')
    
    # Working Hours (stored as JSON)
    hours = models.JSONField(default=dict, blank=True)
    
    # Blockout Dates — holidays/closures (stored as list of ISO date strings)
    blockout_dates = models.JSONField(default=list, blank=True, help_text="List of ISO date strings for holidays")
    
    # ✅ NEW: Location coordinates (for future distance calculations)
    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
        help_text="Latitude for location services"
    )
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
        help_text="Longitude for location services"
    )
    
    # Ratings & Status
    rating = models.FloatField(default=0.0)
    is_open = models.BooleanField(default=True)
    
    # Metadata - auto_now for updated_at
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['city', 'is_open']),  # Composite index for filtering
            models.Index(fields=['state']),
            models.Index(fields=['pincode']),
        ]
    
    def __str__(self):
        city_info = f" - {self.city}" if self.city else ""
        return f"{self.name}{city_info} ({self.owner.email})"
    
    def save(self, *args, **kwargs):
        """Override save to ensure updated_at is set and extract city from address"""
        if not self.pk:  # New object
            if not self.created_at:
                self.created_at = timezone.now()
        
        # ✅ Auto-extract city from address if not provided
        if not self.city and self.address:
            self.city = self._extract_city_from_address()
        
        self.updated_at = timezone.now()
        super().save(*args, **kwargs)
    
    def _extract_city_from_address(self):
        """
        Try to extract city name from address
        This is a basic implementation - you may want to improve this
        """
        if not self.address:
            return ''
        
        # Common patterns: "Street, City, State, Pincode"
        # Try to find city name (usually after first comma)
        parts = [p.strip() for p in self.address.split(',')]
        
        if len(parts) >= 2:
            # Second part is usually the city
            return parts[1]
        
        return ''
    
    @property
    def full_address(self):
        """Return formatted full address"""
        parts = [self.address]
        if self.city:
            parts.append(self.city)
        if self.state:
            parts.append(self.state)
        if self.pincode:
            parts.append(self.pincode)
        return ', '.join(parts)