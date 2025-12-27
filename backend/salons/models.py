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
    phone = models.CharField(max_length=15)
    about = models.TextField(blank=True, default='')
    
    # Image - allow blank URLs
    image_url = models.URLField(blank=True, default='')
    
    # Working Hours (stored as JSON)
    hours = models.JSONField(default=dict, blank=True)
    
    # Ratings & Status
    rating = models.FloatField(default=0.0)
    is_open = models.BooleanField(default=True)
    
    # Metadata - auto_now for updated_at
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.name} ({self.owner.email})"
    
    def save(self, *args, **kwargs):
        """Override save to ensure updated_at is set"""
        if not self.pk:  # New object
            if not self.created_at:
                self.created_at = timezone.now()
        self.updated_at = timezone.now()
        super().save(*args, **kwargs)