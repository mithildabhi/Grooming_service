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
    
    # Image
    image_url = models.URLField(blank=True, default='')
    # OR if you want to store files:
    # image = models.ImageField(upload_to='salon_images/', blank=True, null=True)
    
    # Working Hours (stored as JSON)
    hours = models.JSONField(default=dict, blank=True)
    # Example: {
    #   "Mon": "09:00-19:00",
    #   "Tue": "09:00-19:00",
    #   "Sun": "Closed"
    # }
    
    # Ratings & Status
    rating = models.FloatField(default=0.0)
    is_open = models.BooleanField(default=True)
    
    # Metadata
    created_at=models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.name} ({self.owner.email})"
